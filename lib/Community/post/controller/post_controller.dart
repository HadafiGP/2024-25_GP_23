import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/Providers/storage_repository_providers.dart';
import 'package:hadafi_application/Community/model/comment_model.dart';
import 'package:hadafi_application/Community/model/post_model.dart';
import 'package:hadafi_application/Community/post/repository/post_repository.dart';
import 'package:hadafi_application/Community/model/community_model.dart';
import 'package:hadafi_application/Community/post/screens/add_post_type_screen.dart';
import 'package:hadafi_application/Community/provider.dart';
import '../../model/community_model.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:routemaster/routemaster.dart';

final userDataProvider =
    StreamProvider.family<Map<String, dynamic>?, String>((ref, uid) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('Student')
      .doc(uid)
      .snapshots()
      .map((doc) => doc.data());
});

final PostControllerProvider =
    StateNotifierProvider<PostController, bool>((ref) {
  final postRepository = ref.watch(postRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return PostController(
    postRepository: postRepository,
    storageRepository: storageRepository,
    ref: ref,
  );
});

void showSnackBar(BuildContext context, String message,
    {bool success = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
      backgroundColor:
          success ? const Color.fromARGB(255, 0, 176, 15) : Colors.black,
    ),
  );
}

final userPostProvider =
    StreamProvider.family((ref, List<Community> communitities) {
  final PostController = ref.watch(PostControllerProvider.notifier);
  return PostController.fetchUserPosts(communitities);
});

final getPostByIdProvider = StreamProvider.family((ref, String postId) {
  final PostController = ref.watch(PostControllerProvider.notifier);
  return PostController.getPostById(postId);
});

final getPostCommentsProvider = StreamProvider.family((ref, String postId) {
  final PostController = ref.watch(PostControllerProvider.notifier);
  return PostController.fetchPostComments(postId);
});

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;

  PostController({
    required PostRepository postRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _postRepository = postRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  Future<void> sharedTextPost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required String description,
  }) async {
    state = true;
    String postId = const Uuid().v1();

    final userId = _ref.read(userProvider);
    final userDataAsync = _ref.read(userDataProvider(userId ?? ''));

    userDataAsync.when(
      data: (userData) async {
        if (userData == null) {
          showSnackBar(context, 'User data not found');
          state = false;
          return;
        }

        String userName = userData['name'] ?? 'Unknown';
        String userUid = userData['uid'] ?? '';

        final Post post = Post(
          id: postId,
          title: title,
          communityName: selectedCommunity.name,
          communityProfilePic: selectedCommunity.avatar,
          upvotes: [],
          downvotes: [],
          commentCount: 0,
          username: userName,
          uid: userUid,
          type: 'text',
          createdAt: DateTime.now(),
          awards: [],
          description: description,
        );
        final res = await _postRepository.addPost(post);
        state = false;
        res.fold((l) => showSnackBar(context, l.message), (r) {
          showSnackBar(context, 'Post successfully!', success: true);
          Navigator.pop(context);
        });
      },
      error: (error, stackTrace) {
        showSnackBar(context, 'Error retrieving user data: $error');
        state = false;
      },
      loading: () {
        print('Loading user data...');
      },
    );
  }

  Future<void> sharedLinkPost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required String link,
    required String description,
  }) async {
    state = true;
    String postId = const Uuid().v1();

    final userId = _ref.read(userProvider);
    final userDataAsync = _ref.read(userDataProvider(userId ?? ''));

    userDataAsync.when(
      data: (userData) async {
        if (userData == null) {
          showSnackBar(context, 'User data not found');
          state = false;
          return;
        }

        String userName = userData['name'] ?? 'Unknown';
        String userUid = userData['uid'] ?? '';

        final Post post = Post(
          id: postId,
          title: title,
          communityName: selectedCommunity.name,
          communityProfilePic: selectedCommunity.avatar,
          upvotes: [],
          downvotes: [],
          commentCount: 0,
          username: userName,
          uid: userUid,
          type: 'link',
          createdAt: DateTime.now(),
          awards: [],
          link: link,
          description: description,
        );

        final res = await _postRepository.addPost(post);
        state = false;
        res.fold((l) => showSnackBar(context, l.message), (r) {
          showSnackBar(context, 'Post successfully!', success: true);
          Navigator.pop(context);
        });
      },
      error: (error, stackTrace) {
        showSnackBar(context, 'Error retrieving user data: $error');
        state = false;
      },
      loading: () {
        state = true;
      },
    );
  }

  Future<void> sharedImagePost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required File? file,
    required String description,
  }) async {
    state = true;
    String postId = const Uuid().v1();

    final userId = _ref.read(userProvider);
    final userDataAsync = _ref.read(userDataProvider(userId ?? ''));

    userDataAsync.when(
      data: (userData) async {
        if (userData == null) {
          showSnackBar(context, 'User data not found');
          state = false;
          return;
        }

        String userName = userData['name'] ?? 'Unknown';
        String userUid = userData['uid'] ?? '';

        final imageRes = await _storageRepository.storeFile(
          path: 'post/${selectedCommunity.name}/$postId',
          id: postId,
          file: file,
        );

        imageRes.fold((l) => showSnackBar(context, l.message), (r) async {
          final Post post = Post(
            id: postId,
            title: title,
            communityName: selectedCommunity.name,
            communityProfilePic: selectedCommunity.avatar,
            upvotes: [],
            downvotes: [],
            commentCount: 0,
            username: userName,
            uid: userUid,
            type: 'image',
            createdAt: DateTime.now(),
            awards: [],
            link: r,
            description: description,
          );

          final res = await _postRepository.addPost(post);
          state = false;
          res.fold((l) => showSnackBar(context, l.message), (r) {
            showSnackBar(context, 'Post successfully!', success: true);
            Navigator.pop(context);
          });
        });
      },
      error: (error, stackTrace) {
        showSnackBar(context, 'Error retrieving user data: $error');
        state = false;
      },
      loading: () {
        state = true;
      },
    );
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communitities) {
    if (communitities.isNotEmpty) {
      return _postRepository.fetchUserPosts(communitities);
    }
    return Stream.value([]);
  }

  void deletePost(Post post, BuildContext context) async {
    final res = await _postRepository.deletePost(post);
    res.fold(
        (l) => null,
        (r) =>
            showSnackBar(context, 'Post deleted succesfully!', success: true));
  }

