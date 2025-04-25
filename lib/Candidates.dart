import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hadafi_application/CandidateDetailesPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hadafi_application/button.dart';

class CandidatesPage extends StatelessWidget {
  final String opportunityId;

  const CandidatesPage({super.key, required this.opportunityId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F9FB),
      appBar: AppBar(
        title: const Text("Candidates", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF113F67),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('opportunity')
            .doc(opportunityId)
            .collection('candidates')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No candidates have applied yet.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final candidates = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: candidates.length,
            itemBuilder: (context, index) {
              final data = candidates[index].data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Unknown';
              final email = data['email'] ?? '';
              final major = data['major'] ?? 'Unknown';
              final gpa = (data['gpa'] ?? '').toString();
              final gpaScale = (data['gpaScale'] ?? '').toString();

              final cv = data['cv'] ?? '';
              final nationality = data['nationality'] ?? 'Unknown';
              final locationList = List<String>.from(data['location'] ?? []);
              final skillsList = List<String>.from(data['skills'] ?? []);
              final profilePic = data['profilePic'] ?? '';

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 2.0, vertical: 8.0),
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
                  child: ListTile(
                    title: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: profilePic.isNotEmpty
                              ? NetworkImage(profilePic)
                              : null,
                          backgroundColor: const Color(0xFF113F67),
                          radius: 20,
                          child: profilePic.isEmpty
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF113F67),
                                ),
                                softWrap: true,
                              ),
                              Text(
                                major,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    trailing: GradientButton(
                        text: "More",
                        gradientColors: const [
                          Color(0xFF113F67),
                          Color.fromARGB(255, 105, 185, 255),
                        ],
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CandidateDetailsPage(
                                name: name,
                                email: email,
                                major: major,
                                gpa: gpa,
                                gpaScale: gpaScale,
                                nationality: nationality,
                                locationList: locationList,
                                skillsList: skillsList,
                                cv: cv,
                                profilePic: profilePic,
                              ),
                            ),
                          );
                        }),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
