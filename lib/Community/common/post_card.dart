import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/CommunityProfile.dart';
import 'package:hadafi_application/Community/common/loader.dart';
import 'package:hadafi_application/Community/constants/constants.dart';
import 'package:hadafi_application/Community/controller/community_controller.dart';
import 'package:hadafi_application/Community/model/post_model.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:hadafi_application/Community/post/controller/post_controller.dart';
import 'package:hadafi_application/Community/post/screens/add_post_type_screen.dart';
import 'package:hadafi_application/Community/post/screens/comments_screen.dart';
import 'package:hadafi_application/Community/provider.dart';
import 'package:http/http.dart';
import 'package:routemaster/routemaster.dart';
import 'package:hadafi_application/Community/user_profile/screens/user_profile_screen.dart';
import 'package:hadafi_application/Community/common/error_text.dart';
import 'package:url_launcher/url_launcher.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard({
    super.key,
    required this.post,
  });

  // void deletePost(WidgetRef ref, BuildContext context) async{
  //   ref.read(PostControllerProvider.notifier).deletePost(post, context);
  // }

  void deletePost(WidgetRef ref, BuildContext context) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this post?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // ❌ Cancel
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // ✅ Confirm
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    // If the user confirmed deletion, proceed
    if (confirmDelete == true) {
      ref.read(PostControllerProvider.notifier).deletePost(post, context);
    }
  }

  void upvotePost(WidgetRef ref) async {
    ref.read(PostControllerProvider.notifier).upvote(post);
  }

  void downvotePost(WidgetRef ref) async {
    ref.read(PostControllerProvider.notifier).downvote(post);
  }

  void navigateToUser(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(uid: post.uid), // ✅ Pass UID
      ),
    );
  }

  void navigateToCommunity(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            Communityprofile(name: post.communityName), // ✅ Pass Community Name
      ),
    );
  }

  void navigateToComments(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsScreen(postId: post.id), // ✅ Pass Post ID
      ),
    );
  }

  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeLink = post.type == 'link';

    if (isTypeLink && post.link != null && post.link!.isNotEmpty) {
      debugLinkPreview(post.link!); // Call debug function here
    }
    final isTypeImage = post.type == 'image';
    final isTypeText = post.type == 'text';
    final userID = ref.watch(uidProvider) ?? '';
    if (userID.isEmpty) {
      return const Center(child: Text('User not logged in.'));
    } //final currenThem = ref.watch(themNotifierProvider);
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 219, 225, 231),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 16,
                      ).copyWith(right: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => navigateToCommunity(context),
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        post.communityProfilePic,
                                      ),
                                      radius: 16,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'c/${post.communityName}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => navigateToUser(context),
                                          child: Text(
                                            'u/${post.username}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (post.uid == userID)
                                IconButton(
                                  onPressed: () => deletePost(ref, context),
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              post.title,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // ✅ Show description for Image and Link posts
                          if ((isTypeImage || isTypeLink) &&
                              post.description != null &&
                              post.description!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 10),
                              child: Text(
                                post.description!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),

                          if (isTypeImage)
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.35,
                              width: double.infinity,
                              child: Image.network(
                                post.link!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (isTypeLink &&
                              post.link != null &&
                              post.link!.isNotEmpty)
                            FutureBuilder<Metadata?>(
                              future: AnyLinkPreview.getMetadata(
                                link: post.link!,
                                cache: const Duration(hours: 1),
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                if (!snapshot.hasData || snapshot.hasError) {
                                  return const Text('Invalid URL');
                                }

                                final metadata = snapshot.data!;

                                return Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (metadata.image != null)
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          child: Image.network(
                                            metadata.image!,
                                            fit: BoxFit.cover,
                                            height: 150,
                                            width: double.infinity,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Icon(
                                                  Icons.broken_image,
                                                  size: 50,
                                                  color: Colors.red);
                                            },
                                          ),
                                        ),
                                      const SizedBox(height: 5),
                                      Text(metadata.title ?? "No Title",
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 5),
                                      GestureDetector(
                                        onTap: () async {
                                          final Uri uri = Uri.parse(post.link!);
                                          if (await canLaunchUrl(uri)) {
                                            await launchUrl(uri);
                                          } else {
                                            print(
                                                "Could not open URL: ${post.link}");
                                          }
                                        },
                                        child: Text(
                                          metadata.url ?? post.link!,
                                          style: const TextStyle(
                                              color: Colors.blue,
                                              decoration:
                                                  TextDecoration.underline),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          if (isTypeText)
                            Container(
                              alignment: Alignment.bottomLeft,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Text(
                                post.description!,
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => upvotePost(ref),
                                    icon: Icon(
                                      Constants.up,
                                      size: 25,
                                      color: post.upvotes.contains(userID)
                                          ? Colors.blue
                                          : null,
                                    ),
                                  ),
                                  Text(
                                    '${post.upvotes.length - post.downvotes.length == 0 ? 'Vote' : post.upvotes.length - post.downvotes.length}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => downvotePost(ref),
                                    icon: Icon(
                                      Constants.down,
                                      size: 25,
                                      color: post.downvotes.contains(userID)
                                          ? Colors.red
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        navigateToComments(context),
                                    icon: const Icon(
                                      Icons.comment,
                                      size: 25,
                                    ),
                                  ),
                                  Text(
                                    '${post.commentCount == 0 ? 'Comment' : post.commentCount}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              ref
                                  .watch(getCommunityByNameProvider(
                                      post.communityName))
                                  .when(
                                    data: (data) {
                                      if (data.mods.contains(userID)) {
                                        return IconButton(
                                          onPressed: () =>
                                              deletePost(ref, context),
                                          icon: const Icon(
                                            Icons.admin_panel_settings,
                                            size: 25,
                                          ),
                                        );
                                      }
                                      return const SizedBox();
                                    },
                                    error: (error, stackTrace) {
                                      print(
                                          "Error loading communities: $error"); // 🔍 Debugging Step
                                      return Center(
                                        child: Text(
                                          "Error: ${error.toString()}",
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 16),
                                        ),
                                      );
                                    },
                                    loading: () => const Loader(),
                                  ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
      ],
    );
  }

  Future<void> debugLinkPreview(String url) async {
    try {
      final response = await AnyLinkPreview.getMetadata(link: url);
      print("Metadata fetched: $response");
    } catch (e) {
      print("Error fetching metadata: $e");
    }
  }
}
