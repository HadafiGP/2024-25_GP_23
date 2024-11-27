import 'package:flutter/material.dart';
import 'package:hadafi_application/student_signup.dart';
import 'package:hadafi_application/training_provider_signup.dart';
import 'package:hadafi_application/logIn_page.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Image.asset(
            'Hadafi/images/welcome_interface.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 325), // Space to move the text down
                Flexible(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 20.0,
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            'Welcome',
                            style: TextStyle(
                              fontSize: 45.0,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF113F67),
                            ),
                          ),
                          const SizedBox(height: 8), // Reduced space here
                          Text(
                            'Start up by choosing your role!',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF113F67),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 8,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Student Sign-Up Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StudentSignupScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                              0xFFF3F9FB), // Button background color
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50, // Padding for smaller button width
                            vertical: 15, // Slightly smaller vertical padding
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                30), // More rounded corners
                          ),
                        ),
                        child: Text(
                          'Student',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF113F67), // Text color
                          ),
                        ),
                      ),
                      const SizedBox(height: 10), // Space between buttons
                      // Training Provider Sign-Up Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TrainingProviderSignupScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                              0xFFF3F9FB), // Button background color
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50, // Padding for smaller button width
                            vertical: 15, // Slightly smaller vertical padding
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                30), // More rounded corners
                          ),
                        ),
                        child: Text(
                          'Training Provider',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF113F67), // Text color
                          ),
                        ),
                      ),
                      const SizedBox(
                          height: 20), // Space between buttons and text
                      // Already have an account? Log in link
                      Text.rich(
                        TextSpan(
                          text: 'Already have an account? ',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 18,
                          ),
                          children: [
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Log in',
                                  style: TextStyle(
                                    color: Color(0xFF113F67),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.2),
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
