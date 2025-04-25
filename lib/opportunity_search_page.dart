import 'package:flutter/material.dart';
import 'package:hadafi_application/OpportunityDetailsPage.dart';
import 'package:hadafi_application/TpOpportunityDetailsPage.dart';
import 'package:hadafi_application/button.dart';

class OpportunitySearchPage extends StatefulWidget {
  final List<dynamic> opportunities;
  final int selectedIndex;

  const OpportunitySearchPage({
    super.key,
    required this.opportunities,
    required this.selectedIndex,
  });

  @override
  State<OpportunitySearchPage> createState() => _OpportunitySearchPageState();
}

class _OpportunitySearchPageState extends State<OpportunitySearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> filteredResults = [];

  @override
  void initState() {
    super.initState();
    filteredResults = widget.opportunities;
    _searchController.addListener(_filterList);
  }

  void _filterList() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      filteredResults = widget.opportunities.where((item) {
        final isCsvSource = widget.selectedIndex == 0;

        final title = isCsvSource
            ? (item['Job Title'] ?? '').toLowerCase()
            : (item['jobTitle'] ?? '').toLowerCase();

        final company = isCsvSource
            ? (item['Company Name'] ?? '').toLowerCase()
            : (item['companyName'] ?? '').toLowerCase();

        final locations =
            isCsvSource ? (item['Locations'] ?? []) : (item['locations'] ?? []);
        final locationString = locations.join(', ').toLowerCase();

        final jobType = isCsvSource
            ? ''
            : (item['jobType'] ?? '')
                .toLowerCase(); // only for Hadafi opportunities

        return title.contains(query) ||
            company.contains(query) ||
            locationString.contains(query) ||
            (!isCsvSource &&
                jobType.contains(query)); // filter jobType only for Hadafi
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = widget.selectedIndex;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF113F67),
        iconTheme: const IconThemeData(color: Colors.white),
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search opportunities...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
        ),
      ),
      body: filteredResults.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No opportunities found.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            )
          : ListView.builder(
              itemCount: filteredResults.length,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemBuilder: (context, index) {
                final opportunity = filteredResults[index];

                final oppTitle = selectedIndex == 0
                    ? opportunity['Job Title']
                    : opportunity['jobTitle'];
                final companyName = selectedIndex == 0
                    ? opportunity['Company Name']
                    : opportunity['companyName'];
                final description = selectedIndex == 0
                    ? opportunity['Description']
                    : opportunity['description'];
                final applyUrl = selectedIndex == 0
                    ? opportunity['Apply url']
                    : opportunity['companyLink'];
                final gpa5 = selectedIndex == 0
                    ? double.tryParse(
                            opportunity['GPA out of 5']?.toString() ?? '0.0') ??
                        0.0
                    : double.tryParse(
                            opportunity['gpaOutOf5']?.toString() ?? '0.0') ??
                        0.0;

                final gpa4 = selectedIndex == 0
                    ? double.tryParse(
                            opportunity['GPA out of 4']?.toString() ?? '0.0') ??
                        0.0
                    : double.tryParse(
                            opportunity['gpaOutOf4']?.toString() ?? '0.0') ??
                        0.0;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                      title: Text(
                        oppTitle ?? "Unknown Title",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF113F67),
                        ),
                      ),
                      subtitle: Text(
                        companyName ?? "Unknown Company",
                        style: const TextStyle(fontSize: 13),
                      ),
                      trailing: GradientButton(
                        text: "More",
                        gradientColors: [
                          const Color(0xFF113F67),
                          Color.fromARGB(255, 105, 185, 255),
                        ],
                        onPressed: () {
                          if (selectedIndex == 0) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OpportunityDetailsPage(
                                  jobTitle: oppTitle,
                                  companyName: companyName,
                                  description: description,
                                  applyUrl: applyUrl,
                                  similarity: 0.0,
                                  skills: List<String>.from(
                                      opportunity['Skills'] ?? []),
                                  location: (opportunity['Locations'] ?? [])
                                      .join(', '),
                                  gpa5: gpa5,
                                  gpa4: gpa4,
                                  opportunityId: null,
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TpOpportunityDetailsPage(
                                  opportunityId: opportunity['id'],
                                  jobTitle: oppTitle,
                                  companyName: companyName,
                                  description: description,
                                  applyUrl: applyUrl,
                                  skills: List<String>.from(
                                      opportunity['skills'] ?? []),
                                  location: (opportunity['locations'] ?? [])
                                      .join(', '),
                                  gpa5: gpa5,
                                  gpa4: gpa4,
                                  duration:
                                      opportunity['duration']?.toString() ?? '',
                                  endDate:
                                      opportunity['endDate']?.toString() ?? '',
                                  createdAt:
                                      opportunity['createdAt']?.toString() ??
                                          '',
                                  startDate:
                                      opportunity['startDate']?.toString() ??
                                          '',
                                  jobType:
                                      opportunity['jobType']?.toString() ?? '',
                                  major:
                                      (opportunity['major'] ?? []).join(', '),
                                  contactInfo: opportunity['contactInfo'],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      onTap: () {
                        if (selectedIndex == 0) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OpportunityDetailsPage(
                                jobTitle: oppTitle,
                                companyName: companyName,
                                description: description,
                                applyUrl: applyUrl,
                                similarity: 0.0,
                                skills: List<String>.from(
                                    opportunity['Skills'] ?? []),
                                location:
                                    (opportunity['Locations'] ?? []).join(', '),
                                gpa5: gpa5,
                                gpa4: gpa4,
                                opportunityId: null,
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TpOpportunityDetailsPage(
                                opportunityId: opportunity['id'],
                                jobTitle: oppTitle,
                                companyName: companyName,
                                description: description,
                                applyUrl: applyUrl,
                                skills: List<String>.from(
                                    opportunity['skills'] ?? []),
                                location:
                                    (opportunity['locations'] ?? []).join(', '),
                                gpa5: gpa5,
                                gpa4: gpa4,
                                duration:
                                    opportunity['duration']?.toString() ?? '',
                                endDate:
                                    opportunity['endDate']?.toString() ?? '',
                                createdAt:
                                    opportunity['createdAt']?.toString() ?? '',
                                startDate:
                                    opportunity['startDate']?.toString() ?? '',
                                jobType:
                                    opportunity['jobType']?.toString() ?? '',
                                major: (opportunity['major'] ?? []).join(', '),
                                contactInfo:
                                    opportunity['contactInfo']?.toString() ??
                                        '',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
