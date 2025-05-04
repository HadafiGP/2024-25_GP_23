import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  final ScrollController _scrollController = ScrollController();
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    index = widget.initialIndex;
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isFabVisible) {
          setState(() => _isFabVisible = false);
        }
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_isFabVisible) {
          setState(() => _isFabVisible = true);
        }
      }
    });
  }

  final List<Widget> screens = [
    FeedScreen(),
    ExplorePage(),
    CreateACommunity(),
  ];

  String getUserUID() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (isIconsVisible) {
            setState(() {
              isIconsVisible = false;
            });
          }
        },
        child: index == 0
            ? NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification is UserScrollNotification) {
                    final direction = scrollNotification.direction;
                    if (direction == ScrollDirection.reverse && _isFabVisible) {
                      setState(() => _isFabVisible = false);
                    } else if (direction == ScrollDirection.forward &&
                        !_isFabVisible) {
                      setState(() => _isFabVisible = true);
                    }
                  }
                  return false;
                },
                child: FeedScreen(),
              )
            : screens[index],
      ),
      drawer: index == 2 ? null : const HadafiDrawer(),
      appBar: index == 2
          ? null
          : AppBar(
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
            NavigationDestination(
              icon: Icon(Icons.add_outlined),
              selectedIcon: Icon(Icons.add),
              label: "Create",
            ),
          ],
        ),
      ),
      floatingActionButton: index == 0 && _isFabVisible ? buildFABIcon() : null,
    );
  }

  Widget buildFABIcon() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          bottom: 5,
          right: 20,
          child: GestureDetector(
            onTap: () {
              setState(() {
                isIconsVisible = !isIconsVisible;
              });
            },
            child: AnimatedActionButton(
              icon: Icons.add,
              onPressed: () {
                setState(() {
                  isIconsVisible = !isIconsVisible;
                });
              },
            ),
          ),
        ),
        if (isIconsVisible)
          Positioned(
            bottom: 90,
            right: 18,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddPostTypeScreen(type: 'image'),
                      ),
                    );
                  },
                  child: Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: const [
                          Color(0xFF113F67),
                          Color.fromARGB(255, 105, 185, 255),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Image',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                  child: Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: const [
                          Color(0xFF113F67),
                          Color.fromARGB(255, 105, 185, 255),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Text',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                  child: Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: const [
                          Color(0xFF113F67),
                          Color.fromARGB(255, 105, 185, 255),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Link',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class AnimatedActionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const AnimatedActionButton({
    Key? key,
    required this.onPressed,
    required this.icon,
  }) : super(key: key);

  @override
  _AnimatedActionButtonState createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<AnimatedActionButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.9;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });
    widget.onPressed();
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: const [
                Color(0xFF113F67),
                Color.fromARGB(255, 105, 185, 255),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              'Post',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
