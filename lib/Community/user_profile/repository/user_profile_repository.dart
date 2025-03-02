import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hadafi_application/Community/firebase_constants.dart';
import 'package:hadafi_application/Community/model/community_model.dart';
import 'package:dartz/dartz.dart';
import 'package:hadafi_application/Community/core/failure.dart';
import 'package:hadafi_application/Community/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfileRepository {
  final FirebaseFirestore _firestore;

  UserProfileRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _students =>
      _firestore.collection(FirebaseConstants.studentsCollection);

  Future<Either<Failure, Map<String, dynamic>>> getUserProfile(
      String uid) async {
    try {
      DocumentSnapshot doc = await _students.doc(uid).get();

      if (!doc.exists) {
        return Left(Failure("Student profile not found"));
      }

      return Right(doc.data() as Map<String, dynamic>);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
