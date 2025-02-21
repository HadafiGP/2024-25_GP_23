import 'package:flutter/material.dart';
import 'package:hadafi_application/StudentHomePage.dart';
import 'createCommunity.dart';

class Communityhomescreen extends StatefulWidget {
  final int initialIndex;
  Communityhomescreen({this.initialIndex = 0}); // Default is home

  @override
  _CommunityhomescreenState createState() => _CommunityhomescreenState();
}

class _CommunityhomescreenState extends State<Communityhomescreen> {
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
            onPressed: () {},
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
