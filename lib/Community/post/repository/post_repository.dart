import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/core/failure.dart';
import 'package:hadafi_application/Community/firebase_constants.dart';
import 'package:hadafi_application/Community/model/community_model.dart';
import 'package:hadafi_application/Community/provider.dart';
import 'package:hadafi_application/Community/repoistory/communitory_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadafi_application/Community/model/post_model.dart';

final postRepositoryProvider = Provider((ref) {
  return PostRepository(
    firestore: ref.watch(firestoreProvider),
  );
});

class PostRepository {
  final FirebaseFirestore _firestore;
  PostRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postCollection);

  Future<Either<Failure, void>> addPost(Post post) async {
    try {
      return right(_posts.doc(post.id).set(post.toMap()));
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? 'An unexpected error occurred.'));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    return _posts
        .where('communityName',
            whereIn: communities.map((e) => e.name).toList())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs.map((e) {
            final data = e.data() as Map<String, dynamic>;
            return Post.fromMap({
              ...data,
              'createdAt': (data['createdAt'] as Timestamp)
                  .toDate(), // ✅ Convert Firestore Timestamp to DateTime
            });
          }).toList(),
        );
  }

  // FutureVoid deletePost(Post post) async {
  //   try{

  //     return right(_posts.doc(post.id).delete());

  //   } on FirebaseException catch(e) {
  //     throw e.message! ;
  //   } catch(e) {
  //     return left(Failure(e.toString()));
  //   }
  // }

// delete post function
  Future<Either<Failure, void>> deletePost(Post post) async {
  try {
    await _posts.doc(post.id).delete();
    return right(null);
  } on FirebaseException catch (e) {
    return left(Failure(e.message!));
  } catch (e) {
    return left(Failure(e.toString()));
  }
}

void upvote(Post post, String userId) async {
  if (post.downvotes.contains(userId)){
    _posts.doc(post.id).update({
      'downvotes' : FieldValue.arrayRemove([userId]),
    });
  }

  if (post.upvotes.contains(userId)){
    _posts.doc(post.id).update({
      'upvotes' : FieldValue.arrayRemove([userId]),
    });
  } else {
    _posts.doc(post.id).update({
      'upvotes' : FieldValue.arrayUnion([userId]),
    });
  }
}

void downvote(Post post, String userId) async {
  if (post.upvotes.contains(userId)){
    _posts.doc(post.id).update({
      'upvotes' : FieldValue.arrayRemove([userId]),
    });
  }

  if (post.downvotes.contains(userId)){
    _posts.doc(post.id).update({
      'downvotes' : FieldValue.arrayRemove([userId]),
    });
  } else {
    _posts.doc(post.id).update({
      'downvotes' : FieldValue.arrayUnion([userId]),
    });
  }
}



}
