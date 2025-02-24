import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:hadafi_application/Community/CommunityProfile.dart';
import 'package:hadafi_application/Community/createCommunity.dart';
import 'package:hadafi_application/Community/delegates/search_community_delegate.dart';
import 'package:hadafi_application/Community/model/community_model.dart';
import 'package:hadafi_application/StudentHomePage.dart';


class Communityhomescreen extends ConsumerStatefulWidget { 
  final int initialIndex;
  Communityhomescreen({super.key, this.initialIndex = 0}); 

  @override
  _CommunityhomescreenState createState() => _CommunityhomescreenState();
}

class _CommunityhomescreenState extends ConsumerState<Communityhomescreen> { 
  late int index;

  @override
  void initState() {
    super.initState();
    index = widget.initialIndex;
  }

  final List<Widget> screens = [
    Center(child: Text("Home")),
    createCommunityUI(),
   
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      drawer: const HadafiDrawer(),
      appBar: AppBar(
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
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          animationDuration: Duration(milliseconds: 1250),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: "Home",
            ),
            NavigationDestination(
              icon: Icon(Icons.add_box_outlined),
              selectedIcon: Icon(Icons.add_box),
              label: "Create Community",
            ),
          ],
        ),
      ),
    );
  }
}