//   void upvote(Post post) async {
//   final user = _ref.read(userProvider);

//   if (user == null) {
//     print("User is not logged in!"); // Debugging message
//     return; // Exit function if user is not logged in
//   }

//   _postRepository.upvote(post, user.uid);
// }

  void upvote(Post post) async {
    final userId = _ref.read(userProvider);

    if (userId == null) {
      print("User is not logged in!"); // Debugging message (only in logs)
      return;
    }

    final userDataAsync = _ref.read(userDataProvider(userId));

    userDataAsync.when(
      data: (userData) async {
        if (userData == null) return; // No error shown to user

        String userUid = userData['uid'] ?? '';
        _postRepository.upvote(post, userUid);
      },
      error: (error, stackTrace) {
        print("Error retrieving user data: $error"); // Only logs error
      },
      loading: () {
        print('Loading user data for upvote...'); // Logs loading state
      },
    );
  }

  void downvote(Post post) async {
    final userId = _ref.read(userProvider);

    if (userId == null) {
      print("User is not logged in!"); // Debugging message (only in logs)
      return;
    }

    final userDataAsync = _ref.read(userDataProvider(userId));

    userDataAsync.when(
      data: (userData) async {
        if (userData == null) return; // No error shown to user

        String userUid = userData['uid'] ?? '';
        _postRepository.downvote(post, userUid);
      },
      error: (error, stackTrace) {
        print("Error retrieving user data: $error"); // Only logs error
      },
      loading: () {
        print('Loading user data for upvote...'); // Logs loading state
      },
    );
  }

  Stream<Post> getPostById(String postId) {
    return _postRepository.getPostById(postId);
  }

  void addComment({
    required BuildContext context,
    required String text,
    required Post post,
  }) async {
    final userId = _ref.read(userProvider);

    if (userId == null) {
      print("User is not logged in!"); // Debugging message (only in logs)
      return;
    }

    final userDataAsync = _ref.read(userDataProvider(userId));

    userDataAsync.when(
      data: (userData) async {
        if (userData == null) {
          showSnackBar(context, 'Error: User data not found!');
          return;
        }

        String username = userData['name'] ?? 'Unknown'; // ✅ Get username
        String profilePic =
            userData['profilePic'] ?? ''; // ✅ Get profile picture
        String commentId = const Uuid().v1();

        Comment comment = Comment(
          id: commentId,
          text: text,
          createdAt: DateTime.now(),
          postId: post.id,
          username: username, // ✅ Pass username
          profilePic: profilePic, // ✅ Pass profile picture
        );

        final res = await _postRepository.addComment(comment);

        res.fold(
          (l) => showSnackBar(context, l.message),
          (r) => showSnackBar(context, 'Comment added successfully!',
              success: true),
        );
      },
      error: (error, stackTrace) {
        showSnackBar(context, 'Error retrieving user data: $error');
      },
      loading: () {
        print('Loading user data for comment...');
      },
    );
  }

  Stream<List<Comment>> fetchPostComments(String postId) {
    return _postRepository.getCommentsOfPost(postId);
  }
}
