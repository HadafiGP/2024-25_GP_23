import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ViewOpportunityPage extends StatelessWidget {
  final String opportunityId;

  const ViewOpportunityPage({super.key, required this.opportunityId});

  String _formatDate(String date) {
    final DateFormat formatter = DateFormat('dd MMM, yyyy');
    final DateTime parsedDate = DateTime.parse(date);
    return formatter.format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F9FB),
      appBar: AppBar(
        title: const Text("Opportunity Details",
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF113F67),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('opportunity')
            .doc(opportunityId)
            .get(),
        builder: (context, opportunitySnapshot) {
          if (opportunitySnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!opportunitySnapshot.hasData ||
              !opportunitySnapshot.data!.exists) {
            return const Center(child: Text("Opportunity not found"));
          }

          final opportunityData =
              opportunitySnapshot.data!.data() as Map<String, dynamic>;
          final providerUid = opportunityData['providerUid'] ?? '';

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('TrainingProvider')
                .doc(providerUid)
                .get(),
            builder: (context, providerSnapshot) {
              if (providerSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final providerData =
                  providerSnapshot.data?.data() as Map<String, dynamic>? ?? {};
              final companyName =
                  providerData['company_name'] ?? 'Unknown Company';

              final jobTitle = opportunityData['jobTitle'] ?? '';
              final description = opportunityData['description'] ?? '';
              final jobType = opportunityData['jobType'] ?? '';
              final companyLink = opportunityData['companyLink'] ?? '';
              final startDate = opportunityData['startDate'] ?? '';
              final endDate = opportunityData['endDate'] ?? '';
              final duration = opportunityData['duration'] ?? '';
              final majorData = opportunityData['major'];
              final major = majorData is List
                  ? majorData.join(', ')
                  : majorData?.toString() ?? 'Not specified';

              final skills = List<String>.from(opportunityData['skills'] ?? []);
              final locations =
                  List<String>.from(opportunityData['locations'] ?? []);
              final gpa4 = double.tryParse(
                      opportunityData['gpaOutOf4']?.toString() ?? '0') ??
                  0;
              final gpa5 = double.tryParse(
                      opportunityData['gpaOutOf5']?.toString() ?? '0') ??
                  0;
              final contactInfo =
                  opportunityData['contactInfo'] ?? 'Not provided';

              final bool hasGpa = gpa4 > 0 || gpa5 > 0;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _gradientHeader(jobTitle, companyName),
                    const SizedBox(height: 16),
                    _nonExpandableCard(
                        title: 'Job Type', content: jobType, icon: Icons.work),
                    const SizedBox(height: 5),
                    _expandableCard(
                        title: 'Description',
                        content: description,
                        icon: Icons.info_outline),
                    const SizedBox(height: 5),
                    locations.length == 1
                        ? _nonExpandableCard(
                            title: 'Location',
                            content: locations.first,
                            icon: Icons.location_pin)
                        : _expandableCard(
                            title: 'Locations',
                            content: locations.join(', '),
                            icon: Icons.location_on),
                    const SizedBox(height: 5),
                    _expandableCard(
                        title: 'Major', content: major, icon: Icons.school),
                    const SizedBox(height: 5),
                    if (skills.isNotEmpty)
                      _expandableCard(
                          title: 'Skills Required',
                          content: skills.join(', '),
                          icon: Icons.lightbulb_outline),
                    const SizedBox(height: 5),
                    if (hasGpa)
                      Card(
                        elevation: 4,
                        color: Color(0xFFF3F9FB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ExpansionTile(
                          leading: const Icon(Icons.gpp_maybe,
                              color: Color(0xFF096499)),
                          title: const Text(
                            "GPA Requirements",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF096499),
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (gpa5 > 0)
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            color: Colors.orange, size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          "GPA out of 5: ${gpa5.toStringAsFixed(2)}",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  if (gpa4 > 0)
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            color: Colors.blue, size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          "GPA out of 4: ${gpa4.toStringAsFixed(2)}",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 5),
                    Card(
                      elevation: 4,
                      color:Color(0xFFF3F9FB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        leading: const Icon(Icons.calendar_today,
                            color: Color(0xFF096499)),
                        title: const Text(
                          "Date Information",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF096499),
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        color: Color(0xFF096499), size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                        "Start Date: ${_formatDate(startDate)}",
                                        style: const TextStyle(fontSize: 16)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        color: Color(0xFF096499), size: 16),
                                    const SizedBox(width: 8),
                                    Text("End Date: ${_formatDate(endDate)}",
                                        style: const TextStyle(fontSize: 16)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.timer,
                                        color: Color(0xFF096499), size: 16),
                                    const SizedBox(width: 8),
                                    Text("Duration: $duration",
                                        style: const TextStyle(fontSize: 16)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    _nonExpandableCard(
                        title: 'Contact Info',
                        content: contactInfo,
                        icon: Icons.contact_mail),
                    const SizedBox(height: 5),
          if (companyLink.trim().isNotEmpty)
  _nonExpandableCard(
    title: 'Company Link',
    content: companyLink,
    icon: Icons.link),

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
          colors: [
            Color(0xFF096499),
            Color(0xFF2F83C5),
            Color(0xFF1BAEC6),
            Color(0xFF48C4DD)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.business, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(company,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _expandableCard(
      {required String title,
      required String content,
      required IconData icon}) {
    return Card(
      elevation: 4,
      color: Color(0xFFF3F9FB),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(icon, color: const Color(0xFF096499)),
        title: Text(
          title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF096499)),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(content,
                style: const TextStyle(fontSize: 16, height: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _nonExpandableCard(
      {required String title,
      required String content,
      required IconData icon}) {
    return Card(
      elevation: 4,
      color: Color(0xFFF3F9FB),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF096499)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(content,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
