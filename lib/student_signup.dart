import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadafi_application/signup_widget.dart';
import 'package:hadafi_application/StudentHomepage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // For encoding to base64

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

  final TextEditingController _locationController =
      TextEditingController(); // Controller for displaying selected locations

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

  // Dynamic lists for skills and certificates
  List<TextEditingController> _skillsControllers = [TextEditingController()];
  List<TextEditingController> _certificatesControllers = [
    TextEditingController()
  ];

  @override
  void initState() {
    super.initState();
    _filteredCities = _cities; // Ensure that all cities appear initially
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
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
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
                      _buildTextField('Password', _passwordController,
                          isPassword: true, validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
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

                      // Dynamic Skills input
                      _buildDynamicFields(
                          'Skills', _skillsControllers, _addSkill),
                      const SizedBox(height: 15),

                      // Dynamic Certificates input
                      _buildDynamicFields('Certificates',
                          _certificatesControllers, _addCertificate),
                      const SizedBox(height: 15),

                      _buildTextField(
                        'GPA',
                        _gpaController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your GPA';
                          }
                          final gpaRegex = RegExp(r'^\d+(\.\d{2,})?$');
                          if (!gpaRegex.hasMatch(value)) {
                            return 'Please enter a valid GPA in the format (ex: 4.80)';
                          }
                          final gpa = double.tryParse(value);
                          if (gpa == null || gpa <= 0) {
                            return 'Please enter a valid GPA greater than 0';
                          }
                          return null;
                        },
                      ),
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
                                    borderRadius: BorderRadius.circular(30)),
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

  // Function to build dynamic input fields for skills and certificates
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
                  if (index > 0) // Allow removal only for additional fields
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
          mainAxisAlignment:
              MainAxisAlignment.start, // Align button to the left
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

  // Function to add new skill field
  void _addSkill() {
    setState(() {
      _skillsControllers.add(TextEditingController());
    });
  }

  // Function to add new certificate field
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

  // Store user data in Firestore and Firebase Authentication
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return; // If the form is not valid, return early and show errors
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
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

        // Store the role as 'student'
        await _firestore.collection('Student').doc(user.uid).set({
          'name': _nameController.text,
          'email': _emailController.text,
          'password': encryptedPassword, // Store encrypted password
          'major': _majorController.text,
          'skills': skills, // Save skills as array
          'certificates': certificates, // Save certificates as array
          'gpa': _gpaController.text,
          'location': _selectedLocations,
          'uid': user.uid,
          'role': 'student', // Store the user role as 'student'
          'created_at': FieldValue.serverTimestamp(),
        });

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => StudentHomePage()));
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
          controller: _locationController, // Use the location controller
        ),
      ),
    );
  }

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
                                .startsWith(value.toLowerCase()))
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
                    // Update the location controller with the selected locations
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
}