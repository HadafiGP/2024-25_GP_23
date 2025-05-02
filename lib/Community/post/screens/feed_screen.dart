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
import 'package:hadafi_application/Community/post/screens/communityHeader.dart';
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
                    return ListView.builder(
                      itemCount: data.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              FeedCommunitiesHeader(),
                              Divider(
                                color: Colors.grey,
                                thickness: 0.7,
                                height:
                                    24, 
                                indent: 12,
                                endIndent: 12,
                              ),
                            ],
                          );
                        }
                        final post = data[index - 1];
                        return PostCard(
                          key: ValueKey(post.id),
                          post: post,
                        );
                      },
                    );
                  },
                  error: (error, stackTrace) {
                    print("Error loading posts: $error");
                    return ErrorText(error: error.toString());
                  },
                  loading: () => const Loader(),
                );
          },
          error: (error, stackTrace) {
            print("Error loading communities: $error");
            return ErrorText(error: error.toString());
          },
          loading: () => const Loader(),
        );
  }
}
