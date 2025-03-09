import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  bool isLoading = false; // ✅ Added loading state
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

  void selectBannerImage() async {
    final XFile? res =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (res != null) {
      setState(() {
        bannerFile = File(res.path);
      });
    }
  }

//////////////////////////////////////////
  void sharePost() async {
    setState(() {
      isLoading = true; // ✅ Show loading indicator
    });

    await Future.delayed(
        Duration(milliseconds: 200)); // ✅ Ensure input is captured

    if (widget.type == 'image' &&
        bannerFile != null &&
        titleController.text.isNotEmpty) {
      await ref.read(PostControllerProvider.notifier).sharedImagePost(
          context: context,
          title: titleController.text.trim(),
          selectedCommunity: selectedCommunity ?? communities[0],
          file: bannerFile);
    } else if (titleController.text.isEmpty) {
      showSnackBar(context, 'Please enter a title.');
    } else if (widget.type == 'image' && bannerFile == null) {
      showSnackBar(context, 'Please select an image to upload.');
    } else if (widget.type == 'text') {
      if (titleController.text.isNotEmpty) {
        ref.read(PostControllerProvider.notifier).sharedTextPost(
            context: context,
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity ?? communities[0],
            description: descriptionController.text.trim());
      }
    }
    if (widget.type == 'link') {
      String link = linkController.text.trim();

      // Debugging step to ensure the linkController is correctly attached
      print("Entered link before trimming: '${linkController.text}'");
      print("Entered link after trimming: '$link'");

      print("Entered link: '$link'");

      if (titleController.text.isEmpty) {
        showSnackBar(context, 'Please enter a title.');
        return;
      }

      if (link.isEmpty) {
        showSnackBar(context, 'Please enter a link URL.');
        return;
      }

      Uri? parsedUri = Uri.tryParse(link);

      print("Parsed URI: $parsedUri");
      print("isAbsolute: ${parsedUri?.isAbsolute}");

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
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTypeImage = widget.type == 'image';
    final isTypeText = widget.type == 'text';
    final isTypeLink = widget.type == 'link';

    // Get the userID from FirebaseAuth
    final userID = ref.watch(uidProvider) ?? '';
    if (userID.isEmpty) {
      return const Center(child: Text('User not logged in.'));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF113F67), // ✅ Same as "Create Community"
        title: Text(
          isTypeImage
              ? 'Post Image'
              : isTypeLink
                  ? 'Post Link'
                  : 'Post Text', // ✅ Dynamically change title
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context), // ✅ Go back to previous page
        ),
      ),
      body: Padding(
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
            if (isTypeImage)
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
            if (isTypeText)
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  filled: true,
                  hintText: 'Enter Description Here',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(18),
                ),
                maxLines: 5,
              ),
            if (isTypeLink)
              TextField(
                controller: linkController,
                decoration: const InputDecoration(
                  filled: true,
                  hintText: 'Enter Link Here',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(18),
                ),
                onChanged: (val) {
                  print("TextField Input: $val");
                },
              ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.topLeft,
              child: Text('Select Community'),
            ),
            ref.watch(userCommunityProvider(userID)).when(
                  data: (data) {
                    communities = data;
                    if (data.isEmpty) {
                      return const SizedBox();
                    }
                    return DropdownButton(
                      value: selectedCommunity ?? data[0],
                      items: data
                          .map((e) =>
                              DropdownMenuItem(value: e, child: Text(e.name)))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedCommunity = val;
                        });
                      },
                    );
                  },
                  error: (error, StackTrace) =>
                      ErrorText(error: error.toString()),
                  loading: () => const Loader(),
                ),
            const Spacer(), // ✅ Pushes the button to the bottom

            GestureDetector(
              onTap: isLoading
                  ? null
                  : sharePost, // ✅ Disable button while loading
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isLoading
                      ? Colors.grey
                      : const Color(0xFF113F67), // ✅ Change color while loading
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white) // ✅ Show loading
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
      ),
    );
  }
}

class ErrorText extends StatelessWidget {
  final String error;

  const ErrorText({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        error,
        style: TextStyle(
          color: Colors.red,
          fontSize: 16,
        ),
      ),
    );
  }
}
