import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_widget.dart';
import 'TrainingProviderHomePage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // For encoding to base64

class TrainingProviderSignupScreen extends StatefulWidget {
  const TrainingProviderSignupScreen({super.key});

  @override
  _TrainingProviderSignupScreenState createState() =>
      _TrainingProviderSignupScreenState();
}

class _TrainingProviderSignupScreenState
    extends State<TrainingProviderSignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  List<String> _selectedLocations = [];
  List<String> _filteredCities = [];
  bool _isLoading = false;

  List<String> _cities = [
    'Abha',
    'Al Ahsa',
    'Al Khobar',
    'Al Qassim',
    'Dammam',
    'Hail',
    'Jeddah',
    'Jizan',
    'Jubail',
    'Mecca',
    'Medina',
    'Najran',
    'Riyadh',
    'Tabuk',
    'Taif',
  ];

  @override
  void initState() {
    super.initState();
    _filteredCities = _cities; // Initialize filtered cities
  }

  @override
  Widget build(BuildContext context) {
    return SignupWidget(
      child: Column(
        children: [
          const SizedBox(height: 150), // Space to show top background
          Expanded(
            child: Container(
              width: double.infinity, // Full width
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F9FB),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ), // Rounded corners only at the top
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3), // Darker shadow
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
                        'Training Provider Sign Up',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF113F67),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Company Name Field
                      _buildTextField(
                        'Company Name',
                        _companyNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your company name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Company Email Field
                      _buildTextField(
                        'Company Email',
                        _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your company email';
                          }
                          final emailRegex = RegExp(
                              r'^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Password Field
                      _buildTextField(
                        'Password',
                        _passwordController,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Location Selector
                      _buildLocationSelector(),
                      const SizedBox(height: 25),

                      _isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _signUp,
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
                                'Sign Up',
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

  // Reusable TextField widget with validation
  Widget _buildTextField(String label, TextEditingController controller,
      {bool isPassword = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Location Selector widget for training providers
  Widget _buildLocationSelector() {
    return GestureDetector(
      onTap: () {
        _showLocationDialog();
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: _locationController,
          decoration: InputDecoration(
            labelText: 'Select Location',
            suffixIcon: const Icon(Icons.arrow_drop_down),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator: (value) {
            if (_selectedLocations.isEmpty) {
              return 'Please select at least one location';
            }
            return null;
          },
        ),
      ),
    );
  }

  // Function to show location selection dialog
  void _showLocationDialog() {
    setState(() {
      _filteredCities = _cities; // Ensure cities are loaded when dialog opens
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Column(
                children: [
                  Text('Select Locations'),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                        labelText: 'Search Cities',
                        prefixIcon: Icon(Icons.search)),
                    onChanged: (value) {
                      setState(() {
                        _filteredCities = _cities
                            .where((city) => city
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: _filteredCities.map((city) {
                    return CheckboxListTile(
                      title: Text(city),
                      value: _selectedLocations.contains(city),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedLocations.add(city);
                          } else {
                            _selectedLocations.remove(city);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    _locationController.text = _selectedLocations.join(', ');
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Encrypt password using SHA-256
  String _encryptPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Store user data in Firestore and Firebase Authentication
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return; // If the form is not valid, return early and show errors
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user in Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Encrypt password before saving it to Firestore
        String encryptedPassword = _encryptPassword(_passwordController.text);

        // Store company information in Firestore (TrainingProvider collection)
        await _firestore.collection('TrainingProvider').doc(user.uid).set({
          'company_name': _companyNameController.text,
          'email': _emailController.text,
          'password': encryptedPassword, // Store encrypted password
          'location': _selectedLocations, // Store selected locations
          'uid': user.uid,
          'role': 'training_provider', // Storing the user role
          'created_at': FieldValue.serverTimestamp(),
        });

        // Navigate to TrainingProviderHomePage (if created)
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => TrainingProviderHomePage()));
      }
    } catch (e) {
      String errorMessage = 'Sign-up failed. Please try again.';
      if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
        errorMessage = 'This email is already in use. Please log in.';
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
