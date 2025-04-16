import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/provider.dart';
import 'package:hadafi_application/TpOpportunityDetailsPage.dart';
import 'package:hadafi_application/interview.dart';
import 'package:hadafi_application/welcome.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "package:hadafi_application/OpportunityDetailsPage.dart";
import "package:hadafi_application/button.dart";
import 'package:hadafi_application/studentProfilePage.dart';
import 'package:hadafi_application/CV.dart';
import 'package:hadafi_application/Community/CommunityHomeScreen.dart';
import 'package:hadafi_application/favoriteProvider.dart';
import 'package:hadafi_application/favoriteList.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentHomePage();
  }
}

class HadafiDrawer extends StatelessWidget {
  const HadafiDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFFF3F9FB),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF113F67),
              ),
              child: Image.asset(
                'Hadafi/images/LOGO.png',
                fit: BoxFit.contain,
                height: 80,
              ),
            ),
            _buildDrawerItem(context, Icons.person, 'Profile', ProfilePage()),
            _buildDrawerItem(
                context, Icons.home, 'Home', const StudentHomePage()),
            _buildDrawerItem(context, Icons.assignment, 'CV Checker', CVPage()),
            _buildDrawerItem(
              context,
              Icons.chat,
              'Interview Simulator',
              const InterviewPage(),
            ),
            _buildDrawerItem(context, Icons.feedback, 'Feedback', null),
            _buildDrawerItem(
                context, Icons.group, 'Communities', Communityhomescreen()),
            _buildDrawerItem(context, Icons.bookmark_added,
                'Saved Opportunities', FavoritePage()),
            ListTile(
              leading: const Icon(Icons.contact_mail, color: Color(0xFF113F67)),
              title: const Text('Contact us'),
              onTap: () {
                _launchEmail();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFF113F67)),
              title: const Text('Log Out'),
              onTap: () {
                Navigator.pop(context);
                _logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, IconData icon, String title, Widget? page) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF113F67)),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        }
      },
    );
  }

  void _launchEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print("User is not logged in.");
        return;
      }

      final String userId = user.uid;

      final String email = 'Hadafi.GP@gmail.com';
      final String subject =
          Uri.encodeComponent('App Support - User ID: $userId');
      final String body = Uri.encodeComponent(
          'Dear Admin, I encountered the following issues:');

      final String emailUrl = 'mailto:$email?subject=$subject&body=$body';

      if (await canLaunchUrl(Uri.parse(emailUrl))) {
        await launchUrl(Uri.parse(emailUrl));
      } else {
        throw 'Could not launch email client';
      }
    } catch (e) {
      print("An error occurred while launching the email: $e");
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      ProviderScope.containerOf(context, listen: false)
          .read(uidProvider.notifier)
          .state = null;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  _StudentHomePageState createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  List<dynamic> recommendations = []; //this is for the best match recs
  bool isLoading = true;
  bool isLoadingProviderOpportunities =
      true; // This will be used to track if data is still being fetched
  List<dynamic> providerOpportunities =
      []; // List to store the fetched opportunities
  int selectedIndex = 0; // Initialize selectedIndex to 0 (for "Best Match" tab)

  final ValueNotifier<int> _tabNotifier = ValueNotifier<int>(0);
  TabController? _tabController;

  @override
  @override
  void initState() {
    super.initState();
    // First, fetch recommendations, then fetch provider opportunities and user major
    fetchRecommendations();
    fetchUserMajor().then((_) {
      fetchProviderOpportunities().then((_) {
        // After both fetches complete, filter the opportunities
        filterProviderOpportunitiesByMajor();
      });
    });
  }

//best match recs
  Future<void> fetchRecommendations() async {
    final String url = "http://10.0.2.2:5000/recommend";

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print("User is not logged in.");
        return;
      }

      final String? firebaseToken = await user.getIdToken();

      if (firebaseToken == null) {
        print("Failed to retrieve Firebase token.");
        return;
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $firebaseToken",
        },
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            recommendations = data['recommendations'];
          });
        }
      } else {
        print(
            "Failed to fetch recommendations. Status code: ${response.statusCode}");
        print("Error message: ${response.body}");
      }
    } catch (e) {
      print("An error occurred: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> fetchProviderOpportunities() async {
    try {
      final opportunitiesRef =
          FirebaseFirestore.instance.collection('opportunity');
      final providerQuery = await opportunitiesRef.get();

      List<dynamic> fetchedOpportunities = [];

      for (var doc in providerQuery.docs) {
        // Extract fields for each opportunity from Firestore
        final jobTitle = doc['jobTitle'];
        final providerId = doc['providerUid']; // Get provider's ID
        final description = doc['description'];
        final jobType = doc['jobType'];
        final major = doc['major']; // Major field for filtering
        final locations = List<String>.from(doc['locations']);
        final skills = List<String>.from(doc['skills']);
        final startDate = doc['startDate'];
        final duration = doc['duration'];
        final endDate = doc['endDate'];

        // Add default values for missing fields (if not already in Firestore)
        final gpa5 = doc['gpaOutOf5'] ??
            0.0; // Default value if GPA out of 5 doesn't exist
        final gpa4 = doc['gpaOutOf4'] ??
            0.0; // Default value if GPA out of 4 doesn't exist
        final companyLink = doc['companyLink'] ??
            ""; // Default value if Apply url doesn't exist

        // Fetch the company name using the providerUid
        final providerSnapshot = await FirebaseFirestore.instance
            .collection('TrainingProvider')
            .doc(providerId)
            .get();

        final companyName = providerSnapshot.exists
            ? providerSnapshot['company_name']
            : 'Unknown Company';

        // Add the opportunity to the list
        fetchedOpportunities.add({
          'jobTitle': jobTitle,
          'companyName': companyName,
          'description': description,
          'jobType': jobType,
          'major': major,
          'locations': locations,
          'skills': skills,
          'startDate': startDate,
          'duration': duration,
          'endDate': endDate,
          'providerId': providerId,
          'gpaOutOf5': gpa5, // Add GPA out of 5
          'gpaOutOf4': gpa4, // Add GPA out of 4
          'companyLink': companyLink, // Add Apply URL
        });
      }

      print('Fetched ${providerQuery.docs.length} opportunities');
      print('Provider Opportunities: $fetchedOpportunities');

      setState(() {
        providerOpportunities = fetchedOpportunities;
        isLoadingProviderOpportunities = false;
      });
    } catch (e) {
      print("An error occurred while fetching provider opportunities: $e");
    }
  }

// in this part i will get the student major to display the other opportunities according to it
  String userMajor = '';

  Future<void> fetchUserMajor() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("User is not logged in.");
      return;
    }

    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection(
              'Student') // Ensure this is the correct collection for the student
          .doc(user.uid)
          .get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data();
        userMajor = userData?['major'] ?? '';
        print(
            "User major: $userMajor"); // Debug: Check if the major is correctly fetched
      }
    } catch (e) {
      print("An error occurred while fetching user major: $e");
    }
  }

  List<dynamic> filteredProviderOpportunities = [];
  Future<void> filterProviderOpportunitiesByMajor() async {
    print("Starting to filter opportunities by major.");

    // Debugging: print the fetched opportunities before filtering
    print("Fetched Provider Opportunities: $providerOpportunities");

    filteredProviderOpportunities = providerOpportunities.where((opportunity) {
      final opportunityMajor = opportunity['major'] ?? '';
      print("User Major: $userMajor, Opportunity Major: $opportunityMajor");

      // Check if the opportunity's major exactly matches the user's major
      return opportunityMajor.trim().toLowerCase() ==
          userMajor.trim().toLowerCase();
    }).toList();

    print("Filtered Opportunities: $filteredProviderOpportunities");
    setState(() {
      isLoadingProviderOpportunities = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (BuildContext context) {
          final TabController tabController = DefaultTabController.of(context)!;

          // Listen to the tab changes
          tabController.addListener(() {
            if (!tabController.indexIsChanging) {
              setState(() {
                selectedIndex = tabController.index;
              });
            }
          });

          return Scaffold(
            backgroundColor: const Color(0xFFF3F9FB),
            drawer: const HadafiDrawer(),
            appBar: AppBar(
              backgroundColor: const Color(0xFF113F67),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildSectionTitle('Training Opportunities'),
                        _buildOpportunitiesTab(tabController),
                        _buildSectionTitle('Feedback from Users'),
                        _buildFeedbackList(),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF113F67),
          ),
        ),
      ),
    );
  }

  Widget _buildOpportunitiesTab(TabController tabController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: SizedBox(
        height: 530,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<int>(
              valueListenable: _tabNotifier,
              builder: (context, selectedIndex, child) {
                return AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: selectedIndex == 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(8),
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
                                  'Opportunities are sorted from the best match to the least',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF113F67),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                );
              },
            ),
            const TabBar(
              labelColor: Color(0xFF113F67),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFF113F67),
              tabs: [
                Tab(text: 'Best Match'),
                Tab(text: 'Other'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  OpportunitiesList(
                    title: 'Best Match Opportunities',
                    opportunities: recommendations,
                    selectedIndex: selectedIndex,
                  ),
                  OpportunitiesList(
                    title: 'Other Opportunities',
                    opportunities: filteredProviderOpportunities,
                    selectedIndex: selectedIndex,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackList() {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 200,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF113F67), width: 2),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 5, spreadRadius: 2),
              ],
            ),
            child: ListTile(
              title: Text('User ${index + 1}'),
              subtitle:
                  const Text('This app helped me find a great internship!'),
            ),
          );
        },
      ),
    );
  }
}

