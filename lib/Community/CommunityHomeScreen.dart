import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/CommunityProfile.dart';
import 'package:hadafi_application/Community/addCommunity.dart';
import 'package:hadafi_application/Community/createCommunity.dart';
import 'package:hadafi_application/Community/delegates/search_community_delegate.dart';
import 'package:hadafi_application/Community/explore_page.dart';
import 'package:hadafi_application/Community/model/community_model.dart';
import 'package:hadafi_application/Community/post/screens/add_post_type_screen.dart';
import 'package:hadafi_application/Community/post/screens/communityHeader.dart';
import 'package:hadafi_application/StudentHomePage.dart';
import 'package:hadafi_application/Community/CommunityProfile.dart';
import 'package:hadafi_application/Community/user_profile/screens/user_profile_screen.dart';
import 'package:hadafi_application/Community/post/screens/add_post_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadafi_application/Community/post/screens/feed_screen.dart';

class Communityhomescreen extends ConsumerStatefulWidget {
  final int initialIndex;
  Communityhomescreen({super.key, this.initialIndex = 0});

  @override
  _CommunityhomescreenState createState() => _CommunityhomescreenState();
}

class _CommunityhomescreenState extends ConsumerState<Communityhomescreen> {
  late int index;
  bool isIconsVisible = false;

  @override
  void initState() {
    super.initState();
    index = widget.initialIndex;
  }

  final List<Widget> screens = [
    FeedScreen(),
    ExplorePage(),
    AddPostScreen(),
  ];

  String getUserUID() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      drawer: const HadafiDrawer(),
      appBar: AppBar(
        title: const Text(
          'Communities',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF113F67),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: SearchCommunityDelegate(ref),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddCommunityScreen(),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Colors.white,
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        child: NavigationBar(
          height: 65,
          backgroundColor: const Color.fromARGB(255, 214, 230, 243),
          selectedIndex: index,
          onDestinationSelected: (newIndex) => setState(() => index = newIndex),
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          animationDuration: Duration(milliseconds: 1250),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: "Home",
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: "Explore",
            ),

            //    NavigationDestination(
            //    icon: Icon(Icons.post_add_outlined),
            //    selectedIcon: Icon(Icons.post_add),
            //   label: "Post",
            //       ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main floating action button
          Positioned(
            bottom: 5,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  isIconsVisible =
                      !isIconsVisible; // Toggle visibility of icons
                });
              },
              child: const Icon(
                Icons.add,
                size: 35,
                color: Colors.white,
              ),
              backgroundColor: const Color(0xFF113F67),
            ),
          ),
          // Floating action icons that appear when the main button is pressed
          if (isIconsVisible)
            Positioned(
              bottom: 90,
              right: 12,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddPostTypeScreen(type: 'image'),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFF113F67),
                      child: Icon(
                        Icons.image_outlined,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddPostTypeScreen(type: 'text'),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFF113F67),
                      child: Icon(
                        Icons.font_download_outlined,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddPostTypeScreen(type: 'link'),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFF113F67),
                      child: Icon(
                        Icons.link_outlined,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
