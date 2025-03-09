import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/common/error_text.dart';
import 'package:hadafi_application/Community/common/loader.dart';
import 'package:hadafi_application/Community/common/post_card.dart';
import 'package:hadafi_application/Community/model/post_model.dart';
import 'package:hadafi_application/Community/post/controller/post_controller.dart';
import 'package:hadafi_application/Community/post/widgets/comment_card.dart';

class CommentsScreen extends  ConsumerStatefulWidget {
  final String postId;
  const CommentsScreen({super.key, required this.postId,});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {

final commentController = TextEditingController();

@override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }


  void addComment(Post post){
    ref.read(PostControllerProvider.notifier).addComment(context: context, text: commentController.text.trim(), post: post,);

    setState(() {
      commentController.text = '';
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ref.watch(getPostByIdProvider(widget.postId)).when(
        data: (data){
          return Column(
            
            children: [
              PostCard(post: data),
              
          TextField(
            onSubmitted: (val) => addComment(data),
            controller: commentController,
            decoration: InputDecoration(
              hintText: 'What are your thoughts?',
              filled: true,
              border: InputBorder.none
            ),
          ),

          ref.watch(getPostCommentsProvider(widget.postId)).when(
            data: (data){
              return Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int index){
                    final comment = data[index];
                    return CommentCard(comment: comment);
                  },
                  ),
              );

            }, 
            error: (error, stackTrace) {
            print("Error loading communities: $error"); // 🔍 Debugging Step
            return ErrorText(error: error.toString());
          },
          loading: () => const Loader(),
          
          ),

            ],
          );
          

      }, error: (error, stackTrace) {
            print("Error loading communities: $error"); // 🔍 Debugging Step
            return ErrorText(error: error.toString());
          },
          loading: () => const Loader(),
          ),
    );
  }
}