import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadafi_application/EditTpPostedOpportunity.dart';
import 'package:hadafi_application/PostOpportunityPage.dart';
import 'package:hadafi_application/ViewOpportunityPage.dart';
import 'package:hadafi_application/welcome.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hadafi_application/trainingProviderProfilePage.dart';

class TrainingProviderHomePage extends StatefulWidget {
  const TrainingProviderHomePage({super.key});

  @override
  State<TrainingProviderHomePage> createState() => _TrainingProviderHomePageState();
}

class _TrainingProviderHomePageState extends State<TrainingProviderHomePage> {
  String selectedSort = 'Date (Newest First)';

  List<QueryDocumentSnapshot> sortDocs(List<QueryDocumentSnapshot> docs) {
    switch (selectedSort) {
      case 'Title (A-Z)':
        docs.sort((a, b) => (a['jobTitle'] ?? '').compareTo(b['jobTitle'] ?? ''));
        break;
      case 'Type (A-Z)':
        docs.sort((a, b) => (a['jobType'] ?? '').compareTo(b['jobType'] ?? ''));
        break;
      case 'Date (Oldest First)':
        docs.sort((a, b) => (a['createdAt'] as Timestamp).compareTo(b['createdAt'] as Timestamp));
        break;
      default:
        docs.sort((a, b) => (b['createdAt'] as Timestamp).compareTo(a['createdAt'] as Timestamp));
    }
    return docs;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF113F67),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const Center(
              child: Text(
                'Posted Opportunities',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF113F67),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Color(0xFF113F67),size: 28,),
                  tooltip: 'Sort Options',
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: const Color(0xFFF3F9FB),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'Sort Opportunities By',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF113F67),
                                ),
                              ),
                            ),
                            ListTile(
                              title: const Text('Date (Newest First)'),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() => selectedSort = 'Date (Newest First)');
                              },
                            ),
                            ListTile(
                              title: const Text('Date (Oldest First)'),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() => selectedSort = 'Date (Oldest First)');
                              },
                            ),
                            ListTile(
                              title: const Text('Title (A-Z)'),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() => selectedSort = 'Title (A-Z)');
                              },
                            ),
                            ListTile(
                              title: const Text('Type (A-Z)'),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() => selectedSort = 'Type (A-Z)');
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                )
              ],
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('opportunity')
                    .where('providerUid', isEqualTo: currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No opportunities posted yet.',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    );
                  }

                  final sortedDocs = sortDocs(snapshot.data!.docs);

                  return ListView.builder(
                    itemCount: sortedDocs.length,
                    itemBuilder: (context, index) {
                      final doc = sortedDocs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final timestamp = data['createdAt'] as Timestamp?;
                      final formattedDate = timestamp != null
                          ? "${timestamp.toDate().year}-${timestamp.toDate().month.toString().padLeft(2, '0')}-${timestamp.toDate().day.toString().padLeft(2, '0')}"
                          : 'N/A';

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['jobTitle'] ?? 'Job Title',
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 30),
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
                                  decoration: BoxDecoration(
    color: Colors.white,
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.3),
        blurRadius: 6,
        spreadRadius: 1,
        offset: Offset(0, 2),
      ),
    ],
  ),
                                  child: PopupMenuButton<String>(
                                    padding: EdgeInsets.zero,
                                    iconSize: 24,
                                    icon: const Icon(
                                      Icons.more_horiz,
                                      color: Color(0xFF113F67),
                                    ),
                                    color: const Color(0xFFF3F9FB),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 4,
                                    onSelected: (value) async {
                                      if (value == 'Preview') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ViewOpportunityPage(opportunityId: doc.id),
                                          ),
                                        );
                                      } else if (value == 'edit') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditTpPostedOpportunity(opportunityId: doc.id),
                                          ),
                                        );
                                      } else if (value == 'delete') {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (BuildContext dialogContext) {
                                            return AlertDialog(
                                              backgroundColor: const Color(0xFFF3F9FB),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 40),
                                                  const SizedBox(height: 12),
                                                  const Text(
                                                    'Are you sure you want to delete this opportunity?',
                                                    style: TextStyle(
                                                      color: Color(0xFF113F67),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  const Text(
                                                    'This action cannot be undone!',
                                                    style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 14,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 24),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      OutlinedButton(
                                                        style: OutlinedButton.styleFrom(
                                                          foregroundColor: const Color(0xFF113F67),
                                                          side: const BorderSide(color: Color(0xFF113F67)),
                                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                        ),
                                                        onPressed: () => Navigator.of(dialogContext).pop(false),
                                                        child: const Text('Cancel'),
                                                      ),
                                                      ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          foregroundColor: const Color(0xFF113F67),
                                                          backgroundColor: Colors.redAccent,
                                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                        ),
                                                        onPressed: () => Navigator.of(dialogContext).pop(true),
                                                        child: const Text('Delete'),
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
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Opportunity deleted successfully.'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    itemBuilder: (BuildContext context) => [
                                      const PopupMenuItem(
                                        value: 'Preview',
                                        child: Text('Preview', style: TextStyle(color: Color(0xFF113F67))),
                                      ),
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit', style: TextStyle(color: Color(0xFF113F67))),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
                          MaterialPageRoute(builder: (context) => const PostOpportunityPage()),
                        );
                      },
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF113F67),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add, size: 30, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
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
        color: const Color(0xFFF3F9FB),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF113F67),
              ),
              child: Image.asset('Hadafi/images/LOGO.png', fit: BoxFit.contain, height: 80),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF113F67)),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TrainingProviderProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Color(0xFF113F67)),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_mail, color: Color(0xFF113F67)),
              title: const Text('Contact us'),
              onTap: () {
                _launchEmail(context);
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
          content: Text('Logout failed. Please try again.', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

void _launchEmail(BuildContext context) async {
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

  final Uri emailUri = Uri.parse('mailto:$email?subject=$subject&body=$body');

  try {
    final bool launched = await launchUrl(
      emailUri,
      mode: LaunchMode.externalApplication, // <<< fix for Android
    );

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open email app.'),
        ),
      );
    }
  } catch (e) {
    print("Error launching email: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while trying to open email app.'),
        ),
      );
    }
  }
}
}