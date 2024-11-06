import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hadafi_application/TrainingProviderHomepage.dart';
import 'package:hadafi_application/StudentHomepage.dart';
import 'package:hadafi_application/signup_widget.dart';
import 'package:hadafi_application/forget_password_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  // Login function
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Attempt to log in with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Fetch the user's role from Firestore
        DocumentSnapshot userDoc =
            await _firestore.collection('Student').doc(user.uid).get();

        if (userDoc.exists && userDoc['role'] == 'student') {
          // Navigate to StudentHomePage if the user is a student
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => StudentHomePage()),
          );
        } else {
          // If not found in Student collection, check in TrainingProvider collection
          userDoc = await _firestore
              .collection('TrainingProvider')
              .doc(user.uid)
              .get();

          if (userDoc.exists && userDoc['role'] == 'training_provider') {
            // Navigate to TrainingProviderHomePage if the user is a training provider
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => TrainingProviderHomePage()),
            );
          } else {
            // If role is not found, log out the user and show an error message
            await _auth.signOut();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("This account is not found. Please sign up."),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      String message;

      switch (e.code) {
        case 'invalid-email':
        case 'user-not-found':
        case 'wrong-password':
          message = "The email or password is incorrect. Please try again.";
          break;
        case 'user-disabled':
          message =
              "This account has been disabled. Please contact support for assistance.";
          break;
        case 'too-many-requests':
          message =
              "You have made too many login attempts. Please try again later or reset your password.";
          break;
        default:
          message = "An unexpected error occurred. Please try again later.";
          break;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SignupWidget(
      child: Column(
        children: [
          const SizedBox(height: 150),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
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
                        'Log In',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF113F67),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Email field
                      _buildTextField(
                        'Email',
                        _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email.';
                          }
                          final emailRegex = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email address.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Password field
                      _buildTextField(
                        'Password',
                        _passwordController,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password.';
                          }
                          return null;
                        },
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            // Navigate to ForgotPasswordScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Color(0xFF113F67),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Login button with loading indicator
                      _isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _login,
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
                                'Log In',
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
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
