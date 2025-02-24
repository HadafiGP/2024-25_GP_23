import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/common/loader.dart';
import 'package:hadafi_application/Community/constants/constants.dart';
import 'package:hadafi_application/Community/controller/community_controller.dart';
import 'package:hadafi_application/Community/core/utils.dart';
import 'package:hadafi_application/Community/model/community_model.dart';
import 'package:image_picker/image_picker.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  final String name;
  const EditCommunityScreen({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  File? bannerFile;
  File? profileFile;

  void selectBannerImage() async {
    final XFile? res = await pickImage();
    if (res != null) {
      setState(() {
        bannerFile = File(res.path);
      });
    }
  }

  void selectProfileImage() async {
    final XFile? res = await pickImage();
    if (res != null) {
      setState(() {
        profileFile = File(res.path);
      });
    }
  }

  void save(Community community) {
    ref.read(communityControllerProvider.notifier).editCommunity(
          profileFile: profileFile,
          bannerFile: bannerFile,
          context: context,
          community: community,
          
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    return ref.watch(getCommunityByNameProvider(widget.name)).when(
          data: (community) {
            if (community == null) {
              return const Scaffold(
                body: Center(
                    child: Text("Error: Community data is null",
                        style: TextStyle(color: Colors.red))),
              );
            }

            bool isNetworkBanner = community.banner != null &&
                Uri.parse(community.banner).isAbsolute;
            bool isNetworkAvatar = community.avatar != null &&
                Uri.parse(community.avatar).isAbsolute;

            return Scaffold(
              appBar: AppBar(
                backgroundColor: const Color(0xFF113F67), // Matches Mod Tools
                centerTitle: true,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: const Text(
                  'Style Your Community',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              body: isLoading
                  ? const Loader()
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Explanation Text
                          const Text(
                            "A banner and avatar attract members and establish your community's culture.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // **Preview Section**
                          const Text(
                            "Preview",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Banner & Avatar in Stack for proper positioning
                          SizedBox(
                            height: 190,
                            child: Stack(
                              clipBehavior: Clip.none, // Ensures avatar is not clipped
                              children: [
                                // Banner Image
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
                                            ? Image.file(
                                                bannerFile!,
                                                fit: BoxFit.cover,
                                              )
                                            : community.banner == null ||
                                                    community.banner.isEmpty ||
                                                    community.banner ==
                                                        Constants
                                                            .bannerDefault
                                                ? const Center(
                                                    child: Icon(
                                                      Icons
                                                          .camera_alt_outlined,
                                                      size: 40,
                                                      color: Colors.grey,
                                                    ),
                                                  )
                                                : isNetworkBanner
                                                    ? Image.network(
                                                        community.banner,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Image.file(
                                                        File(community.banner),
                                                        fit: BoxFit.cover,
                                                      ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Profile Image (Overlapping Banner)
                                Positioned(
                                  bottom: -1, // Moves avatar down to overlap banner
                                  left: 20, // Aligns to left
                                  child: GestureDetector(
                                    onTap: selectProfileImage,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white, // White border
                                          width: 2,
                                        ),
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
                                                  ? NetworkImage(community.avatar)
                                                  : (community.avatar != null &&
                                                          community
                                                              .avatar.isNotEmpty
                                                      ? FileImage(File(
                                                          community.avatar))
                                                      : const AssetImage(
                                                              'assets/default_avatar.png')
                                                          as ImageProvider),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Banner Selection
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Banner",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                    
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: selectBannerImage,
                                icon: const Icon(Icons.image_outlined),
                                label: const Text("Add"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  foregroundColor: Colors.black,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Avatar Selection
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Avatar",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              
                              ElevatedButton.icon(
                                onPressed: selectProfileImage,
                                icon: const Icon(Icons.image_outlined),
                                label: const Text("Add"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  foregroundColor: Colors.black,
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => save(community),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF113F67),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
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
            child: Text(
              "Error: $error",
              style: const TextStyle(color: Colors.red),
            ),
          ),
        );
  }
}
