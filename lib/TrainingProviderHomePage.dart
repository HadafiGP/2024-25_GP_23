import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadafi_application/training_provider_profile.dart';
import 'package:hadafi_application/welcome.dart';
import 'package:url_launcher/url_launcher.dart';

class TrainingProviderHomePage extends StatelessWidget {
  const TrainingProviderHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F9FB), // Softer background color
      appBar: AppBar(
        backgroundColor: Color(0xFF113F67),
        iconTheme: IconThemeData(color: Colors.white), // White menu button
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Center the title
            Center(
              child: Text(
                'Posted Opportunities',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF113F67),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Example number of posted opportunities
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFF113F67), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          'Opportunity ${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF113F67),
                          ),
                        ),
                        subtitle: Text(
                          'Details about opportunity ${index + 1}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Deleted Opportunity ${index + 1}'),
                            ));
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () {},
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF113F67),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.add,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Post New Opportunity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF113F67),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color(0xFFF3F9FB),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF113F67),
              ),
              child: Image.asset(
                'Hadafi/images/LOGO.png',
                fit: BoxFit.contain,
                height: 80,
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: Color(0xFF113F67)),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProviderProfilePage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.home, color: Color(0xFF113F67)),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_mail, color: Color(0xFF113F67)),
              title: const Text('Contact us'),
              onTap: () {
                _launchEmail();
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Color(0xFF113F67)),
              title: Text('Log Out'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                _logout(context); // Call the logout function
              },
            ),
          ],
        ),
      ),
    );
  }

  // Logout method to handle signing out
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase

      // Navigate to WelcomeScreen and clear the navigation stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false, // Remove all previous routes
      );
    } catch (e) {
      // Show error if logout fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Logout failed. Please try again.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _launchEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print("User is not logged in.");
        return;
      }

      final String userId = user.uid;

      final String email = 'Hadafi.GP@gmail.com';
      final String subject =
          Uri.encodeComponent('App Support - User ID: $userId');
      final String body = Uri.encodeComponent(
          'Dear Admin, I encountered the following issues:');

      final String emailUrl = 'mailto:$email?subject=$subject&body=$body';

      if (await canLaunchUrl(Uri.parse(emailUrl))) {
        await launchUrl(Uri.parse(emailUrl));
      } else {
        throw 'Could not launch email client';
      }
    } catch (e) {
      print("An error occurred while launching the email: $e");
    }
  }
}
