import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/common/loader.dart';
import 'package:hadafi_application/Community/controller/community_controller.dart';
import 'package:hadafi_application/Community/model/community_model.dart';
import 'package:hadafi_application/Community/CommunityProfile.dart'; // Import the profile screen

class SearchCommunityDelegate extends SearchDelegate {
  final WidgetRef ref;
  SearchCommunityDelegate(this.ref);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.close),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return const SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ref.watch(searchCommunityProvider(query)).when(
        data: (communities) {
          // **Filter Communities by Name OR Description**
          final filteredCommunities = communities.where((community) =>
              community.name.toLowerCase().contains(query.toLowerCase()) ||
              (community.description?.toLowerCase().contains(query.toLowerCase()) ?? false)).toList();

          return ListView.builder(
              itemCount: filteredCommunities.length,
              itemBuilder: (BuildContext context, int index) {
                final community = filteredCommunities[index];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(community.avatar),
                  ),
                  title: RichText(
                    text: highlightQuery(
                        text: 'r/${community.name}',
                        query: query,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        highlightColor: Colors.blue),
                  ),
                  subtitle: community.description != null && community.description!.isNotEmpty
                      ? RichText(
                          text: highlightQuery(
                              text: community.description!,
                              query: query,
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                              highlightColor: Colors.blue),
                        )
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Communityprofile(name: community.name),
                      ),
                    );
                  },
                );
              });
        },
        error: (error, stackTrace) => Center(
              child: Text("Error: $error", style: const TextStyle(color: Colors.red)),
            ),
        loading: () => const Loader());
  }

  /// **Helper Function: Highlight Matching Text**
  TextSpan highlightQuery({
    required String text,
    required String query,
    required TextStyle style,
    required Color highlightColor,
  }) {
    if (query.isEmpty) return TextSpan(text: text, style: style);

    final matches = text.toLowerCase().split(query.toLowerCase());
    if (matches.length <= 1) return TextSpan(text: text, style: style);

    List<TextSpan> spans = [];
    int currentIndex = 0;

    for (var part in matches) {
      if (part.isNotEmpty) {
        spans.add(TextSpan(text: part, style: style));
      }

      if (currentIndex < matches.length - 1) {
        spans.add(TextSpan(
            text: text.substring(
                text.toLowerCase().indexOf(query.toLowerCase(), currentIndex),
                text.toLowerCase().indexOf(query.toLowerCase(), currentIndex) + query.length),
            style: style.copyWith(color: highlightColor, fontWeight: FontWeight.bold)));
      }
      currentIndex += part.length + query.length;
    }

    return TextSpan(children: spans);
  }
}
