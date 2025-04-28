import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CandidateDetailsPage extends StatelessWidget {
  final String name;
  final String email;
  final String major;
  final String gpa;
  final String gpaScale;
  final String nationality;
  final List<String> locationList;
  final List<String> skillsList;
  final String cv;
  final String profilePic;

  const CandidateDetailsPage({
    super.key,
    required this.name,
    required this.email,
    required this.major,
    required this.gpa,
    required this.gpaScale,
    required this.nationality,
    required this.locationList,
    required this.skillsList,
    required this.cv,
    required this.profilePic,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Candidate Details",
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF113F67),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF096499), Color(0xFF2F83C5)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8),
                ],
              ),
              child: Row(
                children: [
                  if (profilePic.isNotEmpty)
                    CircleAvatar(
                      backgroundImage: NetworkImage(profilePic),
                      radius: 30,
                    )
                  else
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, size: 30, color: Colors.white),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            infoCard("Email", email, Icons.email),
            infoCard("Major", major, Icons.school),
            infoCard("GPA", "$gpa / $gpaScale", Icons.grade),
            infoCard("Nationality", nationality, Icons.flag),
            infoCard("Location(s)", locationList.join(', '), Icons.location_on),

            Card(
              elevation: 4,
              margin: const EdgeInsets.only(top: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                title: const ListTile(
                  leading:
                      Icon(Icons.lightbulb_outline, color: Color(0xFF096499)),
                  title: Text(
                    "Skills",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                children: skillsList.map((skill) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.circle,
                            size: 8, color: Color(0xFF096499)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(skill)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            Center(
              child: cv.isNotEmpty
                  ? ElevatedButton.icon(
                      onPressed: () async {
                        final Uri url = Uri.parse(cv);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Could not open CV")    ,      duration: Duration(seconds: 2),
            backgroundColor: Colors.red,),
                          );
                        }
                      },
                      icon:
                          const Icon(Icons.picture_as_pdf, color: Colors.white),
                      label: const Text(
                        "Open CV",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF096499),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )
                  : const Text("CV not uploaded",
                      style: TextStyle(fontSize: 16)),
            ),

            const SizedBox(height: 16),

            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
                label: const Text(
                  "Close",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF096499),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoCard(String label, String value, IconData icon) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(top: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF096499)),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(value),
      ),
    );
  }
}
