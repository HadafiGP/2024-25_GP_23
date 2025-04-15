import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewOpportunityPage extends StatelessWidget {
  final String opportunityId;

  const ViewOpportunityPage({super.key, required this.opportunityId});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Color(0xFFF3F9FB),
      appBar: AppBar(
        title: const Text("Opportunity Details", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF113F67),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('opportunity').doc(opportunityId).get(),
        builder: (context, opportunitySnapshot) {
          if (opportunitySnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!opportunitySnapshot.hasData || !opportunitySnapshot.data!.exists) {
            return const Center(child: Text("Opportunity not found"));
          }

          final opportunityData = opportunitySnapshot.data!.data() as Map<String, dynamic>;
          final providerUid = opportunityData['providerUid'] ?? '';

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('TrainingProvider').doc(providerUid).get(),
            builder: (context, providerSnapshot) {
              if (providerSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final providerData = providerSnapshot.data?.data() as Map<String, dynamic>? ?? {};
              final companyName = providerData['company_name'] ?? 'Unknown Company';

              final jobTitle = opportunityData['jobTitle'] ?? '';
              final description = opportunityData['description'] ?? '';
              final jobType = opportunityData['jobType'] ?? '';
              final createdAt = opportunityData['createdAt'] != null
                  ? (opportunityData['createdAt'] as Timestamp).toDate()
                  : null;
              final companyLink = opportunityData['companyLink'] ?? '';
              final startDate = opportunityData['startDate'] ?? '';
              final endDate = opportunityData['endDate'] ?? '';
              final duration = opportunityData['duration'] ?? '';
              final major = opportunityData['major'] ?? '';
              final skills = List<String>.from(opportunityData['skills'] ?? []);
              final locations = List<String>.from(opportunityData['locations'] ?? []);
              final gpa4 = double.tryParse(opportunityData['gpaOutOf4']?.toString() ?? '0') ?? 0;
              final gpa5 = double.tryParse(opportunityData['gpaOutOf5']?.toString() ?? '0') ?? 0;
              final contactInfo = opportunityData['contactInfo'] ?? 'Not provided';

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _gradientHeader(jobTitle, companyName),
                    const SizedBox(height: 16),
                    _nonExpandableCard(
  title: 'Job Type',
  content: jobType,
  icon: Icons.work_outline, // Adding work icon
)
,                                      locations.length == 1
                        ? _nonExpandableCard(title: 'Location', content: locations.first,icon: Icons.location_pin)
                        : _expandableCard(title: 'Locations', content: locations.join(', '), icon: Icons.location_on),
                    _expandableCard(title: 'Description', content: description, icon: Icons.info_outline),
  

                    if (createdAt != null)
                      _expandableCard(
                        title: 'Start Date',
                        content: _formatDate(DateTime.parse(startDate)),
                        icon: Icons.event,
                      ),
                    if (endDate.isNotEmpty)
                      _expandableCard(
                        title: 'End Date',
                        content: _formatDate(DateTime.parse(endDate)),
                        icon: Icons.event_busy,
                      ),
                    _expandableCard(title: 'Duration', content: duration, icon: Icons.timer),
                    _expandableCard(title: 'Major', content: major, icon: Icons.school_outlined),
                    if (gpa4 > 0 || gpa5 > 0)
                      _expandableCard(
                        title: 'GPA Requirements',
                        content: 'GPA out of 4 : $gpa4\nGPA out of 5 : $gpa5',
                        icon: Icons.grade,
                      ),
                    if (skills.isNotEmpty)
                      _expandableCard(title: 'Skills Required', content: skills.join(', '), icon: Icons.lightbulb_outline),
                    _expandableCard(title: 'Contact Info', content: contactInfo, icon: Icons.contact_mail),
                    const SizedBox(height: 24),
                    if (companyLink.isNotEmpty)
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final uri = Uri.parse(companyLink);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          },
                          icon: const Icon(Icons.send, color: Colors.white),
                          label: const Text(
                            "Apply Now",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF096499),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 6,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _gradientHeader(String title, String company) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF096499), Color(0xFF2F83C5), Color(0xFF1BAEC6), Color(0xFF48C4DD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.business, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  company,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _expandableCard({required String title, required String content, required IconData icon}) {
    return Card(
      elevation: 2,
      color: const Color(0xFFF3F9FB),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(icon, color: const Color(0xFF096499), size: 24,),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF096499),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              content,
              style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

Widget _nonExpandableCard({required String title, required String content, required IconData icon}) {
  return Card(
    elevation: 2,
    color: const Color(0xFFF3F9FB),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF096499), size: 24,),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              content,
              style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
            ),
          ),
        ],
      ),
    ),
  );
}



  String _formatDate(DateTime date) {
    return "${_monthName(date.month)} ${date.day}, ${date.year}";
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}