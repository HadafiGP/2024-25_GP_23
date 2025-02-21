import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hadafi_application/Community/firebase_constants.dart';
import 'package:hadafi_application/Community/model/community_model.dart';
import 'package:dartz/dartz.dart';
import 'package:hadafi_application/Community/core/failure.dart';
import 'package:hadafi_application/Community/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final communityRepositoryProvider= Provider((ref){
  return CommunitntyRepository(firestore: ref.watch(firestoreProvider));

});

class CommunitntyRepository {
  final FirebaseFirestore _firestore;
  CommunitntyRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<Either<Failure, void>> createCommunity(Community community) async {
    try {
      var communityDoc = await _communities.doc(community.name).get();
      if(communityDoc.exists){
 return left(Failure('Community with the same name already exists!'));
      }
      return right(_communities.doc(community.name).set(community.toMap()));
    } on FirebaseException catch (e) {
          return left(Failure(e.message ?? 'An unexpected error occurred.'));
    } catch (e) {
         return left(Failure(e.toString()));
    }
  }

Stream<List<Community>> getUserCommunities(String uid) {
  return _communities
      .where('members', arrayContains: uid)
      .snapshots() 
      .map((snapshot) { 
    List<Community> communities = [];
    for (var doc in snapshot.docs) { 
      communities.add(Community.fromMap(doc.data() as Map<String, dynamic>));
    }
    return communities;
  });
}

Future<bool> checkIfCommunityExists(String name) async {
  var communityDoc = await _firestore.collection(FirebaseConstants.communitiesCollection).doc(name).get();
  return communityDoc.exists; 
}



  CollectionReference get _communities => _firestore.collection(FirebaseConstants.communitiesCollection);
}
