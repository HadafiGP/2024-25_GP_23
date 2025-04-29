import 'package:flutter/material.dart';
import 'package:hadafi_application/OpportunityDetailsPage.dart';
import 'package:hadafi_application/TpOpportunityDetailsPage.dart';
import 'package:hadafi_application/button.dart';

class OpportunitySearchPage extends StatefulWidget {
  final List<dynamic> opportunities;

  const OpportunitySearchPage({
    super.key,
    required this.opportunities,
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
        final title =
            (item['Job Title'] ?? item['jobTitle'] ?? '').toLowerCase();
        final company =
            (item['Company Name'] ?? item['companyName'] ?? '').toLowerCase();
        final locations = (item['Locations'] ?? item['locations'] ?? []);
        final locationString = locations.join(', ').toLowerCase();
        final jobType = (item['jobType'] ?? '').toLowerCase();

        return title.contains(query) ||
            company.contains(query) ||
            locationString.contains(query) ||
            jobType.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF113F67),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          'Search Opportunities',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Search Bar here
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF113F67),
                    Color.fromARGB(255, 105, 185, 255),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(1.8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search opportunities...',
                    hintStyle: const TextStyle(color: Colors.black54),
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF113F67)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                  ),
                ),
              ),
            ),
          ),
          // Info Box
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            margin: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0), // To add margin and avoid it touching edges
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8), // Rounded corners
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF113F67),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'You can search by title, company name, location, and opportunity type (COOP/Intern).',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF113F67),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: filteredResults.isEmpty
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

                      final oppTitle = opportunity['Job Title'] ??
                          opportunity['jobTitle'] ??
                          "Unknown Title";
                      final companyName = opportunity['Company Name'] ??
                          opportunity['companyName'] ??
                          "Unknown Company";
                      final description = opportunity['Description'] ??
                          opportunity['description'] ??
                          "";
                      final applyUrl = opportunity['Apply url'] ??
                          opportunity['companyLink'] ??
                          "";
                      final gpa5 = double.tryParse(
                              (opportunity['GPA out of 5'] ??
                                      opportunity['gpaOutOf5'] ??
                                      '0.0')
                                  .toString()) ??
                          0.0;
                      final gpa4 = double.tryParse(
                              (opportunity['GPA out of 4'] ??
                                      opportunity['gpaOutOf4'] ??
                                      '0.0')
                                  .toString()) ??
                          0.0;
                      final isPostedInHadafi = opportunity.containsKey('id');

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
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
                              oppTitle,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF113F67),
                              ),
                            ),
                            subtitle: Text(
                              companyName,
                              style: const TextStyle(fontSize: 13),
                            ),
                            trailing: GradientButton(
                              text: "More",
                              gradientColors: [
                                const Color(0xFF113F67),
                                Color.fromARGB(255, 105, 185, 255),
                              ],
                              onPressed: () {
                                _navigateToDetails(
                                    context, opportunity, isPostedInHadafi);
                              },
                            ),
                            onTap: () {
                              _navigateToDetails(
                                  context, opportunity, isPostedInHadafi);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetails(
      BuildContext context, dynamic opportunity, bool isPostedInHadafi) {
    final oppTitle = opportunity['Job Title'] ?? opportunity['jobTitle'];
    final companyName =
        opportunity['Company Name'] ?? opportunity['companyName'];
    final description =
        opportunity['Description'] ?? opportunity['description'];
    final applyUrl = opportunity['Apply url'] ?? opportunity['companyLink'];
    final gpa5 = double.tryParse(
            (opportunity['GPA out of 5'] ?? opportunity['gpaOutOf5'] ?? '0.0')
                .toString()) ??
        0.0;
    final gpa4 = double.tryParse(
            (opportunity['GPA out of 4'] ?? opportunity['gpaOutOf4'] ?? '0.0')
                .toString()) ??
        0.0;

    if (isPostedInHadafi) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TpOpportunityDetailsPage(
            opportunityId: opportunity['id'],
            jobTitle: oppTitle,
            companyName: companyName,
            description: description,
            applyUrl: applyUrl,
            skills: List<String>.from(opportunity['skills'] ?? []),
            location: (opportunity['locations'] ?? []).join(', '),
            gpa5: gpa5,
            gpa4: gpa4,
            duration: opportunity['duration']?.toString() ?? '',
            endDate: opportunity['endDate']?.toString() ?? '',
            createdAt: opportunity['createdAt']?.toString() ?? '',
            startDate: opportunity['startDate']?.toString() ?? '',
            jobType: opportunity['jobType']?.toString() ?? '',
            major: (opportunity['major'] ?? []).join(', '),
            contactInfo: opportunity['contactInfo']?.toString() ?? '',
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OpportunityDetailsPage(
            jobTitle: oppTitle,
            companyName: companyName,
            description: description,
            applyUrl: applyUrl,
            similarity: 0.0,
            skills: List<String>.from(opportunity['Skills'] ?? []),
            location: (opportunity['Locations'] ?? []).join(', '),
            gpa5: gpa5,
            gpa4: gpa4,
            opportunityId: null,
          ),
        ),
      );
    }
  }
}
