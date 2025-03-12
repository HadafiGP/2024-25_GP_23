import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/CommunityProfile.dart';
import 'package:hadafi_application/Community/addCommunity.dart';
import 'package:hadafi_application/Community/controller/community_controller.dart';
import 'package:hadafi_application/Community/common/loader.dart';
import 'package:hadafi_application/Community/model/community_model.dart';
import 'package:hadafi_application/Community/provider.dart';

class createCommunityUI extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(uidProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCommunityScreen()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF113F67),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    "+ Create Community",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (userId == null)
              const Center(child: Text("No user logged in"))
            else
              Expanded(
                child: ref.watch(userCommunityProvider(userId)).when(
                      data: (communities) {
                        // Filter moderating and joined communities
                        final moderating = communities
                            .where(
                                (community) => community.mods.contains(userId))
                            .toList();
                        final joined = communities
                            .where((community) =>
                                community.members.contains(userId) &&
                                !community.mods.contains(userId))
                            .toList();

                        return ListView(
                          children: [
                            if (moderating.isNotEmpty) ...[
                              const Text(
                                "Moderating Communities",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF113F67),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...moderating.map((community) =>
                                  _buildCommunityTile(context, community)),
                              const SizedBox(height: 16),
                            ] else...[
                              const Text(
                                "Moderating Communities",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF113F67),
                                ),
                              ),
                            const SizedBox(height: 8),
                            const Center(
                                child: Text(
                                    "You are not moderating any communities.",style: TextStyle(
                                  fontSize: 15,))),
                            const SizedBox(height: 16),
                            ],
                            if (joined.isNotEmpty) ...[
                              const Text(
                                "Joined Communities",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF113F67),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...joined.map((community) =>
                                  _buildCommunityTile(context, community)),
                            ] else...[
                              const Text(
                                "Joined Communities",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF113F67),
                                ),
                              ),
                            const SizedBox(height: 8),
                            const Center(
                                child: Text(
                                    "You have not joined any communities.",style: TextStyle(
                                  fontSize: 15,))),]
                          ],
                        );
                      },
                      error: (error, stackTrace) => Center(
                        child: Text("Error: $error",
                            style: const TextStyle(color: Colors.red)),
                      ),
                      loading: () => const Loader(),
                    ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityTile(BuildContext context, Community community) {
    bool isNetworkImage = Uri.parse(community.avatar).isAbsolute;

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: isNetworkImage
            ? NetworkImage(community.avatar) as ImageProvider
            : FileImage(File(community.avatar)),
      ),
      title: Text('r/${community.name}'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Communityprofile(name: community.name),
          ),
        );
      },
    );
  }
}
