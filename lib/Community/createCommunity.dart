import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/CommunityProfile.dart';
import 'package:hadafi_application/Community/addCommunity.dart';
import 'package:hadafi_application/Community/controller/community_controller.dart';
import 'package:hadafi_application/Community/common/loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hadafi_application/Community/firebase_constants.dart';

class createCommunityUI extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            const Text(
              "Your Communities",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ref.watch(userCommunityProvider).when(
                    data: (communities) => ListView.builder(
                      itemCount: communities.length,
                      itemBuilder: (BuildContext context, int index) {
                        final community = communities[index];

                        bool isNetworkImage =
                            Uri.parse(community.avatar).isAbsolute;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: isNetworkImage
                                ? NetworkImage(community.avatar)
                                    as ImageProvider
                                : FileImage(File(community.avatar)),
                          ),
                          title: Text('r/${community.name}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    Communityprofile(name: community.name),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    error: (error, stackTrace) => Center(
                      child: Text(
                        "Error: $error",
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    loading: () => const Loader(),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}