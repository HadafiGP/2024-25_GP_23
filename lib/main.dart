import "package:hadafi_application/interview.dart";
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Replace with your actual Firebase project configuration
  final firebaseConfig = FirebaseOptions(
  apiKey: "AIzaSyA4_z4iyrS6YTZRx_n0qGe5sFSmcimhQUE",
  appId: "1:402403413533:android:a54f32f299f122b68e00f4",
   messagingSenderId: "402403413533",
  projectId: "hadafi-21420",
  );
  await Firebase.initializeApp(options: firebaseConfig);
  await dotenv.load(fileName: ".env");
  await checkFirestoreConnection();
 
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hadafi',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF113F67)),
        useMaterial3: true,
      ),
      home: InterviewPage(),
    );
  }
}

Future<void> checkFirestoreConnection() async {
  try {
    // Reference to Firestore collection
    CollectionReference usersCollection = FirebaseFirestore.instance.collection('User');

    // Get the document 'user1'
    DocumentSnapshot user1 = await usersCollection.doc('5r9wzBP4Ckha353u94Lk').get();

    // Check if the document exists and print the result
    if (user1.exists) {
      print("Connection successful, User data: ${user1.data()}");
    } else {
      print("Connection successful, but no user data found.");
    }
  } catch (e) {
    // Handle connection or query error
    print("Error connecting to Firestore: $e");
  }
}

