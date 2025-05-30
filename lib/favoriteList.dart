import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/StudentHomePage.dart';
import 'package:hadafi_application/TpOpportunityDetailsPage.dart';
import 'package:hadafi_application/favoriteProvider.dart';
import 'package:hadafi_application/OpportunityDetailsPage.dart';
import 'package:hadafi_application/button.dart';

class FavoritePage extends ConsumerStatefulWidget {
  const FavoritePage({super.key});

  @override
  ConsumerState<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends ConsumerState<FavoritePage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      ref.read(favoriteProvider).loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProviderState = ref.watch(favoriteProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F9FB),
      drawer: const HadafiDrawer(),
      appBar: AppBar(
        title: const Text("Saved Opportunities",
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF113F67),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: favoriteProviderState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteProviderState.favOpportunities.isEmpty
              ? const Center(
                  child: Text(
                    "You haven't saved any opportunities yet.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: favoriteProviderState.favOpportunities.length,
                  itemBuilder: (context, index) {
                    final opportunity =
                        favoriteProviderState.favOpportunities[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2.0, vertical: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                spreadRadius: 2),
                          ],
                        ),
                        child: ListTile(
                          title: Text(
                            opportunity['Job Title'],
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF113F67)),
                            softWrap: true,
                          ),
                          subtitle: Text(
                            opportunity['Company Name'] ?? "Unknown Company",
                            style: const TextStyle(fontSize: 13),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Consumer(
                                builder: (context, ref, child) {
                                  final isFavorited = ref
                                      .watch(favoriteProvider)
                                      .favOpportunities
                                      .any((opp) =>
                                          isSameOpportunity(opp, opportunity));

                                  return GestureDetector(
                                    onTap: () {
                                      final favoriteNotifier =
                                          ref.read(favoriteProvider.notifier);

                                      final rebuiltOpportunity = {
                                        ...opportunity,
                                        'id': opportunity['id'],
                                        'Job Title': opportunity['Job Title'],
                                        'Company Name':
                                            opportunity['Company Name'],
                                        'Description':
                                            opportunity['Description'],
                                        'Apply url': opportunity['Apply url'],
                                        'GPA out of 5':
                                            opportunity['GPA out of 5'],
                                        'GPA out of 4':
                                            opportunity['GPA out of 4'],
                                        'Locations':
                                            opportunity['Locations'] ?? [],
                                        'Skills': opportunity['Skills'] ?? [],
                                        'duration': opportunity['duration'],
                                        'endDate': opportunity['endDate'],
                                        'createdAt': opportunity['createdAt'],
                                        'startDate': opportunity['startDate'],
                                        'jobType': opportunity['jobType'],
                                        'major': opportunity['major'],
                                        'contactInfo':
                                            opportunity['contactInfo'],
                                        'documentId': opportunity[
                                            'documentId'], 
                                      };

                                      final isCurrentlyFavorited = ref
                                          .read(favoriteProvider)
                                          .favOpportunities
                                          .any((opp) => isSameOpportunity(
                                              opp, rebuiltOpportunity));

                                      favoriteNotifier
                                          .toggleFavorite(rebuiltOpportunity);

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isCurrentlyFavorited
                                                ? "Opportunity removed from Saved Opportunities"
                                                : "Opportunity added to Saved Opportunities",
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          action: isCurrentlyFavorited
                                              ? SnackBarAction(
                                                  label: "Undo",
                                                  textColor: Colors.white,
                                                  onPressed: () {
                                                    final undoOpportunity = Map<
                                                            String,
                                                            dynamic>.from(
                                                        rebuiltOpportunity);
                                                    undoOpportunity.remove(
                                                        'documentId'); 
                                                    favoriteNotifier
                                                        .toggleFavorite(
                                                            undoOpportunity);
                                                  },
                                                )
                                              : null,
                                          duration: const Duration(seconds: 5),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                    child: Icon(
                                      isFavorited
                                          ? Icons.bookmark_added
                                          : Icons.bookmark_add_outlined,
                                      color: isFavorited
                                          ? Colors.amber[400]
                                          : Colors.grey,
                                      size: correctSize(context, 72),
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
                                  final bool isPostedInHadafi =
                                      opportunity['jobType'] != null &&
                                          opportunity['jobType']
                                              .toString()
                                              .trim()
                                              .isNotEmpty;

                                  if (isPostedInHadafi) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TpOpportunityDetailsPage(
                                          opportunityId:
                                              opportunity['id'] ?? '',
                                          jobTitle: opportunity['Job Title'],
                                          companyName:
                                              opportunity['Company Name'] ??
                                                  'Unknown',
                                          description:
                                              opportunity['Description'] ??
                                                  'No description available.',
                                          applyUrl:
                                              opportunity['Apply url'] ?? '',
                                          skills: List<String>.from(
                                              opportunity['Skills'] ?? []),
                                          location:
                                              (opportunity['Locations'] ?? [])
                                                  .join(', '),
                                          gpa5: opportunity['GPA out of 5']
                                                  is double
                                              ? opportunity['GPA out of 5']
                                              : double.tryParse(opportunity[
                                                          'GPA out of 5']
                                                      .toString()) ??
                                                  0.0,
                                          gpa4: opportunity['GPA out of 4']
                                                  is double
                                              ? opportunity['GPA out of 4']
                                              : double.tryParse(opportunity[
                                                          'GPA out of 4']
                                                      .toString()) ??
                                                  0.0,
                                          duration:
                                              opportunity['duration'] ?? '',
                                          endDate: opportunity['endDate'] ?? '',
                                          createdAt:
                                              opportunity['createdAt'] ?? '',
                                          startDate:
                                              opportunity['startDate'] ?? '',
                                          jobType: opportunity['jobType'] ?? '',
                                          major: opportunity['major'] is List
                                              ? (opportunity['major'] as List)
                                                  .join(', ')
                                              : opportunity['major']
                                                      ?.toString() ??
                                                  '',
                                          contactInfo:
                                              opportunity['contactInfo'] ?? '',
                                        ),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            OpportunityDetailsPage(
                                          jobTitle: opportunity['Job Title'],
                                          companyName:
                                              opportunity['Company Name'] ??
                                                  'Unknown',
                                          description:
                                              opportunity['Description'] ??
                                                  'No description available.',
                                          applyUrl:
                                              opportunity['Apply url'] ?? '',
                                          similarity: 0.0,
                                          skills: List<String>.from(
                                              opportunity['Skills'] ?? []),
                                          location:
                                              (opportunity['Locations'] ?? [])
                                                  .join(', '),
                                          gpa5: opportunity['GPA out of 5']
                                                  is double
                                              ? opportunity['GPA out of 5']
                                              : double.tryParse(opportunity[
                                                          'GPA out of 5']
                                                      .toString()) ??
                                                  0.0,
                                          gpa4: opportunity['GPA out of 4']
                                                  is double
                                              ? opportunity['GPA out of 4']
                                              : double.tryParse(opportunity[
                                                          'GPA out of 4']
                                                      .toString()) ??
                                                  0.0,
                                          opportunityId: null,
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
                ),
    );
  }

  double correctSize(BuildContext context, double px) {
    return px / MediaQuery.of(context).devicePixelRatio;
  }
}

bool isSameOpportunity(Map<String, dynamic> a, Map<String, dynamic> b) {
  final titleA = (a['Job Title'] ?? a['jobTitle'] ?? '').trim();
  final titleB = (b['Job Title'] ?? b['jobTitle'] ?? '').trim();

  final idA = a['id'] ?? '';
  final idB = b['id'] ?? '';

  // Firestore Opp
  if (idA.isNotEmpty && idB.isNotEmpty) return idA == idB;

  // CSV Opp
  final urlA = (a['Apply url'] ??
          a['Company Apply link'] ??
          a['Job LinkedIn URL'] ??
          a['companyLink'] ??
          '')
      .trim();

  final urlB = (b['Apply url'] ??
          b['Company Apply link'] ??
          b['Job LinkedIn URL'] ??
          b['companyLink'] ??
          '')
      .trim();

  return titleA == titleB && urlA == urlB;
}
