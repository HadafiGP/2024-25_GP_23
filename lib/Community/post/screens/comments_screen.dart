import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/common/error_text.dart';
import 'package:hadafi_application/Community/common/loader.dart';
import 'package:hadafi_application/Community/common/post_card.dart';
import 'package:hadafi_application/Community/model/post_model.dart';
import 'package:hadafi_application/Community/post/controller/post_controller.dart';
import 'package:hadafi_application/Community/post/widgets/comment_card.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentsScreen({super.key, required this.postId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void addComment(Post post) {
    if (commentController.text.trim().isEmpty) return;
    ref.read(PostControllerProvider.notifier).addComment(
          context: context,
          text: commentController.text.trim(),
          post: post,
        );

    setState(() {
      commentController.text = '';
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: const Color(0xFF113F67),
      iconTheme: const IconThemeData(color: Colors.white),
      title: const Text(
        "Comments",
        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    ),
    body: SafeArea(
      child: Column(
        children: [
          // 
          Expanded(
            child: ref.watch(getPostByIdProvider(widget.postId)).when(
              data: (post) => Column(
                children: [
                  // 
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.only(bottom: 12),
                            children: [
                              PostCard(post: post),
                              const Divider(thickness: 1),
                              ref.watch(getPostCommentsProvider(widget.postId)).when(
                                data: (comments) => comments.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Center(child: Text("No comments yet", style: TextStyle(fontSize: 16))),
                                      )
                                    : Column(
                                        children: comments.map((c) => CommentCard(comment: c)).toList(),
                                      ),
                                loading: () => const Center(child: CircularProgressIndicator()),
                                error: (error, _) {
                                  print("Error loading comments: $error");
                                  return ErrorText(error: error.toString());
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              loading: () => const Loader(),
              error: (error, _) {
                print("Error loading post: $error");
                return ErrorText(error: error.toString());
              },
            ),
          ),

          // 
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      hintText: 'Write a comment...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF113F67)),
                  onPressed: () {
                    if (commentController.text.trim().isNotEmpty) {
                      ref.read(getPostByIdProvider(widget.postId)).whenData((post) {
                        addComment(post);
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}
