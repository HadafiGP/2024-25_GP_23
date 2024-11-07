import 'package:flutter/material.dart';
import 'package:hadafi_application/logIn_page.dart';
import 'package:hadafi_application/signup_widget.dart';
import 'package:flutter/gestures.dart';

class ResetSuccessPage extends StatelessWidget {
  final VoidCallback onResendEmail;

  ResetSuccessPage({required this.onResendEmail});

  @override
  Widget build(BuildContext context) {
    return SignupWidget(
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 125),
            Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 20),
            Text(
              'Success!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF113F67),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'A password reset email has been sent. Please check your email to proceed.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
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
                'Back to Login',
                style: TextStyle(
                  fontSize: 18,
                  color: const Color(0xFFF3F9FB),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                onResendEmail();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Reset email resent successfully')),
                );
              },
              child: Text(
                "Did not receive the link? Check your spam folder or click here to resend the email.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF113F67),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
