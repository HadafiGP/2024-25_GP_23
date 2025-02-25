import 'package:flutter/material.dart';
import 'package:hadafi_application/Community/add_mods.dart';
import 'package:hadafi_application/Community/edit_community_screen.dart';

class ModTools extends StatelessWidget {
  final String name;

  const ModTools({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF113F67), // Matches profile page
        centerTitle: true, // ✅ Ensures the title is perfectly centered
        title: const Text(
          'Mod Tools', // ✅ Now perfectly centered
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Add moderators
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.manage_accounts, color: Colors.blue),
                title: const Text(
                  'Manage Moderators',
                  style: TextStyle(fontSize: 16),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddMods(name: name),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            //Edit community
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.edit, color: Colors.green),
                title: const Text(
                  'Edit Community',
                  style: TextStyle(fontSize: 16),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditCommunityScreen(name: name),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
