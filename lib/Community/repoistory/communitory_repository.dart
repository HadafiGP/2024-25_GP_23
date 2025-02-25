import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hadafi_application/Community/firebase_constants.dart';
import 'package:hadafi_application/Community/model/community_model.dart';
import 'package:dartz/dartz.dart';
import 'package:hadafi_application/Community/core/failure.dart';
import 'package:hadafi_application/Community/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef FutureEitherVoid = Future<Either<Failure, void>>;

final communityRepositoryProvider = Provider((ref) {
  return CommunitntyRepository(firestore: ref.watch(firestoreProvider));
});

class CommunitntyRepository {
  final FirebaseFirestore _firestore;
  CommunitntyRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<Either<Failure, void>> createCommunity(Community community) async {
    try {
      var communityDoc = await _communities.doc(community.name).get();
      if (communityDoc.exists) {
        return left(Failure('Community with the same name already exists!'));
      }
      return right(_communities.doc(community.name).set(community.toMap()));
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? 'An unexpected error occurred.'));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  ///Join community

Future<Either<Failure, void>> joinCommunity(
    String communityName, String userID) async {
  try {
    await _communities.doc(communityName).update({
      'members': FieldValue.arrayUnion([userID])
    });
    return right(null); // right() expects a value, so use null
  } on FirebaseException catch (e) {
    return left(Failure(e.message ?? 'An unexpected error occurred.'));
  } catch (e) {
    return left(Failure(e.toString()));
  }
}


  ///Leave community
Future<Either<Failure, void>> leaveCommunity(
    String communityName, String userID) async {
  try {
    await _communities.doc(communityName).update({
      'members': FieldValue.arrayRemove([userID])
    });
    return right(null); // right() expects a value, so use null
  } on FirebaseException catch (e) {
    return left(Failure(e.message ?? 'An unexpected error occurred.'));
  } catch (e) {
    return left(Failure(e.toString()));
  }
}


  ///////////////////////////////////////////////////////////////////////////////

  Stream<List<Community>> getUserCommunities(String uid) {
    return _communities
        .where('members', arrayContains: uid)
        .snapshots()
        .map((event) {
      List<Community> communities = [];
      for (var doc in event.docs) {
        communities.add(Community.fromMap(doc.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }

  Stream<Community> getCommunityByName(String name) {
    return _communities.doc(name).snapshots().map(
        (event) => Community.fromMap(event.data() as Map<String, dynamic>));
  }

  Future<bool> checkIfCommunityExists(String name) async {
    var communityDoc = await _firestore
        .collection(FirebaseConstants.communitiesCollection)
        .doc(name)
        .get();
    return communityDoc.exists;
  }

  FutureEitherVoid editCommunity(Community community) async {
    try {
      return right(_communities.doc(community.name).update(community.toMap()));
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? 'Unknown Firebase error'));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> searchCommunity(String query) {
    if (query.isEmpty) {
      return _communities.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => Community.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      });
    }

    return _communities.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Community.fromMap(doc.data() as Map<String, dynamic>))
          .where((community) =>
              community.name.toLowerCase().contains(query.toLowerCase()) ||
              (community.description
                      ?.toLowerCase()
                      .contains(query.toLowerCase()) ??
                  false))
          .toList();
    });
  }




    FutureEitherVoid addMods(String communityName , List<String> uids) async {
    try {
      return right(_communities.doc(communityName).update({

        'mods':uids,
      }));
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? 'Unknown Firebase error'));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }


  CollectionReference get _communities =>
      _firestore.collection(FirebaseConstants.communitiesCollection);
}
