import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hadafi_application/apply_now_button.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/favoriteProvider.dart';
import 'package:hadafi_application/favoriteList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hadafi_application/favoriteProvider.dart';
import 'package:hadafi_application/favoriteList.dart';

class TpOpportunityDetailsPage extends StatelessWidget {
  final String jobTitle;
  final String companyName;
  final String description;
  final String applyUrl;
  final List<String> skills;
  final String location;
  final double gpa5;
  final double gpa4;
  final String duration;
  final String endDate;
  final String createdAt;
  final String startDate;
  final String jobType;
  final String major;
  final String contactInfo;
  final String opportunityId;

  const TpOpportunityDetailsPage({
    super.key,
    required this.jobTitle,
    required this.companyName,
    required this.description,
    required this.applyUrl,
    required this.skills,
    required this.location,
    required this.gpa5,
    required this.gpa4,
    required this.duration,
    required this.endDate,
    required this.createdAt,
    required this.startDate,
    required this.jobType,
    required this.major,
    required this.contactInfo,
    required this.opportunityId,
  });

  // put the date in a 2 apr,2025 format
  String formatDate(String date) {
    final DateFormat formatter = DateFormat('dd MMM, yyyy');
    final DateTime parsedDate = DateTime.parse(date);
    return formatter.format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    final locationsList = location.split(',').map((loc) => loc.trim()).toList();
    final bool hasGpa = gpa5 > 0 || gpa4 > 0;
    bool isApplied = false;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Opportunity Details",
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
                                  'Duration': duration,
                                  'Start Date': startDate,
                                  'End Date': endDate,
                                  'Major': major,
                                  'contactInfo': contactInfo,
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
            // Job
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.work, color: Color(0xFF096499)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        jobType,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                leading:
                    const Icon(Icons.info_outline, color: Color(0xFF096499)),
                title: const Text(
                  "Description",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF096499),
                  ),
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
            const SizedBox(height: 5),
            // Location
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF096499)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        locationsList.join(', '),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            // Major
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                leading: const Icon(Icons.school,
                    color: Color(0xFF096499)), // Icon for Major
                title: const Text(
                  "Major",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF096499),
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      major,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            // Skills
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                leading: const Icon(Icons.lightbulb_outline,
                    color: Color(0xFF096499)),
                title: const Text(
                  "Skills Required",
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
                      children: skills.map((skill) {
                        return Row(
                          children: [
                            const Icon(Icons.circle,
                                size: 8, color: Color(0xFF096499)),
                            const SizedBox(width: 8),
                            Text(
                              skill,
                              style: const TextStyle(fontSize: 16, height: 1.5),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            // GPA
            if (hasGpa)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  leading:
                      const Icon(Icons.gpp_maybe, color: Color(0xFF096499)),
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
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
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
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
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
            // date info
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                leading:
                    const Icon(Icons.calendar_today, color: Color(0xFF096499)),
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
                              "Start Date: ${(String date) {
                                final DateFormat formatter =
                                    DateFormat('dd MMM, yyyy');
                                final DateTime parsedDate =
                                    DateTime.parse(date);
                                return formatter.format(parsedDate);
                              }(startDate)}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: Color(0xFF096499), size: 16),
                            const SizedBox(width: 8),
                            Text(
                              "End Date: ${(String date) {
                                final DateFormat formatter =
                                    DateFormat('dd MMM, yyyy');
                                final DateTime parsedDate =
                                    DateTime.parse(date);
                                return formatter.format(parsedDate);
                              }(endDate)}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.timer,
                                color: Color(0xFF096499), size: 16),
                            const SizedBox(width: 8),
                            Text(
                              "Duration: $duration",
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
            // Contact Info
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.contact_mail, color: Color(0xFF096499)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        contactInfo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Company applu link
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.link, color: Color(0xFF096499)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (applyUrl.isNotEmpty &&
                              await canLaunchUrl(Uri.parse(applyUrl))) {
                            await launchUrl(Uri.parse(applyUrl));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Could not open the URL")                      , duration: Duration(seconds: 2),
        backgroundColor: Colors.red,),
                            );
                          }
                        },
                        child: Text(
                          applyUrl,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF096499),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
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
              child: ApplyNowButton(opportunityId: opportunityId),
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
