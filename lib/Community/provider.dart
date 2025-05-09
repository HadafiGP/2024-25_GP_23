import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hadafi_application/Community/Providers/storage_repository_providers.dart';
import 'package:hadafi_application/Community/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/model/community_model.dart';
import 'package:hadafi_application/Community/repoistory/communitory_repository.dart';
import 'package:hadafi_application/favoriteProvider.dart';

// Firebase Authentication Provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  firestore.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  return firestore;
});

final userProvider = Provider<String?>((ref) {
  final uid = ref.watch(uidProvider);
  return uid;
});

final authStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

final uidProvider = StateProvider<String?>((ref) {
  final authUser = ref.watch(authStateProvider).value;
  final uid = authUser?.uid;

  if (uid != null) {
    ref.read(favoriteProvider).loadFavorites(); 
  }

  print("Auth state changed, new UID: $uid");
  return uid;
});

// Fetch User Data from Firestore
final userDataProvider =
    StreamProvider.family<Map<String, dynamic>?, String>((ref, uid) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('Student')
      .doc(uid)
      .snapshots()
      .map((doc) => doc.data());
});

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  final firebaseStorage = ref.watch(storageProvider);
  return StorageRepository(firebaseStorage: firebaseStorage);
});


//  Fetch all communities
final communityProvider = StreamProvider<List<Community>>((ref) {
  final communityRepo = ref.watch(communityRepositoryProvider);
  return communityRepo.getAllCommunities();
});