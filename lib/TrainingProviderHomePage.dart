import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadafi_application/EditTpPostedOpportunity.dart';
import 'package:hadafi_application/PostOpportunityPage.dart';
import 'package:hadafi_application/ViewOpportunityPage.dart';
import 'package:hadafi_application/welcome.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hadafi_application/trainingProviderProfilePage.dart';

class TrainingProviderHomePage extends StatelessWidget {
  const TrainingProviderHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Color(0xFFF3F9FB),
      appBar: AppBar(
        backgroundColor: Color(0xFF113F67),
        iconTheme: IconThemeData(color: Colors.white),
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
          children: <Widget>[
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
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('opportunity')
                    .where('providerUid', isEqualTo: currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No opportunities posted yet.',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      // Header bar
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 12.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F9FB),
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFF113F67).withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Opportunity Title',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF113F67),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Posted At',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF113F67),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),
                      // The list of posts
                      Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final doc = snapshot.data!.docs[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final timestamp = data['createdAt'] as Timestamp?;
                            final formattedDate = timestamp != null
                                ? "${timestamp.toDate().year}-${timestamp.toDate().month.toString().padLeft(2, '0')}-${timestamp.toDate().day.toString().padLeft(2, '0')}"
                                : 'N/A';

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0, vertical: 8.0),
                              child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(16.0),
                                  child: Stack(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  data['jobTitle'] ??
                                                      'Job Title',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF113F67),
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  data['jobType'] ?? 'Job Type',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(
                                                    height:
                                                        30), // aligns with jobType
                                                Text(
                                                  formattedDate,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(
                                              0), // smaller box
                                          decoration: BoxDecoration(
                                            color: Colors
                                                .white, // matches your card background
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(
                                                    0.3), // subtle shadow
                                                spreadRadius: 1,
                                                blurRadius: 6,
                                                offset: Offset(
                                                    0, 2), // vertical shadow
                                              ),
                                            ],
                                          ),

                                          child: PopupMenuButton<String>(
                                            padding: EdgeInsets.zero,
                                            iconSize: 24,
                                            icon: const Icon(
                                              Icons.more_horiz,
                                              color: Color(
                                                  0xFF113F67), // Matches title color
                                            ),
                                            color: Color(
                                                0xFFF3F9FB), // Light menu background
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            elevation: 4, // Soft shadow
                                            onSelected: (value) async {
                                              if (value == 'Preview') {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ViewOpportunityPage(
                                                            opportunityId:
                                                                doc.id),
                                                  ),
                                                );
                                              } else if (value == 'edit') {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditTpPostedOpportunity(
                                                            opportunityId:
                                                                doc.id),
                                                  ),
                                                );
                                              } else if (value == 'delete') {
                                                final confirmed =
                                                    await showDialog<bool>(
                                                  context: context,
                                                  builder: (BuildContext
                                                      dialogContext) {
                                                    return AlertDialog(
                                                      backgroundColor:
                                                          const Color(
                                                              0xFFF3F9FB),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 24,
                                                              vertical: 20),
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          const Icon(
                                                              Icons
                                                                  .warning_amber_rounded,
                                                              color: Colors
                                                                  .redAccent,
                                                              size: 40),
                                                          const SizedBox(
                                                              height: 12),
                                                          const Text(
                                                            'Are you sure you want to delete this opportunity?',
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xFF113F67),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 18,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          const Text(
                                                            'This action cannot be undone!',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .black54,
                                                              fontSize: 14,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                          const SizedBox(
                                                              height: 24),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              OutlinedButton(
                                                                style: OutlinedButton
                                                                    .styleFrom(
                                                                  foregroundColor:
                                                                      Color(
                                                                          0xFF113F67),
                                                                  side: const BorderSide(
                                                                      color: Color(
                                                                          0xFF113F67)),
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          20,
                                                                      vertical:
                                                                          10),
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8)),
                                                                ),
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                            dialogContext)
                                                                        .pop(
                                                                            false),
                                                                child: const Text(
                                                                    'Cancel'),
                                                              ),
                                                              ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  foregroundColor:
                                                                      Color(
                                                                          0xFF113F67),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .redAccent,
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          24,
                                                                      vertical:
                                                                          10),
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8)),
                                                                ),
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                            dialogContext)
                                                                        .pop(
                                                                            true),
                                                                child: const Text(
                                                                    'Delete'),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );

                                                if (confirmed == true) {
                                                  await doc.reference.delete();
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Opportunity deleted successfully.'),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );
                                                }
                                              }
                                            },

                                            itemBuilder:
                                                (BuildContext context) => [
                                              PopupMenuItem(
                                                value: 'Preview',
                                                child: Text(
                                                  'Preview',
                                                  style: TextStyle(
                                                      color: Color(0xFF113F67)),
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'edit',
                                                child: Text(
                                                  'Edit',
                                                  style: TextStyle(
                                                      color: Color(0xFF113F67)),
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'delete',
                                                child: Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                      color: Colors.redAccent),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                            );
                          },
                        ),
                      ),
                    ],
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const PostOpportunityPage()),
                        );
                      },
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
                        child: Icon(Icons.add, size: 30, color: Colors.white),
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
                      builder: (context) => TrainingProviderProfilePage()),
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
                Navigator.pop(context);
                _logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

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
