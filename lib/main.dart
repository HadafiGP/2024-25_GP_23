import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hadafi_application/CV.dart';
import 'package:hadafi_application/favoriteProvider.dart';
import 'package:hadafi_application/welcome.dart';
import 'package:hadafi_application/Community/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final firebaseConfig = FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_API_KEY']!,
    appId: dotenv.env['FIREBASE_APP_ID']!,
    messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
    projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
  );

  await Firebase.initializeApp(options: firebaseConfig);

  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    ref.read(favoriteProvider).loadFavorites();

  //    // تسجيل خروج مؤقت بعد أول تشغيل
  // Future.microtask(() async {
  //   await FirebaseAuth.instance.signOut();
  // });

    return authState.when(
      data: (user) {
        if (user != null) {
          return ref.watch(userDataProvider(user.uid)).when(
            data: (userData) {
              if (userData != null) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Hadafi',
                  theme: ThemeData(
                    colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF113F67)),
                    useMaterial3: true,
                  ),
                  home: WelcomeScreen(),
                );
              }
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                home: Scaffold(body: Center(child: Text("User data loading..."))),
              );
            },
            loading: () => MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(body: Center(child: CircularProgressIndicator())),
            ),
            error: (err, stack) => MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(body: Center(child: Text("Error: $err"))),
            ),
          );
        } else {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Hadafi',
            home: WelcomeScreen(),
          );
        }
      },
      loading: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (err, stack) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: Text("Error: $err"))),
      ),
    );
  }
}