class OpportunitiesList extends StatelessWidget {
  final String title;
  final List<dynamic> opportunities; //best match
  final int selectedIndex;

  const OpportunitiesList({
    super.key,
    required this.title,
    required this.opportunities,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (opportunities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No opportunities available at the moment.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: opportunities.length,
      itemBuilder: (context, index) {
        final opportunity = opportunities[index];

        print("Opportunities inside the list: $opportunities");

        // Conditionally use the correct key depending on the active tab
        final oppTitle = selectedIndex == 0
            ? opportunity['Job Title'] ?? "Unknown Title" // "Best Match"
            : opportunity['jobTitle'] ?? "Unknown Title"; // "Other"

        final companyName = selectedIndex == 0
            ? opportunity['Company Name'] ?? "Unknown Company" // "Best Match"
            : opportunity['companyName'] ?? "Unknown Company"; // "Other"

        final description = selectedIndex == 0
            ? opportunity['Description'] ??
                "No description available." // "Best Match"
            : opportunity['description'] ??
                "No description available."; // "Other"

        final applyUrl = selectedIndex == 0
            ? opportunity['Apply url'] ?? "unknown" // "Best Match"
            : opportunity['companyLink'] ?? "unkown"; // "Other"

        final gpa5 = selectedIndex == 0
            ? opportunity['GPA out of 5'] ?? 0.0 // "Best Match"
            : opportunity['gpaOutOf5'] ?? 0.0; // "Other"

        final gpa4 = selectedIndex == 0
            ? opportunity['GPA out of 4'] ?? 0.0 // "Best Match"
            : opportunity['gpaOutOf4'] ?? 0.0; // "Other"
            

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 8.0),
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
                  softWrap: true,
                ),
                subtitle: Text(
                  companyName,
                  style: const TextStyle(fontSize: 13),
                ),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Consumer(
                    builder: (context, ref, child) {
                      final favoriteOpps = ref.watch(favoriteProvider);
                      final isFavorited = favoriteOpps.favOpportunities
                          .any((opp) => opp['Job Title'] == oppTitle);

                      return GestureDetector(
                        onTap: () {
                          final wasFavorited = isFavorited;

                          final favoriteOpp = {
                            'Job Title': oppTitle,
                            'Company Name': companyName,
                            'Description': description,
                            'Apply url': applyUrl,
                            'GPA out of 5': gpa5,
                            'GPA out of 4': gpa4,
                            'Locations': opportunity['Locations'] ?? [],
                            'Skills': opportunity['Skills'] ?? [],
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
                                style: const TextStyle(color: Colors.white),
                              ),
                              action: wasFavorited
                                  ? SnackBarAction(
                                      label: "Undo",
                                      textColor: Colors.white,
                                      onPressed: () {
                                        ref
                                            .read(favoriteProvider.notifier)
                                            .toggleFavorite(favoriteOpp);
                                      },
                                    )
                                  : null,
                              backgroundColor:
                                  const Color.fromARGB(255, 0, 118, 208),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            isFavorited
                                ? Icons.bookmark_added
                                : Icons.bookmark_add_outlined,
                            color:
                                isFavorited ? Colors.amber[400] : Colors.grey,
                            size: correctSize(context, 72),
                            key: ValueKey<bool>(isFavorited),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 5),
                  GradientButton(
                    text: "More",
                    gradientColors: [
                      const Color(0xFF113F67),
                      Color.fromARGB(255, 105, 185, 255),
                    ],
                    onPressed: () {
                      // Check which tab is currently selected
                      if (selectedIndex == 0) {
                        // Best match tab - navigate to OpportunityDetailsPage
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
                            ),
                          ),
                        );
                      } else {
                        // Other tab - navigate to TpOpportunityDetailsPage
                        Navigator.push(
                          context,
MaterialPageRoute(
  builder: (context) => TpOpportunityDetailsPage(
    jobTitle: oppTitle,
    companyName: companyName,
    description: description,
    applyUrl: applyUrl,
    skills: List<String>.from(opportunity['skills'] ?? []),
    location: (opportunity['locations'] ?? []).join(', '),
    gpa5: (opportunity['gpaOutOf5'] is double)
        ? opportunity['gpaOutOf5']
        : double.tryParse(opportunity['gpaOutOf5'].toString()) ?? 0.0,
    gpa4: (opportunity['gpaOutOf4'] is double)
        ? opportunity['gpaOutOf4']
        : double.tryParse(opportunity['gpaOutOf4'].toString()) ?? 0.0,
    duration: opportunity['duration'] ?? "",
    endDate: opportunity['endDate'] ?? "",
    createdAt: opportunity['createdAt'] ?? "",
    startDate: opportunity['startDate'] ?? "",  // Added startDate
    jobType: opportunity['jobType'] ?? "",      // Added jobType
    major: opportunity['major'] ?? "",          // Added major
    contactInfo: opportunity['contactInfo'] ?? "", // Added contactInfo
  ),
),

                        );
                      }
                    },
                  ),
                ]),
              )),
        );
      },
    );
  }

  double correctSize(BuildContext context, double px) {
    return px / MediaQuery.of(context).devicePixelRatio;
  }
}
