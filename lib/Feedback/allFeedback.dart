import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hadafi_application/Feedback/feedback.dart';
import 'package:hadafi_application/PostOpportunityPage.dart';
import 'package:hadafi_application/StudentHomePage.dart';

class AllFeedbackScreen extends StatefulWidget {
  const AllFeedbackScreen({super.key});

  @override
  State<AllFeedbackScreen> createState() => _AllFeedbackScreenState();
}

class _AllFeedbackScreenState extends State<AllFeedbackScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'App Feedback',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF113F67),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: HadafiDrawer(),
      backgroundColor: const Color(0xFFF3F9FB),
      body: Stack(
        children: [
          // Fetch Ratings
          Padding(
            padding: const EdgeInsets.fromLTRB(
                12, 12, 12, 80), 
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Feedback')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No feedback is found."));
                }

                final feedbacks = snapshot.data!.docs;
              //DIsplay Ratings
                return ListView.builder(
                  itemCount: feedbacks.length,
                  itemBuilder: (context, index) {
                    final data =
                        feedbacks[index].data() as Map<String, dynamic>;
                    final uid = data['uid'];
                    final experience = data['experience'] ?? '';
                    final rating = data['rating'] ?? 0;

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('Student')
                          .doc(uid)
                          .get(),
                      builder: (context, userSnapshot) {
                        final name = (userSnapshot.data?.data()
                                as Map<String, dynamic>?)?['name'] ??
                            'User';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF113F67),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: List.generate(5, (i) {
                                  return Icon(
                                    Icons.star,
                                    size: 18,
                                    color: i < rating
                                        ? Colors.amber[700]
                                        : Colors.grey[300],
                                  );
                                }),
                              ),
                              if (experience.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(
                                  experience,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Button
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeedbackScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF113F67),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                 
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Write Feedback",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),

              
                  Positioned(
                    left: 65,
                    bottom: 3,
                    child:Transform(alignment: Alignment.center, transform: Matrix4.rotationY(3.1416),child:Icon(Icons.chat_bubble, color: Colors.white, size: 22),), 
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
