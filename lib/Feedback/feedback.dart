import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadafi_application/StudentHomePage.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int? _rating;
  bool _ratingError = false;
  bool _isSubmitting = false;
  String _networkError = '';
  String _experience = '';

  final uid = FirebaseAuth.instance.currentUser?.uid;



  final _formKey = GlobalKey<FormState>();


  Future<void> _submitFeedback() async {
    setState(() {
      _ratingError = _rating == null;
      _isSubmitting = true;
      _networkError = '';
    });

    if (_formKey.currentState!.validate() &&
        _rating != null) {
      try {
        await FirebaseFirestore.instance.collection('Feedback').add({
          'uid': uid,
          'rating': _rating,
          'experience': _experience,
          'timestamp': FieldValue.serverTimestamp(),
        }).timeout(const Duration(seconds: 10), onTimeout: () {
          throw TimeoutException("Network timeout");
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color.fromARGB(255, 0, 118, 208),
              content: Row(
                children: const [
                  Icon(Icons.check_circle_outline, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Feedback submitted!',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              duration: Duration(seconds: 2),
            ),
          );
        }

        setState(() {
          _rating = null;
          _experience = '';
          _ratingError = false;
        });

        _formKey.currentState!.reset();
      } on TimeoutException {
        setState(() {
          _networkError = 'No internet connection. Please check your network and try again.';
        });
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _networkError = '';
            });
          }
        });
      } catch (e) {
        setState(() {
          _networkError = 'Failed to submit. Please try again later.';
        });
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            setState(() {
              _networkError = '';
            });
          }
        });
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    } else {
      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC3545),
          content: Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Please complete all fields',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildStar(int index) {
    return IconButton(
      icon: Icon(
        Icons.star,
        color: (_rating != null && index <= _rating!)
            ? Colors.amber[700]
            : Colors.grey[300],
      ),
      onPressed: () {
        setState(() {
          _rating = index;
          _ratingError = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      drawer: const HadafiDrawer(),
      appBar: AppBar(
        title: const Text('Feedback', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF113F67),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_networkError.isNotEmpty)
              Container(
                width: double.infinity,
                color: Colors.red,
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.white),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        _networkError,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Share Your Experience with Others',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Leaving feedback helps other users know what to expect and helps us make Hadafi even better. Keep in mind: your feedback will be public and visible to others.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 152, 161, 168),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Divider(thickness: 1, color: Colors.grey[400]),
                      const SizedBox(height: 5),

                      const Text(
                        'How was your experience?',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children:
                            List.generate(5, (index) => _buildStar(index + 1)),
                      ),
                      if (_ratingError)
                        const Padding(
                          padding: EdgeInsets.only(top: 4, left: 4),
                          child: Text(
                            'Please select a rating',
                            style: TextStyle(
                              color: Color(0xFFDC3545),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      const Text(
                        'Write About Your Experience',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        maxLines: 5,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          labelText: 'Type Here',
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 152, 161, 168),
                          ),
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        onChanged: (value) {
                          _experience = value;
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please write something'
                            : null,
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: _isSubmitting
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _submitFeedback,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  minimumSize: const Size(double.infinity, 50),
                                  backgroundColor: const Color(0xFF113F67),
                                ),
                                child: const Text(
                                  "Submit",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}