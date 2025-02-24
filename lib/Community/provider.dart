import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hadafi_application/Community/Providers/storage_repository_providers.dart';
import 'package:hadafi_application/Community/provider.dart';


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



final authStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});


final uidProvider = StateProvider<String?>((ref) {
  final authUser = ref.watch(authStateProvider).value;
  print("Auth state changed, new UID: ${authUser?.uid}"); 
  return authUser?.uid;
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

