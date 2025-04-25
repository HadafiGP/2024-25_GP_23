import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hadafi_application/studentProfilePage.dart';

class ApplyNowButton extends StatefulWidget {
  final String opportunityId;

  const ApplyNowButton({super.key, required this.opportunityId});

  @override
  State<ApplyNowButton> createState() => _ApplyNowButtonState();
}

class _ApplyNowButtonState extends State<ApplyNowButton> {
  bool isApplied = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkIfApplied();
  }

  Future<void> checkIfApplied() async {
    final user = FirebaseAuth.instance.currentUser;
    final doc = await FirebaseFirestore.instance
        .collection('opportunity')
        .doc(widget.opportunityId)
        .collection('candidates')
        .doc(user!.uid)
        .get();

    setState(() {
      isApplied = doc.exists;
      isLoading = false;
    });
  }

  Future<void> handleApplyNow() async {
    final user = FirebaseAuth.instance.currentUser;
    final studentDoc = await FirebaseFirestore.instance
        .collection('Student')
        .doc(user!.uid)
        .get();
    final studentData = studentDoc.data();

    final cv = studentData?['cv'] ?? '';

    if (cv.isEmpty) {
      // 🚫 No CV uploaded — show dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Complete Your Profile"),
          content: const Text("Please upload your CV to apply."),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text("Go to Profile"),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(), // import this page
                  ),
                );
              },
            ),
          ],
        ),
      );
      return;
    }

    // ✅ CV exists — proceed with application
    await FirebaseFirestore.instance
        .collection('opportunity')
        .doc(widget.opportunityId)
        .collection('candidates')
        .doc(user.uid)
        .set({
      'uid': user.uid,
      'appliedAt': Timestamp.now(),
      'cv': studentData?['cv'] ?? '',
      'name': studentData?['name'] ?? '',
      'email': studentData?['email'] ?? '',
      'major': studentData?['major'] ?? '',
      'gpa': studentData?['gpa'] ?? '',
      'gpaScale': studentData?['gpaScale'] ?? '',
      'skills': studentData?['skills'] ?? [],
      'location': studentData?['location'] ?? [],
      'nationality': studentData?['nationality'] ?? '',
      'profilePic': studentData?['profilePic'] ?? '',
    });

    setState(() {
      isApplied = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Thank you! Your application has been submitted."),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ElevatedButton(
      onPressed: isApplied
          ? null
          : () async {
              await handleApplyNow();
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: isApplied ? Colors.green : const Color(0xFF096499),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 6,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isApplied ? Icons.check_circle : Icons.send,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            isApplied ? "Applied" : "Apply Now",
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
