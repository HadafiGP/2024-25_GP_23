import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/common/loader.dart';
import 'package:hadafi_application/Community/common/post_card.dart';
import 'package:hadafi_application/Community/controller/community_controller.dart';
import 'package:hadafi_application/Community/mod_screens_tools.dart';
import 'package:hadafi_application/Community/model/community_model.dart';
import 'package:hadafi_application/Community/provider.dart';

class Communityprofile extends ConsumerWidget {
  final String name;

  const Communityprofile({
    super.key,
    required this.name,
  });

  void joinCommunity(WidgetRef ref, Community community, BuildContext context) {
    ref
        .read(communityControllerProvider.notifier)
        .joinCommunity(community, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(uidProvider);

    return Scaffold(
      body: ref.watch(getCommunityByNameProvider(name)).when(
            data: (community) {
              if (community == null) {
                return const Center(
                  child: Text(
                    "Error: Community data is null",
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }

              bool isNetworkBanner = community.banner.isNotEmpty &&
                  Uri.parse(community.banner).isAbsolute;
              bool isNetworkAvatar = community.avatar.isNotEmpty &&
                  Uri.parse(community.avatar).isAbsolute;

              return Stack(
                children: [
                  NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverAppBar(
                          expandedHeight: 180,
                          floating: false,
                          pinned: true,
                          automaticallyImplyLeading: false,
                          flexibleSpace: Stack(
                            alignment: Alignment.bottomLeft,
                            children: [
                              Positioned.fill(
                                child: isNetworkBanner
                                    ? Image.network(community.banner,
                                        fit: BoxFit.cover)
                                    : Image.asset('assets/default_banner.png',
                                        fit: BoxFit.cover),
                              ),
                              Positioned.fill(
                                child: Container(
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                left: 16,
                                right: 16,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .end, // Aligns buttons lower
                                  children: [
                                    // Profile Avatar
                                    CircleAvatar(
                                      radius: 32,
                                      backgroundColor: Colors.white,
                                      child: CircleAvatar(
                                        radius: 30,
                                        backgroundImage: isNetworkAvatar
                                            ? NetworkImage(community.avatar)
                                            : const AssetImage(
                                                    'assets/default_avatar.png')
                                                as ImageProvider,
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Community Name and Member Count
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${community.name}',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            softWrap: false,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${community.members.length} members',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  Colors.white.withOpacity(1),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(
                                        width:
                                            12), // Space between text and button

                                    // Buttons (Aligned Lower)
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: community.mods.contains(user)
                                          ? ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ModTools(name: name),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.settings,
                                                  size: 18),
                                              label: const Text('Mod Tools'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Color(0xFF113F67),
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              ),
                                            )
                                          : ElevatedButton(
                                              onPressed: () => joinCommunity(
                                                  ref, community, context),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: community
                                                        .members
                                                        .contains(user)
                                                    ? Colors.grey
                                                    : Color(0xFF113F67),
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20),
                                              ),
                                              child: Text(
                                                community.members.contains(user)
                                                    ? "Joined"
                                                    : 'Join',
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ];
                    },
                    body: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "🌟 About This Community",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            community.description.length > 200
                                ? '${community.description.substring(0, 200)}...'
                                : community.description,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (community.description.length > 200)
                            TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Full Description"),
                                    content: SingleChildScrollView(
                                      child: Text(community.description),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Close"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text("Read More",
                                  style: TextStyle(color: Colors.blue)),
                            ),
                          const SizedBox(height: 10),
                          const Text(
                            "📢 Community Posts",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: ref
                                .watch(getCommunityPostsProvider(name))
                                .when(
                                  data: (data) {
                                    return ListView.builder(
                                      itemCount: data.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final post = data[index];
                                        return PostCard(post: post);
                                      },
                                    );
                                  },
                                  error: (error, stackTrace) {
                                    return Text(
                                      "Error: $error",
                                      style: const TextStyle(color: Colors.red),
                                    );
                                  },
                                  loading: () => const Loader(),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue[800]?.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 24),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              );
            },
            error: (error, stackTrace) => Center(
              child: Text(
                "Error: $error",
                style: const TextStyle(color: Colors.red),
              ),
            ),
            loading: () => const Loader(),
          ),
    );
  }
}
