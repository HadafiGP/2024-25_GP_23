import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadafi_application/interview.dart';
import 'package:hadafi_application/student_profile.dart';
import 'package:hadafi_application/welcome.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "package:hadafi_application/OpportunityDetailsPage.dart";

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentHomePage();
  }
}

class HadafiDrawer extends StatelessWidget {
  const HadafiDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFFF3F9FB),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF113F67),
              ),
              child: Image.asset(
                'Hadafi/images/LOGO.png',
                fit: BoxFit.contain,
                height: 80,
              ),
            ),
            _buildDrawerItem(
                context, Icons.person, 'Profile', const ProfilePage()),
            _buildDrawerItem(
                context, Icons.home, 'Home', const StudentHomePage()),
            _buildDrawerItem(
                context, Icons.assignment, 'CV Enhancement Tool', null),
            _buildDrawerItem(
              context,
              Icons.chat,
              'Interview Simulator',
              const InterviewPage(),
            ),
            _buildDrawerItem(context, Icons.feedback, 'Feedback', null),
            _buildDrawerItem(context, Icons.group, 'Communities', null),
            _buildDrawerItem(context, Icons.favorite, 'Favorites List', null),
            ListTile(
              leading: const Icon(Icons.contact_mail, color: Color(0xFF113F67)),
              title: const Text('Contact us'),
              onTap: () {
                _launchEmail(); 
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFF113F67)),
              title: const Text('Log Out'),
              onTap: () {
                Navigator.pop(context); 
                _logout(context); 
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, IconData icon, String title, Widget? page) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF113F67)),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); 
        if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        }
      },
    );
  }

  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'Hadafi.GP@gmail.com',
      query:
          'subject=App Support&body=Dear Admin, I encountered the following issues:',
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        throw 'Could not launch email client';
      }
    } catch (e) {
      print(e);
    }
  }
}

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  _StudentHomePageState createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  List<dynamic> recommendations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecommendations();
  }

  Future<void> fetchRecommendations() async {
    final String url = "http://10.0.2.2:5000/recommend";

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print("User is not logged in.");
        return;
      }

      final String? firebaseToken = await user.getIdToken();

      if (firebaseToken == null) {
        print("Failed to retrieve Firebase token.");
        return;
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $firebaseToken",
        },
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            recommendations = data['recommendations'];
          });
        }
      } else {
        print(
            "Failed to fetch recommendations. Status code: ${response.statusCode}");
        print("Error message: ${response.body}");
      }
    } catch (e) {
      print("An error occurred: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F9FB),
      drawer: const HadafiDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF113F67),
        actions: [
          Padding(
            padding: const EdgeInsets.all(1),
            child: Image.asset(
              'Hadafi/images/LOGO.png',
              fit: BoxFit.contain,
              height: 300,
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildSectionTitle('Training Opportunities'),
                  _buildOpportunitiesTab(),
                  _buildSectionTitle('Feedback from Users'),
                  _buildFeedbackList(),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF113F67),
          ),
        ),
      ),
    );
  }

  Widget _buildOpportunitiesTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: SizedBox(
        height: 490,
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const TabBar(
                labelColor: Color(0xFF113F67),
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color(0xFF113F67),
                tabs: [
                  Tab(text: 'Best Match'),
                  Tab(text: 'Other'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    OpportunitiesList(
                      title: 'Best Match Opportunities',
                      opportunities: recommendations,
                    ),
                    OpportunitiesList(
                        title: 'Other Opportunities', opportunities: []),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackList() {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 200,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF113F67), width: 2),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 5, spreadRadius: 2),
              ],
            ),
            child: ListTile(
              title: Text('User ${index + 1}'),
              subtitle:
                  const Text('This app helped me find a great internship!'),
            ),
          );
        },
      ),
    );
  }
}

class OpportunitiesList extends StatelessWidget {
  final String title;
  final List<dynamic> opportunities;

  const OpportunitiesList(
      {super.key, required this.title, required this.opportunities});

  @override
  Widget build(BuildContext context) {
    if (opportunities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No opportunities available at the moment.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: opportunities.length,
      itemBuilder: (context, index) {
        final opportunity = opportunities[index];

        final jobTitle = opportunity['Job Title'] ?? "Unknown Title";
        final companyName = opportunity['Company Name'] ?? "Unknown Company";
        final description =
            opportunity['Description'] ?? "No description available.";
        final applyUrl = opportunity['Apply url'] ?? "";
        final similarity = opportunity['Total Similarity'] ?? 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF113F67), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ListTile(
              title: Text(
                jobTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF113F67),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(companyName),
                  const SizedBox(height: 5),
                  Text(
                    "Match Percent: ${(similarity * 100).toStringAsFixed(2)}%",
                    style: TextStyle(
                      color: similarity >= 0.7
                          ? Colors.green
                          : similarity >= 0.5
                              ? const Color.fromARGB(255, 233, 109, 0)
                              : const Color.fromARGB(255, 200, 14, 1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.more),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OpportunityDetailsPage(
                        jobTitle: jobTitle,
                        companyName: companyName,
                        description: description,
                        applyUrl: applyUrl,
                        similarity: opportunity['Total Similarity'] ?? 0.0,
                        skills: List<String>.from(opportunity['Skills'] ?? []),
                        location: (opportunity['Locations'] ?? []).join(', '),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

// Logout method
Future<void> _logout(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (route) => false,
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logout failed. Please try again.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
