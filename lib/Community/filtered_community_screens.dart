import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/provider.dart';
import 'package:hadafi_application/Community/model/community_model.dart';
import 'package:hadafi_application/Community/CommunityProfile.dart';
import 'package:hadafi_application/Community/controller/community_controller.dart';

class FilteredCommunityScreen extends ConsumerWidget {
  final String topic;

  const FilteredCommunityScreen({Key? key, required this.topic})
      : super(key: key);

  void joinCommunity(WidgetRef ref, Community community, BuildContext context) {
    ref
        .read(communityControllerProvider.notifier)
        .joinCommunity(community, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(uidProvider);
    final communitiesAsync = ref.watch(communityProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(topic,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              // fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: const Color(0xFF113F67), 
        
      ),
      body: communitiesAsync.when(
        data: (communityList) {
       
          print(
              "Fetched communities: ${communityList.map((c) => c.name).toList()}");

     
          final filteredCommunities = communityList
              .where((community) =>
                  community.topics != null &&
                  community.topics
                      .any((t) => t.toLowerCase() == topic.toLowerCase()))
              .toList();

          if (filteredCommunities.isEmpty) {
            print("No communities found for $topic");
            return _buildNoCommunitiesFound();
          }

          return ListView.builder(
            itemCount: filteredCommunities.length,
            itemBuilder: (context, index) {
              final community = filteredCommunities[index];
              final bool isJoined = community.members.contains(user);

              return ListTile(
                leading: GestureDetector(
                  onTap: () {
             
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Communityprofile(name: community.name),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(community.avatar),
                    radius: 24,
                  ),
                ),
                title: GestureDetector(
                  onTap: () {
           
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Communityprofile(name: community.name),
                      ),
                    );
                  },
                  child: Text(community.name),
                ),
                subtitle: Text("${community.members.length} members"),
                trailing: ElevatedButton(
                  onPressed: () {
                    
                      joinCommunity(ref, community, context);
                    
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isJoined ? Colors.grey : Color(0xFF113F67),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: Text(
                    isJoined ? "Joined" : "Join",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) {
          print("Error fetching communities: $err");
          return Center(child: Text("Error: $err"));
        },
      ),
    );
  }

  Widget _buildNoCommunitiesFound() {
  return SizedBox.expand( 
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 50, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            "No communities found for $topic",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    ),
  );
}

}
