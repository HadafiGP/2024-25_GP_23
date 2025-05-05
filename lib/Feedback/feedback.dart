import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hadafi_application/Feedback/allFeedback.dart';
import 'package:hadafi_application/StudentHomePage.dart';
import 'dart:async';

import 'package:hadafi_application/style.dart';



class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int? _rating;
  bool _ratingError = false;
  bool _isSubmitting = false;
  String _experience = '';
  bool _charLimitReached = false;
  String _networkError = '';
  StreamSubscription<QuerySnapshot>? _feedbackListener;

  final uid = FirebaseAuth.instance.currentUser?.uid;
  final _formKey = GlobalKey<FormState>();

  Future<bool> _checkInternetConnection() async {
    try {
      var connectivityResult = await Connectivity()
          .checkConnectivity()
          .timeout(const Duration(seconds: 3));
      return connectivityResult != ConnectivityResult.none;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _feedbackListener?.cancel();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    setState(() {
      _ratingError = _rating == null;
    });

    if (!_formKey.currentState!.validate() || _rating == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Row(
              children: [
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
      });
      return;
    }

    bool hasInternet = await _checkInternetConnection();
    if (!hasInternet) {
      if (mounted) {
        setState(() {
          _networkError =
              'Network timeout. Please check your internet connection.';
        });
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            setState(() {
              _networkError = '';
            });
          }
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isSubmitting = true;
        _networkError = '';
      });
    }

    final DateTime submitTime = DateTime.now();
    final String attemptedExperience = _experience;
    final int? attemptedRating = _rating;

    try {
      await FirebaseFirestore.instance.collection('Feedback').add({
        'uid': uid,
        'rating': _rating,
        'experience': _experience,
        'timestamp': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 5));

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text('Feedback submitted successfully!'),
              duration: Duration(seconds: 2),
            ),
          );
        });
      }

      if (mounted) {
        setState(() {
          _rating = null;
          _experience = '';
          _charLimitReached = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AllFeedbackScreen()),
        );
      }
      _formKey.currentState!.reset();
    } catch (e) {
      if (mounted) {
        setState(() {
          _networkError =
              'Network timeout. Please check your internet connection.';
        });
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            setState(() {
              _networkError = '';
            });
          }
        });

        _feedbackListener?.cancel();
        _feedbackListener = FirebaseFirestore.instance
            .collection('Feedback')
            .where('uid', isEqualTo: uid)
            .snapshots()
            .listen((snapshot) {
          bool feedbackMatched = false;

          for (var doc in snapshot.docs) {
            if (doc.metadata.hasPendingWrites) {
              continue;
            }
            var data = doc.data() as Map<String, dynamic>;
            var docTimestamp = (data['timestamp'] as Timestamp?)?.toDate();

            if (data['experience'] == attemptedExperience &&
                data['rating'] == attemptedRating &&
                docTimestamp != null &&
                docTimestamp.isAfter(submitTime)) {
              feedbackMatched = true;
              break;
            }
          }

          if (feedbackMatched) {
            _feedbackListener?.cancel();

            if (mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text('Feedback submitted successfully!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              });

              setState(() {
                _rating = null;
                _experience = '';
                _charLimitReached = false;
              });
              _formKey.currentState!.reset();
            }
          }
        });

        Future.delayed(const Duration(seconds: 120), () {
          _feedbackListener?.cancel();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
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
      appBar: AppBar(
        title:
            const Text('Write Feedback', style: TextStyle(color: Colors.white)),
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
                child: Center(
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF113F67),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Leaving feedback helps other users know what to expect and helps us make Hadafi even better. Your feedback will be public and visible to others.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 152, 161, 168),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Divider(thickness: 1, color: Colors.grey[400]),
                      const SizedBox(height: 10),
                      const Text(
                        'How was your experience?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF113F67),
                        ),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF113F67),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        maxLines: 5,
                        maxLength: 500,
                        decoration: InputDecoration(
                          labelText: 'Type Here',
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 152, 161, 168),
                          ),
                          border: OutlineInputBorder(),
                          counterStyle: TextStyle(
                            color: _charLimitReached ? Colors.red : Colors.grey,
                          ),
                          alignLabelWithHint: true,
                        ),
                        onChanged: (value) {
                          _experience = value;
                          if (value.length >= 500 && !_charLimitReached) {
                            setState(() {
                              _charLimitReached = true;
                            });
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(
                                    'You\'ve reached the maximum character limit!',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            });
                          } else if (value.length < 500 && _charLimitReached) {
                            setState(() {
                              _charLimitReached = false;
                            });
                          }
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
                                // style: ElevatedButton.styleFrom(
                                //   shape: RoundedRectangleBorder(
                                //     borderRadius: BorderRadius.circular(8),
                                //   ),
                                //   minimumSize: const Size(double.infinity, 50),
                                //   backgroundColor: const Color(0xFF113F67),
                                // ),
                                style: kMainButtonStyle,
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
