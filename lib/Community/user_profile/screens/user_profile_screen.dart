import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/common/loader.dart';
import 'package:hadafi_application/Community/controller/community_controller.dart';
import 'package:hadafi_application/Community/provider.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hadafi_application/Community/firebase_constants.dart';
import 'package:hadafi_application/Community/user_profile/screens/edit_profile_screen.dart';

class UserProfileScreen extends ConsumerWidget {
  final String uid;
  const UserProfileScreen({
    super.key,
    required this.uid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ref.watch(userDataProvider(uid)).when(
            data: (user) {
              if (user == null) {
                return const Center(child: Text('User data is not available.'));
              }
              bool isNetworkBanner = user['banner'] != null &&
                  Uri.parse(user['banner']).isAbsolute &&
                  user['banner'].isNotEmpty;
              bool isNetworkAvatar = user['profilePic'] != null &&
                  Uri.parse(user['profilePic']).isAbsolute &&
                  user['profilePic'].isNotEmpty;

              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 220,
                      floating: true,
                      snap: true,
                      flexibleSpace: Stack(
                        children: [
                          Positioned.fill(
                            child: isNetworkBanner
                                ? Image.network(
                                    user['banner'],
                                    fit: BoxFit.cover,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      } else {
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    (loadingProgress
                                                            .expectedTotalBytes ??
                                                        1)
                                                : null,
                                          ),
                                        );
                                      }
                                    },
                                  )
                                : const SizedBox.shrink(),
                          ),
                          Container(
                            alignment: Alignment.bottomLeft,
                            padding:
                                const EdgeInsets.all(20).copyWith(bottom: 70),
                            child: isNetworkAvatar
                                ? CircleAvatar(
                                    radius: 40,
                                    backgroundImage:
                                        NetworkImage(user['profilePic']),
                                  )
                                : const CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.grey,
                                    child: Icon(Icons.person, size: 40),
                                  ),
                          ),
                          Container(
                            alignment: Alignment.bottomLeft,
                            padding: const EdgeInsets.all(20),
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfileScreen(
                                      uid: uid,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 25),
                              ),
                              child: const Text('Edit Profile'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'u/${user['name'] ?? 'Unknown'}',
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Divider(thickness: 2),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: const Text("Displaying Posts"),
              );
            },
            error: (error, StackTrace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
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
