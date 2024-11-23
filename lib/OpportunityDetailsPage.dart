import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OpportunityDetailsPage extends StatelessWidget {
  final String jobTitle;
  final String companyName;
  final String description;
  final String applyUrl;
  final double similarity;
  final List<String> skills;
  final String location;

  const OpportunityDetailsPage({
    super.key,
    required this.jobTitle,
    required this.companyName,
    required this.description,
    required this.applyUrl,
    required this.similarity,
    required this.skills,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    // Split location into a list to handle multiple locations.
    final locationsList = location.split(',').map((loc) => loc.trim()).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Company Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF096499),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF096499),
                    Color(0xFF2F83C5),
                    Color(0xFF1BAEC6),
                    Color(0xFF48C4DD),
                  ],
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
                    jobTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.business, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        companyName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // About the Company Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                title: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF096499)),
                    const SizedBox(width: 8),
                    const Text(
                      "About the Company",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF096499),
                      ),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      description,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Location Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: locationsList.length > 1
                  ? ExpansionTile(
                      title: Row(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFF096499)),
                          const SizedBox(width: 8),
                          const Text(
                            "Locations",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF096499),
                            ),
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            locationsList.join(', '),
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFF096499)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              location,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            // Skills Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                title: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Color(0xFF096499)),
                    const SizedBox(width: 8),
                    const Text(
                      "Skills Required",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF096499),
                      ),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: skills
                          .map(
                            (skill) => Row(
                              children: [
                                const Icon(Icons.circle, size: 8, color: Color(0xFF096499)), // Bullet point
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    skill,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Match Percent Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.bar_chart,
                      color: Color(0xFF096499),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Match Percent: ${(similarity * 100).toStringAsFixed(2)}%",
                        style: TextStyle(
                          fontSize: 16,
                          color: similarity >= 0.7
                              ? Colors.green
                              : similarity >= 0.5
                                  ? const Color.fromARGB(255, 233, 109, 0)
                                  : const Color.fromARGB(255, 200, 14, 1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Apply Now Button
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (applyUrl.isNotEmpty && await canLaunchUrl(Uri.parse(applyUrl))) {
                    await launchUrl(Uri.parse(applyUrl));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Could not open the URL"),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF096499),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.send, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "Apply Now",
                      style: TextStyle(color: Colors.white, fontSize: 16),
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
}
