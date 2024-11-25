import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hadafi_application/success_reset_page.dart';
import 'package:hadafi_application/signup_widget.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  _ForgetPasswordPageState createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  static const int maxRequests = 3; // Maximum number of allowed requests
  static const int banDuration = 60; // Ban duration in seconds

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    // Get current time
    final int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Load attempts and last request time from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    int attempts = prefs.getInt('attempts') ?? 0;
    int lastRequestTime = prefs.getInt('lastRequestTime') ?? 0;

    // Check if the user is banned
    if (attempts >= maxRequests &&
        currentTime - lastRequestTime < banDuration) {
      setState(() {
        _errorMessage = 'You have reached the limit. Please try again later.';
      });
      return;
    }

    // If not banned, proceed
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear any previous error message
    });

    try {
      // Send password reset email
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());

      // Update attempts and last request time
      prefs.setInt('attempts', attempts + 1);
      prefs.setInt('lastRequestTime', currentTime);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResetSuccessPage(
            onResendEmail: _resendResetEmail,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your connection.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later.';
          break;
        default:
          errorMessage =
              e.message ?? 'An unexpected error occurred. Please try again.';
      }
      setState(() {
        _errorMessage = errorMessage; // Update the error message
      });
    } finally {
      setState(() {
        _isLoading = false; // Stop the loading indicator
      });
    }
  }

  Future<void> _resendResetEmail() async {
    // Similar logic for resend email can be applied here if needed
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your connection.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later.';
          break;
        default:
          errorMessage =
              e.message ?? 'An unexpected error occurred. Please try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SignupWidget(
        child: Column(
          children: [
            const SizedBox(height: 125),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F9FB),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 5,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF113F67),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Enter your email to receive a password reset link.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        _buildTextField('Email', _emailController),
                        const SizedBox(height: 25),
                        if (_errorMessage !=
                            null) // Display error message if available
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        _isLoading
                            ? CircularProgressIndicator() // Show loading indicator while processing
                            : ElevatedButton(
                                onPressed: _resetPassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF113F67),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 50,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  'Send Reset Link',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: const Color(0xFFF3F9FB),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        // Validate email field
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        final emailRegex =
            RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
        if (!emailRegex.hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }
}
