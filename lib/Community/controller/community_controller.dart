import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/Providers/storage_repository_providers.dart';
import 'package:hadafi_application/Community/model/community_model.dart';
import 'package:hadafi_application/Community/repoistory/communitory_repository.dart';
import 'package:hadafi_application/Community/provider.dart';
import 'package:hadafi_application/Community/constants/constants.dart';
import 'package:hadafi_application/Community/CommunityHomeScreen.dart';
import 'package:hadafi_application/Community/model/community_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hadafi_application/Community/edit_community_screen.dart';
import 'package:hadafi_application/Community/provider.dart';

final userCommunityProvider = StreamProvider((ref) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getUserCommunities();
});

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  final communityRepoistory = ref.watch(communityRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return CommunityController(
      communityRepoistory: communityRepoistory,
      storageRepository: storageRepository,
      ref: ref);
});

final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  return ref
      .watch(communityControllerProvider.notifier)
      .getCommunityByName(name);
});

final searchCommunityProvider = StreamProvider.family( (ref , String query) {
  return ref.watch(communityControllerProvider.notifier).searchCommunity(query);


});


class CommunityController extends StateNotifier<bool> {
  final CommunitntyRepository _communityRepoistory;
  final Ref _ref;
  final StorageRepository _storageRepository;
  CommunityController({
    required CommunitntyRepository communityRepoistory,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _communityRepoistory = communityRepoistory,
        _ref = ref,
        _storageRepository = storageRepository,
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

  Stream<Community> getCommunityByName(String name) {
    return _communityRepoistory.getCommunityByName(name);
  }

void editCommunity({
  required File? profileFile,
  required File? bannerFile,
  required BuildContext context,
  required Community community,
}) async {
  state=true;
  if (profileFile != null) {
    final res = await _storageRepository.storeFile(
        path: 'communities/profile', id: community.name, file: profileFile);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => community = community.copyWith(avatar: r),
    );
  }

  if (bannerFile != null) {
    final res = await _storageRepository.storeFile(
        path: 'communities/banner', id: community.name, file: bannerFile);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => community = community.copyWith(banner: r),
    );
  }

  final res = await _communityRepoistory.editCommunity(community);
  state=false;

  res.fold(
    (l) => showSnackBar(context, l.message), 
    (r) {
      showSnackBar(context, "Community updated successfully!"); 
      Navigator.pop(context); 
    },
  );
}

Stream<List<Community>> searchCommunity(String query){

return _communityRepoistory.searchCommunity(query);
  
}



  }

