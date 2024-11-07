import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadafi_application/signup_widget.dart';
import 'package:hadafi_application/StudentHomepage.dart';
import 'package:hadafi_application/TrainingProviderHomepage.dart';
import 'package:hadafi_application/forget_password_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Form key
  bool _isLoading = false;
  String? _errorMessage; // To hold the generic error message

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
                          'Login',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF113F67),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildEmailField(),
                        const SizedBox(height: 15),
                        _buildPasswordField(),
                        const SizedBox(height: 15),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ForgetPasswordPage()),
                              );
                            },
                            child: Text(
                              'Forget Password?',
                              style: TextStyle(
                                color: Color(0xFF113F67),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_errorMessage !=
                            null) // Display generic error message if it exists
                          Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 15),
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
                                  'Login',
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

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if form validation fails
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null; // Reset the generic error message
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      User? user = userCredential.user;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Verification email sent. Please verify to proceed.')),
        );
      } else if (user != null && user.emailVerified) {
        // Check Firestore for the user's role
        final userDoc =
            await _firestore.collection('Student').doc(user.uid).get();

        if (userDoc.exists && userDoc.get('role') == 'student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => StudentHomePage()),
          );
        } else {
          final providerDoc = await _firestore
              .collection('TrainingProvider')
              .doc(user.uid)
              .get();

          if (providerDoc.exists &&
              providerDoc.get('role') == 'training_provider') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => TrainingProviderHomePage()),
            );
          } else {
            setState(() {
              _errorMessage = 'Role not found. Please contact support.';
            });
          }
        }
      }
    } on FirebaseAuthException {
      setState(() {
        _errorMessage = 'Invalid email or password';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
