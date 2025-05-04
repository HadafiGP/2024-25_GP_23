import 'package:flutter/material.dart';
import 'package:hadafi_application/Community/filtered_community_screens.dart';

class ExplorePage extends StatelessWidget {
  final List<Map<String, dynamic>> topics = [
    {
      "category": "💼 Training Opportunities Related",
      "topics": [
        "Internships",
        "COOP Training",
        'Remote',
        'On-site',
        'Hybrid',
        'Paid',
        'Unpaid',
        "Over The Summer",
        'Full-time',
        'Part-time',
        'Government Sector',
        'Private Sector',
        'Training search tips',
      ]
    },
    {
      "category": "📚 Industry-Specific Discussions",
      "topics": [
        'Business & Management',
        'Education & Training',
        'Information Technology & Computer Science',
        'Engineering & Industrial Technologies',
        'Healthcare & Medical Fields',
        'Arts, Design & Creative Media',
        'Humanities & Social Sciences',
        'Law, Government & Public Policy',
        'Science & Mathematics',
        'Hospitality & Tourism'
      ]
    },
    {
      "category": "🌱 Soft Skills  & Personal Development",
      "topics": [
        "Communication Skills",
        "Leadership & Teamwork",
        "CV advice",
        'Workplace Etiquette',
        'Presentation & Public Speaking Skills',
        'Interview Preparation'
      ]
    },
    {
      "category": "🏫 University Life & Support",
      "topics": [
        "University Advice",
        "Scholarships & Grants",
        "Balancing Study & Other Work",
        'Clubs, Volunteering & Extracurricular',
        'COOP Report Templates & Examples'
      ]
    },
    {
      "category": "🌐 Student Networking & Growth",
      "topics": [
        'Hackathons & Competition',
        "Internship Meetups",
        'Networking for Introverts',
        'Networking Tips',
        'Industry Expert Q&A',
        "Events & Career Fairs",
        'Mentorship & Career Guidance',
        'Professional Associations',
        'Online Networking & Profile Building',
        'Student Conferences & Summits',
      ]
    },
    {
      "category": "📍 Locations",
      "topics": [
        'Abha',
        'Al Ahsa',
        'Al-Kharj',
        'Al Khobar',
        'Al Qassim',
        'Baha',
        'Bisha',
        'Dammam',
        'Dhahran',
        'Hail',
        'Jeddah',
        'Jizan',
        'Jubail',
        'Mecca',
        'Medina',
        'Najran',
        'Riyadh',
        'Tabuk',
        'Taif',
        'Other'
      ]
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Color(0xFF113F67), // ✅ Hadafi theme color
      //   automaticallyImplyLeading: false, // ❌ Remove Back Arrow
      //   elevation: 0, // Remove shadow
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // ✅ "Explore communities by topic" Title
            Text(
              "Explore communities by topic",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF113F67), // ✅ Hadafi theme color
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 16), // Space before topics

            // ✅ List of categories
            ...topics.map(
                (categoryData) => _buildCategorySection(context, categoryData)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
      BuildContext context, Map<String, dynamic> categoryData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          categoryData["category"],
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: (categoryData["topics"] as List<String>).map((topic) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF113F67),
                side: BorderSide(color: Color(0xFF113F67)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FilteredCommunityScreen(topic: topic),
                  ),
                );
              },
              child: Text(topic),
            );
          }).toList(),
        ),
        SizedBox(height: 16), // Space between categories
      ],
    );
  }
}
