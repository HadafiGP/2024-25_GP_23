import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/StudentHomePage.dart';
import 'package:hadafi_application/favoriteProvider.dart';
import 'package:hadafi_application/OpportunityDetailsPage.dart';
import 'package:hadafi_application/button.dart';
import 'package:hadafi_application/StudentHomePage.dart';

class FavoritePage extends ConsumerWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteOpp = ref.watch(favoriteProvider).favOpportunities;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F9FB),
      drawer: const HadafiDrawer(),
      appBar: AppBar(
        title: const Text(
          "Favorite List",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF113F67),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: favoriteOpp.isEmpty
          ? const Center(
              child: Text(
                "No favorites yet!",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: favoriteOpp.length,
              itemBuilder: (context, index) {
                final opportunity = favoriteOpp[index];

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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                      title: Text(
                        opportunity['Job Title'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF113F67),
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          opportunity['Company Name'] ?? "Unknown Company",
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 28.0,
                            ),
                            onPressed: () {
                              ref.read(favoriteProvider.notifier).toggleFavorite(opportunity);
                            },
                          ),
                          SizedBox(
                            height: 35,
                            child: GradientButton(
                              text: "More",
                              gradientColors: [
                                const Color(0xFF113F67),
                                Color.fromARGB(255, 105, 185, 255),
                              ],
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OpportunityDetailsPage(
                                      jobTitle: opportunity['Job Title'],
                                      companyName: opportunity['Company Name'] ?? "Unknown",
                                      description: opportunity['Description'] ?? "No description available.",
                                      applyUrl: opportunity['Apply url'] ?? "",
                                      similarity: 0.0,
                                      skills: List<String>.from(opportunity['Skills'] ?? []),
                                      location: (opportunity['Locations'] ?? []).join(', '),
                                      gpa5: opportunity['GPA out of 5'] ?? 0.0,
                                      gpa4: opportunity['GPA out of 4'] ?? 0.0,
                                    ),
                                  ),
                                );
                              },
                            ),
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
}
