import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OpportunityDetailsPage extends StatelessWidget {
  final String jobTitle;
  final String companyName;
  final String description;
  final String applyUrl;
  final double similarity;

  const OpportunityDetailsPage({
    super.key,
    required this.jobTitle,
    required this.companyName,
    required this.description,
    required this.applyUrl,
    required this.similarity,
  });

  @override
  Widget build(BuildContext context) {
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              jobTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF113F67),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Company: $companyName",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF113F67),
              ),
            ),
            const SizedBox(height: 10),
             Text(
              "About: $companyName",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(description),
            const SizedBox(height: 10),
            Text(
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
            const Spacer(), 
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (applyUrl.isNotEmpty && await canLaunch(applyUrl)) {
                    await launch(applyUrl);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Could not open the URL"),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF113F67),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 12), // Adjust button size
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Apply Now",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20), 
          ],
        ),
      ),
    );
  }
}
