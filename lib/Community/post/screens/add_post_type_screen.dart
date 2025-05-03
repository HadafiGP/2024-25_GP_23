import 'dart:io';
import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/common/error_text.dart';
import 'package:hadafi_application/Community/common/loader.dart';
import 'package:hadafi_application/Community/controller/community_controller.dart';
import 'package:hadafi_application/Community/model/community_model.dart';
import 'package:hadafi_application/Community/post/controller/post_controller.dart';
import 'package:hadafi_application/Community/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants/constants.dart';
import '../../core/utils.dart';
import 'package:image/image.dart' as img;

class AddPostTypeScreen extends ConsumerStatefulWidget {
  final String type;
  const AddPostTypeScreen({super.key, required this.type});

  @override
  ConsumerState<AddPostTypeScreen> createState() => _AddPostTypeScreenState();
}

class _AddPostTypeScreenState extends ConsumerState<AddPostTypeScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkController = TextEditingController();

  bool isLoading = false;
  bool _isCheckingNetwork = false;
  File? bannerFile;
  List<Community> communities = [];
  Community? selectedCommunity;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose(); // ✅ Dispose correctly
    super.dispose();
  }

  Future<bool> hasFirestoreConnection() async {
    try {
      await FirebaseFirestore.instance
          .collection('Community')
          .limit(1)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 10));
      return true;
    } catch (_) {
      return false;
    }
  }

  void selectBannerImage() async {
    setState(() => isLoading = true); // Show loader during image processing

    try {
      final XFile? res =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (res == null) {
        showSnackBar(context, "No image selected.");
        setState(() => isLoading = false);
        return;
      }

      File selectedFile = File(res.path);
      File compressedFile = await compressImage(selectedFile);

      setState(() {
        bannerFile = compressedFile;
        isLoading = false;
      });
    } catch (e) {
      showSnackBar(context, "Image selection failed: $e");
      setState(() => isLoading = false);
    }
  }

  Future<File> compressImage(File imageFile) async {
    Uint8List imageBytes = await imageFile.readAsBytes();
    img.Image image = img.decodeImage(imageBytes)!;

    // Resize to a max width of 800px (preserving aspect ratio)
    final resized = img.copyResize(image, width: 800);

    List<int> compressedBytes = img.encodeJpg(resized, quality: 50);

    final compressedFile = File(imageFile.path);
    await compressedFile.writeAsBytes(compressedBytes); // ✅ Async write
    return compressedFile;
  }

  void sharePost() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      _isCheckingNetwork = true;
    });

    final hasConnection = await hasFirestoreConnection();
    if (!hasConnection) {
      showSnackBar(context, "No internet connection.");
      setState(() {
        isLoading = false;
        _isCheckingNetwork = false;
      });
      return;
    }

    setState(() => _isCheckingNetwork = false);

    try {
      if (widget.type == 'image' &&
          bannerFile != null &&
          titleController.text.isNotEmpty) {
        showSnackBar(context, "Uploading image, please wait...", success: true);

        await ref.read(PostControllerProvider.notifier).sharedImagePost(
              context: context,
              title: titleController.text.trim(),
              selectedCommunity: selectedCommunity ?? communities[0],
              file: bannerFile!,
              description: descriptionController.text.trim(),
            );
      } else if (titleController.text.isEmpty) {
        showSnackBar(context, 'Please enter a title.');
      } else if (widget.type == 'image' && bannerFile == null) {
        showSnackBar(context, 'Please select an image to upload.');
      } else if (widget.type == 'text') {
        if (titleController.text.isNotEmpty) {
          await ref.read(PostControllerProvider.notifier).sharedTextPost(
              context: context,
              title: titleController.text.trim(),
              selectedCommunity: selectedCommunity ?? communities[0],
              description: descriptionController.text.trim());
        }
      }
      if (widget.type == 'link') {
        String link = linkController.text.trim();

        if (titleController.text.isEmpty) {
          showSnackBar(context, 'Please enter a title.');
          return;
        }

        if (link.isEmpty) {
          showSnackBar(context, 'Please enter a link URL.');
          return;
        }

        Uri? parsedUri = Uri.tryParse(link);

        if (parsedUri == null ||
            !parsedUri.isAbsolute ||
            parsedUri.scheme.isEmpty) {
          showSnackBar(context, 'Please enter a valid URL.');
          return;
        }

        ref.read(PostControllerProvider.notifier).sharedLinkPost(
              context: context,
              title: titleController.text.trim(),
              selectedCommunity: selectedCommunity ?? communities[0],
              link: link,
              description: descriptionController.text.trim(),
            );
      }
    } catch (e) {
      showSnackBar(context, "Error: ${e.toString()}");
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the userID from FirebaseAuth
    final userID = ref.watch(uidProvider) ?? '';
    if (userID.isEmpty) {
      return const Center(child: Text('User not logged in.'));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF113F67),
        title: Text(
          widget.type == 'image'
              ? 'Post Image'
              : widget.type == 'link'
                  ? 'Post Link'
                  : 'Post Text',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ref.watch(userCommunityProvider(userID)).when(
            data: (data) {
              communities = data;
              if (data.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "You haven't joined any community yet.\nJoin a community first to share posts.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        filled: true,
                        hintText: 'Enter Title Here',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(18),
                      ),
                      maxLength: 30,
                    ),
                    const SizedBox(height: 10),
                    // Image upload area
                    if (widget.type == 'image')
                      GestureDetector(
                        onTap: selectBannerImage,
                        child: DottedBorder(
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(10),
                          dashPattern: const [10, 4],
                          strokeCap: StrokeCap.round,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: double.infinity,
                              height: 150,
                              color: Colors.grey[200],
                              child: bannerFile != null
                                  ? Image.file(bannerFile!, fit: BoxFit.cover)
                                  : const Center(
                                      child: Icon(
                                        Icons.camera_alt_outlined,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    if (widget.type == 'link' || widget.type == 'image')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          TextField(
                            controller: descriptionController,
                            decoration: const InputDecoration(
                              filled: true,
                              hintText: 'Enter Description Here',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(18),
                            ),
                            minLines: 3,
                            maxLines: 5,
                            maxLength: 300,
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    if (widget.type == 'text')
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          filled: true,
                          hintText: 'Enter Description Here',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(18),
                        ),
                        minLines: 3,
                        maxLines: 5,
                        maxLength: 300,
                      ),
                    if (widget.type == 'link')
                      TextField(
                        controller: linkController,
                        decoration: const InputDecoration(
                          filled: true,
                          hintText: 'Enter Link Here',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(18),
                        ),
                      ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Select Community:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF113F67),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ref.watch(userCommunityProvider(userID)).when(
                          data: (data) {
                            communities = data;
                            if (data.isEmpty) {
                              return const SizedBox();
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 12.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF113F67),
                                      Color.fromARGB(255, 105, 185, 255),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(1.8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<Community>(
                                      value: selectedCommunity ?? data[0],
                                      isExpanded: true,
                                      icon: const Icon(Icons.arrow_drop_down,
                                          color: Color(0xFF113F67)),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF113F67),
                                      ),
                                      items: data.map((e) {
                                        return DropdownMenuItem(
                                          value: e,
                                          child: Text(e.name),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          selectedCommunity = val;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          error: (error, StackTrace) =>
                              ErrorText(error: error.toString()),
                          loading: () => const Loader(),
                        ),
                    const Spacer(),
                    GestureDetector(
                      onTap: isLoading ? null : sharePost,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color:
                              isLoading ? Colors.grey : const Color(0xFF113F67),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  "Share",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            error: (error, stackTrace) {
              return ErrorText(error: error.toString());
            },
            loading: () => const Loader(),
          ),
    );
  }
}
