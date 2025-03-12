import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/common/loader.dart';
import 'package:hadafi_application/Community/controller/community_controller.dart';
import 'package:hadafi_application/Community/model/community_model.dart';
import 'package:hadafi_application/Community/CommunityProfile.dart';

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
    final searchResults = ref.watch(searchCommunityProvider(query));

  
    WidgetsBinding.instance.addPostFrameCallback((_) {
      query = query; 
    });

    return searchResults.when(
      data: (communities) {
        if (query.isNotEmpty && communities.isEmpty) {
          return const Center(
            child: Text(
              "No matching communities found",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: communities.length,
          itemBuilder: (BuildContext context, int index) {
            final community = communities[index];

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(community.avatar),
              ),
              title: RichText(
                text: highlightQuery(
                  text: 'r/${community.name}',
                  query: query,
                  style: const TextStyle(fontWeight: FontWeight.bold , color: Colors.grey,  fontSize: 14,),
                  highlightColor: Colors.blue, // Highlights matchingGGG IN NAME
                ),
              ),
              subtitle: community.description != null &&
                      community.description!.isNotEmpty
                  ? RichText(
                      text: highlightQuery(
                        text: community.description!,
                        query: query,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                        highlightColor: Colors
                            .blue, //Highlights matching text in description
                      ),
                    )
                  : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Communityprofile(name: community.name),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(
          child: CircularProgressIndicator()), // STOP LOADER when there is data
      error: (error, stackTrace) => Center(
        child: Text(
          "Error: $error",
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  /// **Helper Function: Highlight Matching Text in Results**
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
                text.toLowerCase().indexOf(query.toLowerCase(), currentIndex) +
                    query.length),
            style: style.copyWith(
                color: highlightColor, fontWeight: FontWeight.bold)));
      }
      currentIndex += part.length + query.length;
    }

    return TextSpan(children: spans);
  }
}
