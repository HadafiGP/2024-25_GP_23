import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/model/community_model.dart';
import 'package:hadafi_application/Community/CommunityProfile.dart';
import 'package:hadafi_application/Community/controller/community_controller.dart';
import 'package:hadafi_application/Community/provider.dart';
import 'package:hadafi_application/Community/common/loader.dart';

class FeedCommunitiesHeader extends ConsumerWidget {
  const FeedCommunitiesHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userID = ref.watch(uidProvider) ?? '';

    return ref.watch(userCommunityProvider(userID)).when(
          data: (communities) {
            if (communities.isEmpty) return const SizedBox();

            final displayCommunities = communities.take(10).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    scrollDirection: Axis.horizontal,
                    itemCount: displayCommunities.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      if (index < displayCommunities.length) {
                        final community = displayCommunities[index];
                        final isNetwork =
                            Uri.parse(community.avatar).isAbsolute;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    Communityprofile(name: community.name),
                              ),
                            );
                          },
                          child: Stack(
                            alignment: Alignment.bottomLeft,
                            children: [
                              Container(
                                width: 130,
                                height: 90,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: isNetwork
                                        ? NetworkImage(community.avatar)
                                        : FileImage(File(community.avatar))
                                            as ImageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Container(
                                width: 130,
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  community.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CommunityTabsScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            margin: const EdgeInsets.only(top: 20),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF113F67),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.arrow_forward,
                                  color: Colors.white),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Loader(),
          error: (e, _) => const SizedBox(),
        );
  }
}

class CommunityTabsScreen extends ConsumerWidget {
  const CommunityTabsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userID = ref.watch(uidProvider) ?? '';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF113F67),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Your Communities",
            style: TextStyle(color: Colors.white),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Material(
              color: Colors.white,
              child: TabBar(
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 3.0, color: Color(0xFF113F67)),
                ),
                labelColor: Color(0xFF113F67),
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: 'Moderating'),
                  Tab(text: 'Joined'),
                ],
              ),
            ),
          ),
        ),
        body: ref.watch(userCommunityProvider(userID)).when(
              data: (communities) {
                final joined = communities
                    .where((c) =>
                        c.members.contains(userID) && !c.mods.contains(userID))
                    .toList();
                final moderating =
                    communities.where((c) => c.mods.contains(userID)).toList();

                return TabBarView(
                  children: [
                    CommunityList(communities: moderating),
                    CommunityList(communities: joined),
                  ],
                );
              },
              error: (e, _) => Center(child: Text('Error: $e')),
              loading: () => const Loader(),
            ),
      ),
    );
  }
}

class CommunityList extends StatelessWidget {
  final List<Community> communities;

  const CommunityList({super.key, required this.communities});

  @override
  Widget build(BuildContext context) {
    if (communities.isEmpty) {
      return const Center(child: Text("No communities to show."));
    }

    return ListView.builder(
      itemCount: communities.length,
      itemBuilder: (context, index) {
        final community = communities[index];
        final isNetworkImage = Uri.parse(community.avatar).isAbsolute;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: isNetworkImage
                ? NetworkImage(community.avatar)
                : FileImage(File(community.avatar)) as ImageProvider,
          ),
          title: Text('r/${community.name}'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Communityprofile(name: community.name),
              ),
            );
          },
        );
      },
    );
  }
}
