import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/common/error_text.dart';
import 'package:hadafi_application/Community/common/loader.dart';
import 'package:hadafi_application/Community/common/post_card.dart';
import 'package:hadafi_application/Community/model/community_model.dart';
import 'package:hadafi_application/Community/post/controller/post_controller.dart';
import 'package:hadafi_application/Community/post/screens/add_post_type_screen.dart';
import 'package:hadafi_application/Community/controller/community_controller.dart';
import 'package:hadafi_application/Community/provider.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userID = ref.watch(uidProvider) ?? '';
    if (userID.isEmpty) {
      return const Center(child: Text('User not logged in.'));
    }

    return ref.watch(userCommunityProvider(userID)).when(
          data: (communities) {
            // ✅ If user is not in any community, show a message
            if (communities.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "You're not in any community yet.\nJoin a community to see posts here.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54),
                  ),
                ),
              );
            }

            return ref.watch(userPostProvider(communities)).when(
                  data: (data) {
                    print("Fetched posts: ${data.length}"); // 🔍 Debugging Step
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (BuildContext context, int index) {
                        final post = data[index];
                        print(
                            "Post data: ${post.toMap()}"); // 🔍 Debugging Step
                        return PostCard(post: post);
                      },
                    );
                  },
                  error: (error, stackTrace) {
                    print("Error loading posts: $error"); // 🔍 Debugging Step
                    return ErrorText(error: error.toString());
                  },
                  loading: () => const Loader(),
                );
          },
          error: (error, stackTrace) {
            print("Error loading communities: $error"); // 🔍 Debugging Step
            return ErrorText(error: error.toString());
          },
          loading: () => const Loader(),
        );
  }
}
