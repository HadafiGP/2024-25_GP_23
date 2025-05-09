import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/constants/constants.dart';
import 'package:hadafi_application/Community/core/failure.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hadafi_application/Community/provider.dart';

final storageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

final firebaseStorageProvider = Provider(
  (ref) => StorageRepository(firebaseStorage: ref.watch(storageProvider)),
);

class StorageRepository {
  final FirebaseStorage _firebaseStorage;

  StorageRepository({required FirebaseStorage firebaseStorage})
      : _firebaseStorage = firebaseStorage;

  Future<Either<Failure, String>> storeFile({
    required String path,
    required String id,
    required File? file,
  }) async {
    try {
      final ref = _firebaseStorage.ref().child(path).child(id);

      UploadTask uploadTask = ref.putFile(file!);
      final snapshot = await uploadTask;

      return right(await snapshot.ref.getDownloadURL());
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<String> uploadImageToStorage(
      String folder, String userId, String imagePath) async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child(folder).child(userId);
      final uploadTask = storageRef.putFile(File(imagePath));
      final snapshot = await uploadTask;
      final imageUrl = await snapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return Constants.avatarDefault;
    }
  }

  Future<String> uploadFileToStorage(
      String folder, String userId, File file) async {
    try {
      final storageRef = _firebaseStorage.ref().child(folder).child(userId);
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask;
      final fileUrl = await snapshot.ref.getDownloadURL();
      return fileUrl;
    } catch (e) {
      print('Error uploading file: $e');
      return ''; 
    }
  }
}
