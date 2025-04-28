import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hadafi_application/favoriteProvider.dart';
import 'package:hadafi_application/favoriteList.dart';

class OpportunityDetailsPage extends StatelessWidget {
  final String jobTitle;
  final String companyName;
  final String description;
  final String applyUrl;
  final double similarity;
  final List<String> skills;
  final String location;
  final double gpa5;
  final double gpa4;

  const OpportunityDetailsPage({
    super.key,
    required this.jobTitle,
    required this.companyName,
    required this.description,
    required this.applyUrl,
    required this.similarity,
    required this.skills,
    required this.location,
    required this.gpa5,
    required this.gpa4,
    required opportunityId,
  });

  @override
  Widget build(BuildContext context) {
    // Split locations
    final locationsList = location.split(',').map((loc) => loc.trim()).toList();

    // Check GPA if 0 the gpa requriments will not be displayed
    final bool hasGpa = gpa5 > 0 || gpa4 > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Company Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF113F67),
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
                      Expanded(
                        child: Text(
                          companyName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Consumer(
                          builder: (context, ref, child) {
                            final favoriteOpps = ref.watch(favoriteProvider);
                            final isFavorited = favoriteOpps.favOpportunities
                                .any((opp) => opp['Job Title'] == jobTitle);

                            return GestureDetector(
                              onTap: () {
                                final wasFavorited = isFavorited;

                                final favoriteOpp = {
                                  'Job Title': jobTitle,
                                  'Company Name': companyName,
                                  'Description': description,
                                  'Apply url': applyUrl,
                                  'GPA out of 5': gpa5,
                                  'GPA out of 4': gpa4,
                                  'Locations': location
                                      .split(',')
                                      .map((loc) => loc.trim())
                                      .toList(),
                                  'Skills': skills.isNotEmpty ? skills : [],
                                };

                                ref
                                    .read(favoriteProvider.notifier)
                                    .toggleFavorite(favoriteOpp);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      wasFavorited
                                          ? "Opportunity removed from Saved Opportunities"
                                          : "Opportunity added to Saved Opportunities",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    action: wasFavorited
                                        ? SnackBarAction(
                                            label: "Undo",
                                            textColor: Colors.white,
                                            onPressed: () {
                                              ref
                                                  .read(
                                                      favoriteProvider.notifier)
                                                  .toggleFavorite(favoriteOpp);
                                            },
                                          )
                                        : null,
                                               duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                  isFavorited
                                      ? Icons.bookmark_added
                                      : Icons.bookmark_add_outlined,
                                  color: isFavorited
                                      ? Colors.amber[400]
                                      : Colors.white,
                                  size: correctSize(context, 72),
                                  key: ValueKey<bool>(isFavorited),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // About the Company
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
            // Location
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: locationsList.length > 1
                  ? ExpansionTile(
                      title: Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Color(0xFF096499)),
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
                          const Icon(Icons.location_on,
                              color: Color(0xFF096499)),
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
            if (hasGpa) const SizedBox(height: 16),
            // GPA
            if (hasGpa)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.school,
                            color: Color(0xFF096499),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "GPA Requirements",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF096499),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (gpa5 > 0)
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.orange,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "GPA out of 5: ${gpa5.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          if (gpa4 > 0)
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.blue,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "GPA out of 4: ${gpa4.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            // Skills
            if (!hasGpa) const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                title: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline,
                        color: Color(0xFF096499)),
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
                                const Icon(Icons.circle,
                                    size: 8, color: Color(0xFF096499)),
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
            const SizedBox(height: 24),
            // Apply button
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (applyUrl.isNotEmpty &&
                      await canLaunchUrl(Uri.parse(applyUrl))) {
                    await launchUrl(Uri.parse(applyUrl));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Could not open the URL"),
                                                 duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF096499),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
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

  double correctSize(BuildContext context, double px) {
    return px / MediaQuery.of(context).devicePixelRatio;
  }
}
