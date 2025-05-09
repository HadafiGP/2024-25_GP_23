import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadafi_application/style.dart';
import 'package:hadafi_application/welcome.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hadafi_application/TrainingProviderHomePage.dart';

class TrainingProviderProfilePage extends StatefulWidget {
  const TrainingProviderProfilePage({super.key});

  @override
  _TrainingProviderProfilePageState createState() =>
      _TrainingProviderProfilePageState();
}

class _TrainingProviderProfilePageState
    extends State<TrainingProviderProfilePage> {
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isEditing = false;
  List<String> _selectedLocations = [];
  String? _emailError;

  final List<String> _cities = [
    'Abha',
    'Al Ahsa',
    'Al-Kharj',
    'Al Khobar',
    'Al Qassim',
    'Baha',
    'Bisha',
    'Dammam',
    'Dhahran',
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
    _loadProfileData();
  }

// List of trusted domains for validation
  List<String> trustedDomains = [
    'mc.gov.sa',
    'hrsd.gov.sa',
    'tvtc.gov.sa',
    'ksu.edu.sa',
    'kau.edu.sa',
    'psu.edu.sa',
    'kfupm.edu.sa',
    'aramco.com',
    'sabic.com',
    'stc.com.sa',
    'almarai.com',
    'monshaat.gov.sa',
    'scfhs.org.sa',
    'sdaia.gov.sa',
  ];

// List of exception emails that are allowed
  List<String> exceptionEmails = [
    'hendtp@gmail.com',
    'hessatp@gmail.com',
    'dunatp@gmail.com',
    'jejetp@gmail.com',
    'lamatp@gmail.com',
    'riderise.sa@gmail.com',
    'alanazilama01@gmail.com'
  ];

  Future<bool> checkEmailInUse(String email) async {
    final methods =
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    return methods.isNotEmpty;
  }

  Future<void> _loadProfileData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc =
            await _firestore.collection('TrainingProvider').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _companyNameController.text = doc['company_name'] ?? '';
            _emailController.text = doc['email'] ?? '';
            _selectedLocations = List<String>.from(doc['location'] ?? []);
            _locationController.text = _selectedLocations.join(', ');
          });
        }
      }
    } catch (e) {
      print("Failed to load profile data: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to load profile data'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final currentEmail = _auth.currentUser?.email;

    // 1. Check email format with regex
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });
      return;
    }

    // 2. Check if email is in exception list or has trusted domain
    String domain = email.split('@').last;
    if (!exceptionEmails.contains(email) && !trustedDomains.contains(domain)) {
      setState(() {
        _emailError =
            'Only emails from trusted domains or exception list are allowed';
      });
      return;
    }

    // 3. Check if email has changed and is already in use
    if (email != currentEmail) {
      bool isEmailInUse = await checkEmailInUse(email);
      if (isEmailInUse) {
        setState(() {
          _emailError = 'This email is already in use';
        });
        return;
      }
    }

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('TrainingProvider').doc(user.uid).update({
          'company_name': _companyNameController.text.trim(),
          'email': email,
          'location': _selectedLocations,
        });

        setState(() {
          _isEditing = false;
          _emailError = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Failed to save profile data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _enterEditMode() {
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEditMode() async {
    setState(() {
      _isEditing = false;
      _emailError = null;
      _formKey.currentState?.reset();
    });
    await _loadProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Color(0xFF113F67),
        title: Text(
          _isEditing ? 'Edit Profile' : 'Profile',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _enterEditMode,
            ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(_isEditing ? Icons.arrow_back : Icons.menu),
          onPressed: () async {
            if (_isEditing) {
              setState(() {
                _isEditing = false;
                _emailError = null;
                _formKey.currentState?.reset();
              });
              await _loadProfileData();
            } else {
              _scaffoldKey.currentState!.openDrawer();
            }
          },
        ),
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Company Information:',
                style: TextStyle(
                  fontSize: kFontSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                ),
              ),
              SizedBox(height: 20),
              _buildEditableField('Company Name', _companyNameController),
              SizedBox(height: 10),
              _buildEditableField('Email', _emailController),
              SizedBox(height: 10),
              _buildLocationSelector(),
              SizedBox(height: 15),

              // Change Password Button
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final String email = _emailController.text.trim();
                      await FirebaseAuth.instance
                          .sendPasswordResetEmail(email: email);

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Row(
                              children: [
                                Text(
                                  'Success ',
                                  style: TextStyle(color: Color(0xFF113F67)),
                                ),
                                Icon(Icons.check_circle,
                                    color: Colors.green), // Check icon
                                SizedBox(width: 10),
                              ],
                            ),
                            content: Text(
                              'A password change link has been successfully sent to your email. Please check your inbox to proceed.',
                              style: TextStyle(fontSize: 16),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text(
                                  'OK',
                                  style: TextStyle(color: Color(0xFF113F67)),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } catch (e) {
                      // Show error message in a popup dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Row(
                              children: [
                                Text(
                                  'Error ',
                                  style: TextStyle(color: Colors.red),
                                ),
                                Icon(Icons.cancel, color: Colors.red),
                                SizedBox(width: 10),
                              ],
                            ),
                            content: Text(
                              'Failed to send reset email. Please try again later.',
                              style: TextStyle(fontSize: 16),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text(
                                  'OK',
                                  style: TextStyle(color: Color(0xFF113F67)),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  style: kSecondaryButtonStyle,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_reset, color: Color(0xFF113F67)),
                      SizedBox(width: 10),
                      Text(
                        "Change Password",
                        style: TextStyle(
                          color: Color(0xFF113F67),
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (_isEditing)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _saveProfile,
                      style: smallButtonStyle,
                      child: Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _cancelEditMode,
                      style: kSecondaryButtonStyle,
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF113F67),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: _emailController,
        decoration: InputDecoration(
          labelText: 'Company Email (required)',
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF113F67)),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF113F67)),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF113F67)),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your company email';
          }

          final emailRegex = RegExp(r'^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
          if (!emailRegex.hasMatch(value)) {
            return 'Please enter a valid email address';
          }

          // Check if the email domain is trusted or if it's an exception email
          String domain = value.split('@').last;
          if (!trustedDomains.contains(domain) &&
              !exceptionEmails.contains(value)) {
            return 'The email domain is not recognized as a trusted company domain';
          }

          return null;
        },
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          errorText: label == 'Email' ? _emailError : null,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF113F67)),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF113F67)),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF113F67)),
            borderRadius: BorderRadius.circular(10),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF113F67)),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        enabled: _isEditing,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label cannot be empty';
          }

          if (label == 'Email') {
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return 'Invalid email format';
            }

            // Check if email is in exception list or has trusted domain
            String domain = value.split('@').last;
            if (!exceptionEmails.contains(value) &&
                !trustedDomains.contains(domain)) {
              return 'Email not from trusted domain';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _buildLocationSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _isEditing
                ? () {
                    _showLocationDialog();
                  }
                : null,
            child: AbsorbPointer(
              child: TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF113F67)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF113F67)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF113F67)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF113F67)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                enabled: _isEditing,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children: _selectedLocations.map((location) {
              return Chip(
                backgroundColor: Colors.white,
                label: Text(
                  location,
                  style: TextStyle(
                    color: Color(0xFF113F67),
                  ),
                ),
                deleteIconColor: Color(0xFF113F67),
                onDeleted: _isEditing
                    ? () {
                        setState(() {
                          _selectedLocations.remove(location);
                          _locationController.text =
                              _selectedLocations.join(', ');
                        });
                      }
                    : null,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Location'),
              content: SingleChildScrollView(
                child: Column(
                  children: _cities.map((city) {
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
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color(0xFFF3F9FB),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF113F67),
              ),
              child: Image.asset(
                'Hadafi/images/LOGO.png',
                fit: BoxFit.contain,
                height: 80,
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: Color(0xFF113F67)),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TrainingProviderProfilePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.home, color: Color(0xFF113F67)),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TrainingProviderHomePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_mail, color: Color(0xFF113F67)),
              title: const Text('Contact us'),
              onTap: () {
                _launchEmail();
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Color(0xFF113F67)),
              title: Text('Log Out'),
              onTap: () {
                Navigator.pop(context);
                _logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed. Please try again.'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _launchEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print("User is not logged in.");
        return;
      }

      final String userId = user.uid;
      final String email = 'Hadafi.GP@gmail.com';
      final String subject =
          Uri.encodeComponent('App Support - User ID: $userId');
      final String body = Uri.encodeComponent(
          'Dear Admin, I encountered the following issues:');

      final String emailUrl = 'mailto:$email?subject=$subject&body=$body';

      if (await canLaunchUrl(Uri.parse(emailUrl))) {
        await launchUrl(Uri.parse(emailUrl));
      } else {
        throw 'Could not launch email client';
      }
    } catch (e) {
      print("An error occurred while launching the email: $e");
    }
  }
}
