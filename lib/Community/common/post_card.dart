import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hadafi_application/Community/model/post_model.dart';
import 'package:hadafi_application/Community/post/controller/post_controller.dart';
import 'package:hadafi_application/Community/provider.dart';
import 'package:hadafi_application/Community/post/screens/comments_screen.dart';
import 'package:hadafi_application/Community/user_profile/screens/user_profile_screen.dart';
import 'package:hadafi_application/Community/CommunityProfile.dart';
import 'package:hadafi_application/Community/controller/community_controller.dart';

class PostCard extends ConsumerStatefulWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  bool showFullDescription = false;
  late final Ticker _ticker;
  DateTime _lastUpdate = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scheduleNextUpdate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void toggleDescription() {
    setState(() {
      showFullDescription = !showFullDescription;
    });
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void deletePost(BuildContext context, WidgetRef ref) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete this post?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete) {
      ref
          .read(PostControllerProvider.notifier)
          .deletePost(widget.post, context);
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final post = widget.post;
    final userID = ref.watch(uidProvider) ?? '';

    if (userID.isEmpty) {
      return const Center(child: Text('User not logged in.'));
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(post.communityProfilePic),
                  radius: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Communityprofile(name: post.communityName),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${post.communityName}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '• ${timeAgo(getCreatedAtDateTime(post.createdAt))}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        child: Text(
                          '${post.username}',
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
                ref.watch(getCommunityByNameProvider(post.communityName)).when(
                      data: (community) {
                        bool isModerator = community.mods.contains(userID);
                        if (post.uid == userID || isModerator) {
                          return IconButton(
                            onPressed: () => deletePost(context, ref),
                            icon: const Icon(Icons.delete, color: Colors.red),
                          );
                        }
                        return const SizedBox();
                      },
                      loading: () => const SizedBox(),
                      error: (e, _) => const SizedBox(),
                    ),
              ],
            ),
            const SizedBox(height: 10),

            // Post Title
            Text(
              post.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            // Description
            if (post.description != null && post.description!.isNotEmpty)
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      showFullDescription || post.description!.length <= 100
                          ? post.description!
                          : "${post.description!.substring(0, 100)}...",
                      style:
                          const TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                    if (post.description!.length > 100)
                      GestureDetector(
                        onTap: toggleDescription,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            showFullDescription ? "Show Less" : "Show More",
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Image Post
            if (post.type == 'image')
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.link!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 250,
                ),
              ),

            // Link Preview
            if (post.type == 'link' &&
                post.link != null &&
                post.link!.isNotEmpty)
              GestureDetector(
                onTap: () => _launchURL(post.link!),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.link, color: Colors.blue),
                    title: Text(post.link!,
                        style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline),
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
              ),

            // Voting & Comments Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_upward,
                          color: post.upvotes.contains(userID)
                              ? Colors.blue
                              : Colors.grey),
                      onPressed: () => ref
                          .read(PostControllerProvider.notifier)
                          .upvote(post),
                    ),
                    Text(
                      post.upvotes.length - post.downvotes.length == 0
                          ? 'Vote'
                          : '${post.upvotes.length - post.downvotes.length}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_downward,
                          color: post.downvotes.contains(userID)
                              ? Colors.red
                              : Colors.grey),
                      onPressed: () => ref
                          .read(PostControllerProvider.notifier)
                          .downvote(post),
                    ),
                  ],
                ),
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.comment, color: Colors.grey),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommentsScreen(postId: post.id),
                        ),
                      ),
                    ),
                    if (post.commentCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CommentsScreen(postId: post.id),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              '${post.commentCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _scheduleNextUpdate() {
    _timer?.cancel();

    final postDate = getCreatedAtDateTime(widget.post.createdAt);
    final diff = DateTime.now().difference(postDate);

    Duration next;

    if (diff.inSeconds < 60) {
      next = const Duration(seconds: 1);
    } else if (diff.inMinutes < 60) {
      next = Duration(minutes: 1) - Duration(seconds: diff.inSeconds % 60);
    } else if (diff.inHours < 24) {
      next = Duration(hours: 1) - Duration(minutes: diff.inMinutes % 60);
    } else {
      next = Duration(days: 1) - Duration(hours: diff.inHours % 24);
    }

    _timer = Timer(next, () {
      if (mounted) {
        setState(() {});
        _scheduleNextUpdate();
      }
    });
  }
}

String timeAgo(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inSeconds < 60) return '${diff.inSeconds}s';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';

  final days = diff.inDays;
  if (days <= 7) return '${days}d';

  // More than 7 days: format as dd/mm/yyyy
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  return '$day/$month/$year';
}

DateTime getCreatedAtDateTime(dynamic timestamp) {
  if (timestamp is DateTime) return timestamp;
  return (timestamp as dynamic).toDate();
}
