import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/common/loader.dart';
import 'package:hadafi_application/Community/constants/constants.dart';
import 'package:hadafi_application/Community/controller/community_controller.dart';
import 'package:hadafi_application/Community/core/utils.dart';
import 'package:hadafi_application/Community/provider.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final String uid;
  const EditProfileScreen({super.key, required this.uid});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  File? bannerFile;
  File? profileFile;
  late TextEditingController nameController;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void selectProfileImage() async {
    final XFile? res = await pickImage();
    if (res != null) {
      setState(() {
        profileFile = File(res.path);
      });

      FirebaseStorage storage = FirebaseStorage.instance;
      String fileName = 'user_${widget.uid}_profile.jpg';
      Reference ref = storage.ref().child('profile_images/$fileName');
      UploadTask uploadTask = ref.putFile(profileFile!);

      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      String downloadUrl = await snapshot.ref.getDownloadURL();

      await _firestore.collection('Student').doc(widget.uid).update({
        'profilePic': downloadUrl,
      });
    }
  }

  void selectBannerImage() async {
    final XFile? res = await pickImage();
    if (res != null) {
      setState(() {
        bannerFile = File(res.path);
      });

      FirebaseStorage storage = FirebaseStorage.instance;
      String fileName = 'user_${widget.uid}_banner.jpg';
      Reference ref = storage.ref().child('banner_images/$fileName');
      UploadTask uploadTask = ref.putFile(bannerFile!);

      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      String downloadUrl = await snapshot.ref.getDownloadURL();

      await _firestore.collection('Student').doc(widget.uid).update({
        'banner': downloadUrl,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    void showSnackBar(BuildContext context, String message,
        {bool success = false}) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor:
              success ? Colors.green: Colors.red,
        ),
      );
    }

    return ref.watch(userDataProvider(widget.uid)).when(
          data: (community) {
            if (community == null) {
              return const Scaffold(
                body: Center(
                    child: Text("Error: Community data is null",
                        style: TextStyle(color: Colors.red))),
              );
            }

            bool isNetworkBanner = community['banner'].isNotEmpty &&
                Uri.parse(community['banner']).isAbsolute;
            bool isNetworkAvatar = community['profilePic'].isNotEmpty &&
                Uri.parse(community['profilePic']).isAbsolute;

            return Scaffold(
              appBar: AppBar(
                backgroundColor: const Color(0xFF113F67),
                centerTitle: true,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: const Text('Edit Profile',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18)),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                        "Edit your banner and avatar to customize your profile.",
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 20),
                    const Text("Preview",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 190,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
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
                                      ? Image.file(bannerFile!,
                                          fit: BoxFit.cover)
                                      : community['banner'].isEmpty ||
                                              community['banner'] ==
                                                  Constants.bannerDefault
                                          ? const Center(
                                              child: Icon(
                                                  Icons.camera_alt_outlined,
                                                  size: 40,
                                                  color: Colors.grey))
                                          : isNetworkBanner
                                              ? Image.network(
                                                  community['banner'],
                                                  fit: BoxFit.cover)
                                              : Image.file(
                                                  File(community['banner'])),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -1,
                            left: 20,
                            child: GestureDetector(
                              onTap: selectProfileImage,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(
                                    radius: 36,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage: profileFile != null
                                        ? FileImage(profileFile!)
                                        : isNetworkAvatar
                                            ? NetworkImage(
                                                community['profilePic'])
                                            : community['profilePic'].isNotEmpty
                                                ? FileImage(File(
                                                    community['profilePic']))
                                                : const AssetImage(
                                                        'assets/default_avatar.png')
                                                    as ImageProvider,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Banner",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        ElevatedButton.icon(
                          onPressed: selectBannerImage,
                          icon: const Icon(Icons.image_outlined),
                          label: const Text("Add"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              foregroundColor: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Profile Picture",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        ElevatedButton.icon(
                          onPressed: selectProfileImage,
                          icon: const Icon(Icons.image_outlined),
                          label: const Text("Add"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              foregroundColor: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        filled: true,
                        hintText: 'Name',
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(18),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Save changes to the name in Firestore
                          String updatedName = nameController.text.trim();

                          if (updatedName.isNotEmpty) {
                            try {
                              await _firestore
                                  .collection('Student')
                                  .doc(widget.uid)
                                  .update({
                                'name': updatedName, 
                              });

                            
                              showSnackBar(
                                  context, 'Profile updated successfully!',
                                  success: true);
                              Navigator.of(context)
                                  .pop(); 
                            } catch (e) {
                      
                              showSnackBar(
                                  context, 'Error updating profile: $e',
                                  success: false);
                            }
                          } else {
                            showSnackBar(context, 'Name cannot be empty',
                                success: false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFF113F67),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
          loading: () => const Loader(),
          error: (error, stackTrace) => Center(
              child: Text("Error: $error",
                  style: const TextStyle(color: Colors.red))),
        );
  }
}
