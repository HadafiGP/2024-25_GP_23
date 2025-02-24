import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/Providers/storage_repository_providers.dart';
import 'package:hadafi_application/Community/core/failure.dart';
import 'package:hadafi_application/Community/model/community_model.dart';
import 'package:hadafi_application/Community/repoistory/communitory_repository.dart';
import 'package:hadafi_application/Community/provider.dart';
import 'package:hadafi_application/Community/constants/constants.dart';
import 'package:hadafi_application/Community/CommunityHomeScreen.dart';
import 'package:hadafi_application/Community/model/community_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hadafi_application/Community/edit_community_screen.dart';
import 'package:hadafi_application/Community/provider.dart';


final userCommunityProvider =
    StreamProvider.family<List<Community>, String>((ref, uid) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getUserCommunities(uid);
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

final searchCommunityProvider = StreamProvider.family((ref, String query) {
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

void createCommunity(
    String name,
    String description,
    String? avatarPath,
    String? bannerPath,
    List<String> topics,
    BuildContext context) async {
  state = true;
  final uid = _ref.read(uidProvider) ?? '';

  // Upload avatar if provided
  String avatarUrl = Constants.avatarDefault;
  if (avatarPath != null && avatarPath.isNotEmpty) {
    final avatarRes = await _storageRepository.storeFile(
      path: 'communities/avatar',
      id: name,
      file: File(avatarPath),
    );
    avatarRes.fold(
      (l) => showSnackBar(context, "Failed to upload avatar: ${l.message}"),
      (r) => avatarUrl = r,
    );
  }

  // Upload banner if provided
  String bannerUrl = Constants.bannerDefault;
  if (bannerPath != null && bannerPath.isNotEmpty) {
    final bannerRes = await _storageRepository.storeFile(
      path: 'communities/banner',
      id: name,
      file: File(bannerPath),
    );
    bannerRes.fold(
      (l) => showSnackBar(context, "Failed to upload banner: ${l.message}"),
      (r) => bannerUrl = r,
    );
  }

  // Create community object
  Community community = Community(
    id: name,
    name: name,
    description: description,
    avatar: avatarUrl,
    banner: bannerUrl,
    topics: topics,
    members: [uid],
    mods: [uid],
  );

  // Save community details in Firestore
  final res = await _communityRepoistory.createCommunity(community);
  state = false;

  res.fold(
    (l) => showSnackBar(context, l.message),
    (r) {
      showSnackBar(context, "Community created successfully!");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Communityhomescreen(initialIndex: 1),
        ),
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





void joinCommunity(Community community, BuildContext context) async {
  final userId = _ref.read(userProvider);

  if (userId == null) {
    showSnackBar(context, 'User not found!');
    return;
  }

  final _communityRepository = _ref.read(communityRepositoryProvider);

  final res = community.members.contains(userId)
      ? await _communityRepository.leaveCommunity(community.name, userId)
      : await _communityRepository.joinCommunity(community.name, userId);

  res.fold(
    (l) => showSnackBar(context, l.message),
    (r) => showSnackBar(context, community.members.contains(userId) 
      ? 'Community left successfully!' 
      : 'Community joined successfully!'),
  );
}












  Stream<List<Community>> getUserCommunities(String uid) {
    if (uid.isEmpty) {
      return Stream.value([]);
    }
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
    state = true;
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
    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, "Community updated successfully!");
        Navigator.pop(context);
      },
    );
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communityRepoistory.searchCommunity(query);
  }
}