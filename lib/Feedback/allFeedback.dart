import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
          'Users\' Feedback',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF113F67),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF3F9FB),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
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

            return ListView.builder(
              itemCount: feedbacks.length,
              itemBuilder: (context, index) {
                final data = feedbacks[index].data() as Map<String, dynamic>;
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
                        border: Border.all(
                            color: const Color(0xFF113F67), width: 2),
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
                          // User name
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF113F67),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Star rating
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
                          const SizedBox(height: 10),

                          // Experience text
                          Text(
                            experience,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
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
    );
  }
}