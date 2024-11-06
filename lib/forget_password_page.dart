import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  String? _errorMessage;

  Future<void> _resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Password reset email sent. Please check your inbox."),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Go back to the login screen
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
      });
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return "The email address is invalid. Please enter a valid email address.";
      case 'user-not-found':
        return "No account found with this email. Please check your email address or sign up.";
      default:
        return "An unexpected error occurred. Please try again later.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF113F67),
        iconTheme: IconThemeData(
          color: Colors.white, // Make the back arrow white
        ),
        title: Text(
          "Reset Password",
          style: TextStyle(
            color: Colors.white, // Make the title text white
            fontSize: 20,
          ),
        ),
        centerTitle: true, // This will perfectly center the title
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter your email address to receive a password reset link.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                errorText: _errorMessage,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF113F67),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Send Reset Link",
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(
                        0xFFF3F9FB), // Match text color and font size
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
