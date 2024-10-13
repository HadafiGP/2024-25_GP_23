import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_widget.dart';
import 'TrainingProviderHomePage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

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

// List of trusted domains for validation
List<String> trustedDomains = [
  // Government Institutions
  'mc.gov.sa',       
  'hrsd.gov.sa',     
  'tvtc.gov.sa',     

  // Educational Institutions
  'ksu.edu.sa',      
  'kau.edu.sa',      
  'psu.edu.sa',      
  'kfupm.edu.sa',    

  // Private Sector & Large Corporations
  'aramco.com',      
  'sabic.com',       
  'stc.com.sa',      
  'almarai.com',     

  // Public Sector Organizations
  'monshaat.gov.sa', 
  'scfhs.org.sa',    
  'sdaia.gov.sa',    
];

// List of exception emails that are allowed
List<String> exceptionEmails = [
  'hend@gmail.com',
  'hessaa@gmail.com',
  'duna@gmail.com',
  'jeje@gmail.com',
  'lama@gmail.com',// Add more allowed exceptions here
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
                ), // Rounded corners only at the top
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
                        'Training Provider Sign Up',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF113F67),
                        ),
                      ),
                      const SizedBox(height: 20),

                      //Company name field
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

                      // Company email field with both domain and exception email validation
_buildTextField(
  'Company Email',
  _emailController,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your company email';
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    // Extract the domain from the email
    String domain = value.split('@').last;

    // Check if the email is in the exception list or if the domain is trusted
    if (!trustedDomains.contains(domain) && !exceptionEmails.contains(value)) {
      return 'The email domain is not recognized as a trusted \n company domain.';
    }

    return null;
  },
),

                      const SizedBox(height: 15),

                      // Password field
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

                      // location selector
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

  //encrypt password using SHA-256
  String _encryptPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return; //if the form is not valid return and show errors
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
        //encrypt password before saving it to Firestore
        String encryptedPassword = _encryptPassword(_passwordController.text);

        await _firestore.collection('TrainingProvider').doc(user.uid).set({
          'company_name': _companyNameController.text,
          'email': _emailController.text,
          'password': encryptedPassword, //store encrypted password
          'location': _selectedLocations, //store selected locations
          'uid': user.uid,
          'role': 'training_provider', //storing the user role
        });

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
