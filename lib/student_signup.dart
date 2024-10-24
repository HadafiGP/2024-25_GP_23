import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadafi_application/signup_widget.dart';
import 'package:hadafi_application/StudentHomepage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:async';

class StudentSignupScreen extends StatefulWidget {
  const StudentSignupScreen({Key? key}) : super(key: key);

  @override
  _StudentSignupScreenState createState() => _StudentSignupScreenState();
}

class _StudentSignupScreenState extends State<StudentSignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _gpaController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String? _emailError; // To hold the "email already in use" error
  List<String> _selectedLocations = [];
  List<String> _filteredCities = [];
  bool _isLoading = false;
  double? _selectedGpaScale; // Store selected GPA scale
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

  // Lists for skills and certificates
  List<TextEditingController> _skillsControllers = [TextEditingController()];
  List<TextEditingController> _certificatesControllers = [
    TextEditingController()
  ];

  @override
  void initState() {
    super.initState();
    _filteredCities = _cities;
  }

  @override
  Widget build(BuildContext context) {
    return SignupWidget(
      child: Column(
        children: [
          const SizedBox(height: 125),
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
                        'Student Sign Up',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF113F67),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField('Full Name', _nameController,
                          validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      }),
                      const SizedBox(height: 15),

                      _buildTextField(
                        'Email',
                        _emailController,
                        validator: (value) {
                          if (_emailError != null) {
                            return _emailError; // Display the email aleardy in use error
                          }
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          final emailRegex = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildTextField('Password', _passwordController,
                          isPassword: true, validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password.';
                        }

                        // Password constraints:
                        final passwordValid = value.length >= 8 &&
                            RegExp(r'[A-Z]').hasMatch(value) &&
                            RegExp(r'[a-z]').hasMatch(value) &&
                            RegExp(r'[0-9]').hasMatch(value) &&
                            RegExp(r'[!@#\$&*~]').hasMatch(value);

                        if (!passwordValid) {
                          return 'The password must be at least 8 characters long, include \nuppercase/lowercase letters, and at least one number \nand special character.';
                        }

                        return null;
                      }),
                      const SizedBox(height: 15),
                      _buildTextField('Major', _majorController,
                          validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your major';
                        }
                        return null;
                      }),
                      const SizedBox(height: 15),

