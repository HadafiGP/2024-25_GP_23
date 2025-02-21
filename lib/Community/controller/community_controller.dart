import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/model/community_model.dart';
import 'package:hadafi_application/Community/repoistory/communitory_repository.dart';
import 'package:hadafi_application/Community/provider.dart';
import 'package:hadafi_application/Community/constants/constants.dart';
import 'package:hadafi_application/Community/CommunityHomeScreen.dart';

final userCommunityProvider = StreamProvider((ref) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getUserCommunities();
});

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  final communityRepoistory = ref.watch(communityRepositoryProvider);
  return CommunityController(
      communityRepoistory: communityRepoistory, ref: ref);
});

class CommunityController extends StateNotifier<bool> {
  final CommunitntyRepository _communityRepoistory;
  final Ref _ref;
  CommunityController({
    required CommunitntyRepository communityRepoistory,
    required Ref ref,
  })  : _communityRepoistory = communityRepoistory,
        _ref = ref,
        super(false);

  void createCommunity(String name, String desciption, String Avatar,
      String Banner, List<String> topic, BuildContext context) async {
    state = true;
    final uid = _ref.read(uidProvider) ?? '';

    Community community = Community(
        id: name,
        name: name,
        description: desciption,
        avatar: Avatar,
        banner: Banner,
        topics: topic,
        members: [uid],
        mods: [uid]);

    final res = await _communityRepoistory.createCommunity(community);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, "Community created successfully!");
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Communityhomescreen(initialIndex: 1)),
        );
      },
    );
  }

  Future<bool> checkIfCommunityExists(String name) async {
    return await _communityRepoistory.checkIfCommunityExists(name);
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Stream<List<Community>> getUserCommunities() {
    final uid = _ref.read(uidProvider);
    return _communityRepoistory.getUserCommunities(uid);
  }
}
