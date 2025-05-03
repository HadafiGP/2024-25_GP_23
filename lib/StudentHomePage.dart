import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/provider.dart';
import 'package:hadafi_application/TpOpportunityDetailsPage.dart';
import 'package:hadafi_application/interview.dart';
import 'package:hadafi_application/opportunity_search_page.dart';
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
import 'package:hadafi_application/Feedback/feedback.dart';
import 'package:hadafi_application/Feedback/allFeedback.dart';

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
            _buildDrawerItem(
                context, Icons.feedback, 'App Feedback', AllFeedbackScreen()),
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
  List<dynamic> csvOpportunities = [];
  bool isLoadingCsvOpportunities = true;
  List<dynamic> recommendations = [];
  bool isLoading = true;
  bool isLoadingProviderOpportunities = true;
  List<dynamic> providerOpportunities = [];
  int selectedIndex = 0;

  final ValueNotifier<int> _tabNotifier = ValueNotifier<int>(0);
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAllData();
    });
  }

  Future<void> _initializeAllData() async {
    setState(() => isLoading = true);

    await fetchCsvOpportunities(); // Ensure CSV loads first
    print("CSV loaded: ${csvOpportunities.length} items");

    await Future.wait([
      fetchRecommendations(),
      fetchUserMajor().then((_) async {
        await fetchProviderOpportunities();
        await filterProviderOpportunitiesByMajor();
      }),
    ]);

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  //Fetch all opportunitites
  Future<void> fetchCsvOpportunities() async {
    int attempts = 0;
    const maxRetries = 5;

    while (attempts < maxRetries) {
      try {
        final response =
            await http.get(Uri.parse("http://10.0.2.2:5000/opportunities"));

        if (response.statusCode == 200) {
          try {
            final data = json.decode(response.body);
            setState(() {
              csvOpportunities = data['opportunities'] ?? [];
              isLoadingCsvOpportunities = false;
            });
            print("CSV loaded: ${csvOpportunities.length} items");
            return;
          } catch (e) {
            print("⚠️ JSON decoding error: $e (retrying...)");
          }
        } else {
          print("CSV error: ${response.body}");
        }
      } catch (e) {
        print("CSV exception: $e");
      }

      attempts++;
      await Future.delayed(const Duration(seconds: 2));
    }

    setState(() => isLoadingCsvOpportunities = false);
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
        final jobTitle = doc['jobTitle'];
        final providerId = doc['providerUid'];
        final description = doc['description'];
        final jobType = doc['jobType'];
        final majors = List<String>.from(doc['majors'] ?? []);

        final locations = List<String>.from(doc['locations']);
        final skills = List<String>.from(doc['skills']);
        final startDate = doc['startDate'];
        final duration = doc['duration'];
        final endDate = doc['endDate'];

        final contactInfo = doc['contactInfo'] ?? 'Not provided';

        final gpa5 = doc['gpaOutOf5'] ?? 0.0;
        final gpa4 = doc['gpaOutOf4'] ?? 0.0;
        final companyLink = doc['companyLink'] ?? "";

        final providerSnapshot = await FirebaseFirestore.instance
            .collection('TrainingProvider')
            .doc(providerId)
            .get();

        final companyName = providerSnapshot.exists
            ? providerSnapshot['company_name']
            : 'Unknown Company';

        fetchedOpportunities.add({
          'id': doc.id,
          'jobTitle': jobTitle,
          'companyName': companyName,
          'description': description,
          'jobType': jobType,
          'major': majors,
          'locations': locations,
          'skills': skills,
          'startDate': startDate,
          'duration': duration,
          'endDate': endDate,
          'providerId': providerId,
          'gpaOutOf5': gpa5,
          'gpaOutOf4': gpa4,
          'companyLink': companyLink,
          'contactInfo': contactInfo,
        });
      }

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
          .collection('Student')
          .doc(user.uid)
          .get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data();
        userMajor = userData?['major'] ?? '';
        print("User major: $userMajor");
      }
    } catch (e) {
      print("An error occurred while fetching user major: $e");
    }
  }

  List<dynamic> filteredProviderOpportunities = [];
  Future<void> filterProviderOpportunitiesByMajor() async {
    filteredProviderOpportunities = providerOpportunities;

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
                _tabNotifier.value =
                    tabController.index; //innfo navigation only in recommended
              });
            }
          });

          return Scaffold(
            backgroundColor: const Color(0xFFF3F9FB),
            drawer: const HadafiDrawer(),
            appBar: AppBar(
              backgroundColor: const Color(0xFF113F67),
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(''),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    final List<dynamic> dataToSearch = [
                      ...recommendations,
                      ...filteredProviderOpportunities,
                    ];

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OpportunitySearchPage(
                          opportunities: dataToSearch,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildSectionTitle('Training Opportunities'),
                        _buildOpportunitiesTab(tabController),
                        _buildSectionTitle('App Feedback'),
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
                Tab(text: 'Recommended'),
                Tab(text: 'Find Oppurtonities'),
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
                  FindOpportunitiesTab(
                    key: ValueKey(csvOpportunities.length +
                        filteredProviderOpportunities.length),
                    csvOpportunities: csvOpportunities,
                    firestoreOpportunities: filteredProviderOpportunities,
                    isLoading: isLoadingCsvOpportunities,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                "Care to share your experience?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF113F67),
                ),
              ),
              const Spacer(),
              GradientButton(
                text: "Share",
                gradientColors: [
                  const Color(0xFF113F67),
                  Color.fromARGB(255, 105, 185, 255),
                ],
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FeedbackScreen()),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 160,
          child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('Feedback')
                .orderBy('timestamp', descending: true)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final allDocs = snapshot.data!.docs;
              final showMoreButton = allDocs.length > 3;
              final docs = allDocs.take(3).toList();

              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    "No feedback has been shared yet.",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: showMoreButton ? docs.length + 1 : docs.length,
                itemBuilder: (context, index) {
                  if (!showMoreButton || index < docs.length) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final scrollController = ScrollController();

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('Student')
                          .doc(data['uid'])
                          .get(),
                      builder: (context, userSnapshot) {
                        final name = userSnapshot.hasData
                            ? (userSnapshot.data!.data()
                                    as Map<String, dynamic>)['name'] ??
                                'User'
                            : 'User';

                        final rating = data['rating'] ?? 0;
                        final experience = data['experience'] ?? '';

                        return Container(
                          width: 240,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          padding: const EdgeInsets.all(12),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF113F67),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: List.generate(5, (i) {
                                  return Icon(
                                    Icons.star,
                                    size: 16,
                                    color: i < rating
                                        ? Colors.amber[700]
                                        : Colors.grey[300],
                                  );
                                }),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Scrollbar(
                                  controller: scrollController,
                                  thumbVisibility: true,
                                  radius: const Radius.circular(8),
                                  child: SingleChildScrollView(
                                    controller: scrollController,
                                    padding: EdgeInsets.zero,
                                    child: Text(
                                      experience,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    // More button
                    return Container(
                      margin: const EdgeInsets.all(16),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AllFeedbackScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF113F67),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: const Center(
                            child:
                                Icon(Icons.arrow_forward, color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class OpportunitiesList extends StatelessWidget {
  final String title;
  final List<dynamic> opportunities;
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

        final oppTitle = opportunity['Job Title'] as String? ??
            opportunity['jobTitle'] as String? ??
            "Unknown Title";

        final companyName = opportunity['Company Name'] as String? ??
            opportunity['companyName'] as String? ??
            "Unknown Company";

        final description = opportunity['Description'] as String? ??
            opportunity['description'] as String? ??
            "No description available.";

        final applyUrl = opportunity['Apply url'] as String? ??
            opportunity['companyLink'] as String? ??
            "unknown";

        final gpa5 = (opportunity['GPA out of 5'] is String)
            ? double.tryParse(opportunity['GPA out of 5']) ?? 0.0
            : opportunity['GPA out of 5'] ?? opportunity['gpaOutOf5'] ?? 0.0;

        final gpa4 = (opportunity['GPA out of 4'] is String)
            ? double.tryParse(opportunity['GPA out of 4']) ?? 0.0
            : opportunity['GPA out of 4'] ?? opportunity['gpaOutOf4'] ?? 0.0;

        final contactInfo =
            (opportunity['Contact Info'] ?? opportunity['contactInfo'])
                    ?.toString() ??
                "";

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
              onTap: () {
                if (opportunity.containsKey('Skills Similarity') ||
                    opportunity['id'] == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OpportunityDetailsPage(
                        jobTitle: oppTitle,
                        companyName: companyName,
                        description: description,
                        applyUrl: applyUrl,
                        similarity: 0.0,
                        skills: List<String>.from(opportunity['Skills'] ??
                            opportunity['skills'] ??
                            []),
                        location: (opportunity['Locations'] ??
                                opportunity['locations'] ??
                                [])
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
                        skills: List<String>.from(opportunity['Skills'] ??
                            opportunity['skills'] ??
                            []),
                        location: (opportunity['Locations'] ??
                                opportunity['locations'] ??
                                [])
                            .join(', '),
                        gpa5: opportunity['gpaOutOf5'] is double
                            ? opportunity['gpaOutOf5']
                            : double.tryParse(
                                    opportunity['gpaOutOf5'].toString()) ??
                                0.0,
                        gpa4: opportunity['gpaOutOf4'] is double
                            ? opportunity['gpaOutOf4']
                            : double.tryParse(
                                    opportunity['gpaOutOf4'].toString()) ??
                                0.0,
                        duration: opportunity['duration'] ?? "",
                        endDate: opportunity['endDate'] ?? "",
                        createdAt: opportunity['createdAt'] ?? "",
                        startDate: opportunity['startDate'] ?? "",
                        jobType: opportunity['jobType'] ?? "",
                        major: (opportunity['major'] ?? []).join(', '),
                        contactInfo: contactInfo,
                      ),
                    ),
                  );
                }
              },
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Consumer(
                    builder: (context, ref, child) {
                      final favoriteOpps = ref.watch(favoriteProvider);
                      final oppUrl = opportunity['Job LinkedIn URL'] ??
                          opportunity['Company Apply link'] ??
                          opportunity['Apply url'] ??
                          opportunity['companyLink'] ??
                          '';
                      final isFavorited =
                          favoriteOpps.favOpportunities.any((opp) {
                        // Firestore-based match by id
                        if (opp['id'] != null && opportunity['id'] != null) {
                          return opp['id'] == opportunity['id'];
                        }

                        // CSV-based match by URL
                        final urlA = opp['Job LinkedIn URL'] ??
                            opp['Company Apply link'] ??
                            opp['Apply url'] ??
                            opp['companyLink'] ??
                            '';
                        final urlB = opportunity['Job LinkedIn URL'] ??
                            opportunity['Company Apply link'] ??
                            opportunity['Apply url'] ??
                            opportunity['companyLink'] ??
                            '';
                        return urlA == urlB;
                      });

                      final favoriteOpp = {
                        'id': opportunity['id'],
                        'Job Title': oppTitle,
                        'Company Name': companyName,
                        'Description': description,
                        'Apply url': applyUrl,
                        'GPA out of 5': gpa5,
                        'GPA out of 4': gpa4,
                        'Locations': opportunity['Locations'] ??
                            opportunity['locations'] ??
                            [],
                        'Skills': opportunity['Skills'] ??
                            opportunity['skills'] ??
                            [],
                      };

                      return GestureDetector(
                        onTap: () {
                          final wasFavorited = isFavorited;
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
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child:  Icon(
                            isFavorited
                                ? Icons.bookmark_added
                                : Icons.bookmark_add_outlined,
                            color:
                                isFavorited ? Colors.amber[400] : Colors.grey,
                            size: MediaQuery.of(context).devicePixelRatio < 2.5
                                ? 20
                                : 24,
                            key: ValueKey<bool>(isFavorited),
                          ),
                        
                      );
                    },
                  ),
                  const SizedBox(width: 5),
                  GradientButton(
                    text: "More",
                    gradientColors: const [
                      Color(0xFF113F67),
                      Color.fromARGB(255, 105, 185, 255),
                    ],
                    onPressed: () {
                      if (opportunity.containsKey('Skills Similarity') ||
                          opportunity['id'] == null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OpportunityDetailsPage(
                              jobTitle: oppTitle,
                              companyName: companyName,
                              description: description,
                              applyUrl: applyUrl,
                              similarity: 0.0,
                              skills: List<String>.from(opportunity['Skills'] ??
                                  opportunity['skills'] ??
                                  []),
                              location: (opportunity['Locations'] ??
                                      opportunity['locations'] ??
                                      [])
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
                              skills: List<String>.from(opportunity['Skills'] ??
                                  opportunity['skills'] ??
                                  []),
                              location: (opportunity['Locations'] ??
                                      opportunity['locations'] ??
                                      [])
                                  .join(', '),
                              gpa5: opportunity['gpaOutOf5'] is double
                                  ? opportunity['gpaOutOf5']
                                  : double.tryParse(opportunity['gpaOutOf5']
                                          .toString()) ??
                                      0.0,
                              gpa4: opportunity['gpaOutOf4'] is double
                                  ? opportunity['gpaOutOf4']
                                  : double.tryParse(opportunity['gpaOutOf4']
                                          .toString()) ??
                                      0.0,
                              duration: opportunity['duration'] ?? "",
                              endDate: opportunity['endDate'] ?? "",
                              createdAt: opportunity['createdAt'] ?? "",
                              startDate: opportunity['startDate'] ?? "",
                              jobType: opportunity['jobType'] ?? "",
                              major: (opportunity['major'] ?? []).join(', '),
                              contactInfo: contactInfo,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double correctSize(BuildContext context, double px) {
    return px / MediaQuery.of(context).devicePixelRatio;
  }
}

class FindOpportunitiesTab extends StatefulWidget {
  final List<dynamic> csvOpportunities;
  final List<dynamic> firestoreOpportunities;
  final bool isLoading;

  const FindOpportunitiesTab({
    super.key,
    required this.csvOpportunities,
    required this.firestoreOpportunities,
    required this.isLoading,
  });

  @override
  State<FindOpportunitiesTab> createState() => _FindOpportunitiesTabState();
}

class _FindOpportunitiesTabState extends State<FindOpportunitiesTab> {
  late List<dynamic> allOpportunities;

  @override
  void initState() {
    super.initState();
    allOpportunities = [
      ...widget.firestoreOpportunities,
      ...widget.csvOpportunities
    ];
  }

  @override
  void didUpdateWidget(covariant FindOpportunitiesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.csvOpportunities != widget.csvOpportunities ||
        oldWidget.firestoreOpportunities != widget.firestoreOpportunities) {
      setState(() {
        allOpportunities = [
          ...widget.firestoreOpportunities,
          ...widget.csvOpportunities
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.isLoading) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: allOpportunities.isEmpty
              ? const Center(child: Text('No opportunities available.'))
              : OpportunitiesList(
                  title: 'Other Opportunities',
                  opportunities: allOpportunities,
                  selectedIndex: 3,
                ),
        ),
      ],
    );
  }
}