// GPA Scale and GPA Field Placement
                      Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Align buttons to the left
                        children: [
                          // GPA Input Field
                          _buildTextField(
                            'GPA',
                            _gpaController,
                            validator: (value) {
                              if (_selectedGpaScale == null) {
                                return 'Please select a GPA scale';
                              }

                              if (value == null || value.isEmpty) {
                                return 'Please enter your GPA';
                              }

                              final gpa = double.tryParse(value);
// Check if GPA is null (i.e., user did not enter a valid number)
                              if (gpa == null) {
                                return 'Please enter a valid number for GPA.';
                              }

// Check if GPA is 0
                              if (gpa == 0) {
                                return 'GPA cannot be 0. Please enter a valid GPA.';
                              }

// Check if GPA exceeds the selected scale
                              if (gpa > _selectedGpaScale!) {
                                return 'Please enter a valid GPA greater than 0 and up to ${_selectedGpaScale!.toStringAsFixed(2)}';
                              }

                              // Ensure GPA is in correct format
                              final gpaRegex = RegExp(r'^\d+(\.\d{1,2})?$');
                              if (!gpaRegex.hasMatch(value)) {
                                return 'Please enter a valid GPA with up to two decimal\nplaces (e.g., 4, 4.00, or 4.90)';
                              }

                              //If GPA is a whole number, format it as x.00 (e.g., 3 becomes 3.00)
                              if (gpa % 1 == 0) {
                                _gpaController.text = gpa.toStringAsFixed(2);
                              } else {
                                _gpaController.text = gpa.toStringAsFixed(
                                    2); // Ensure two decimal places
                              }

                              return null;
                            },
                            enabled: _selectedGpaScale !=
                                null, // Disable until scale is selected
                          ),

                          const SizedBox(height: 5),

                          // GPA Scale Buttons
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedGpaScale = 4.0;
                                    _gpaController
                                        .clear(); // Clear the GPA field if scale changes
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _selectedGpaScale == 4.0
                                      ? Color(0xFF113F67)
                                      : Colors.grey,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 11, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  'GPA Scale 4.00',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedGpaScale = 5.0;
                                    _gpaController
                                        .clear(); // Clear the GPA field if scale changes
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _selectedGpaScale == 5.0
                                      ? Color(0xFF113F67)
                                      : Colors.grey,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 11, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  'GPA Scale 5.00',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),
                      _buildDynamicFields(
                          'Skill', _skillsControllers, _addSkill),
                      const SizedBox(height: 15),
                      _buildDynamicFields('Certificate',
                          _certificatesControllers, _addCertificate),
                      const SizedBox(height: 15),
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
                                    color: const Color(0xFFF3F9FB)),
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

  // Dynamic input fields for skills and certificates
  Widget _buildDynamicFields(
      String label, List<TextEditingController> controllers, Function() onAdd) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          itemCount: controllers.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controllers[index],
                      decoration: InputDecoration(
                        labelText: '$label ${index + 1}',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter at least one $label';
                        }
                        return null;
                      },
                    ),
                  ),
                  if (index > 0) // Remove only for additional fields
                    IconButton(
                      icon: Icon(Icons.remove_circle),
                      onPressed: () {
                        setState(() {
                          controllers.removeAt(index);
                        });
                      },
                    ),
                ],
              ),
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: onAdd,
              icon: Icon(Icons.add_circle),
              label: Text('Add $label'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isPassword = false,
      bool enabled = true,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildLocationSelector() {
    return GestureDetector(
      onTap: () {
        _showLocationDialog();
      },
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'Select Locations',
            suffixIcon: const Icon(Icons.arrow_drop_down),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          controller: _locationController,
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

  void _showLocationDialog() {
    setState(() {
      _filteredCities = _cities;
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
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        // If search field is empty, reset the filtered list to show all cities
                        if (value.isEmpty) {
                          _filteredCities = _cities;
                        } else {
                          // Filter cities starting with the typed letter(s)
                          _filteredCities = _cities
                              .where((city) => city
                                  .toLowerCase()
                                  .startsWith(value.toLowerCase()))
                              .toList();
                        }
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

  // Add new skill field
  void _addSkill() {
    setState(() {
      _skillsControllers.add(TextEditingController());
    });
  }

  // Add new certificate field
  void _addCertificate() {
    setState(() {
      _certificatesControllers.add(TextEditingController());
    });
  }

  // Encrypt password using SHA-256
  String _encryptPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Store user data in Firestore and Firebase Authentication with Timeout and Error Handling
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return; // If the form is not valid, return and show errors
    }

    setState(() {
      _isLoading = true;
      _emailError = null; // Reset the email error before sign-up attempt
    });

    try {
      // Set a timeout of 15 seconds for Firebase sign-up operation
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          )
          .timeout(Duration(seconds: 15)); // Timeout for Firebase Auth

      User? user = userCredential.user;

      if (user != null) {
        // Encrypt password before saving it to Firestore
        String encryptedPassword = _encryptPassword(_passwordController.text);

        // Collect skills and certificates from dynamic input fields
        List<String> skills =
            _skillsControllers.map((controller) => controller.text).toList();
        List<String> certificates = _certificatesControllers
            .map((controller) => controller.text)
            .toList();

        // Store user data in Firestore
        await _firestore.collection('Student').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': encryptedPassword, // Store encrypted password
          'major': _majorController.text.trim(),
          'skills': skills, // Save skills as array
          'certificates': certificates, // Save certificates as array
          'gpa': _gpaController.text.trim(),
          'location': _selectedLocations,
          'uid': user.uid,
          'role': 'student', // Store the user role as 'student'
        });

        // Navigate to Student Home Page after successful sign-up
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StudentHomePage()),
        );
      }
    } on TimeoutException {
      // Handle timeout error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sign-up timed out. Please check your connection and try again.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(() {
          _emailError = 'This email is already in use. Please log in.';
        });
      } else {
        // Show general Firebase error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sign-up failed. Please check your internet connection, or try again later.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
