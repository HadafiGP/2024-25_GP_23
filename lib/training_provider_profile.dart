import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadafi_application/TrainingProviderHomePage.dart';

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
            leading:
                Icon(Icons.person, color: Color(0xFF113F67)), // Profile icon
            title: Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProviderProfilePage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.home, color: Color(0xFF113F67)), // Home icon
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Color(0xFF113F67)),
            title: Text('Log Out'),
            onTap: () {},
          ),
        ],
      ),
    ),
  );
}

class ProviderProfilePage extends StatefulWidget {
  const ProviderProfilePage({super.key});

  @override
  _ProviderProfilePageState createState() => _ProviderProfilePageState();
}

class _ProviderProfilePageState extends State<ProviderProfilePage> {
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  List<String> _selectedLocations = [];
  List<String> _filteredCities = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final List<String> validDomains = [
    'corp.com',
    'example.com'
  ]; // Example valid domains
  final List<String> exceptionEmails = [
    'hendtp@gmail.com',
    'hessatp@gmail.com',
    'dunatp@gmail.com',
    'jejetp@gmail.com',
    'lamatp@gmail.com'
  ]; // Example exception emails

  final List<String> _cities = [
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

  bool _isEmailUsed = false;
  String _originalEmail = '';

  @override
  void initState() {
    super.initState();
    _loadProviderData(); // Load provider data on profile page load
    _filteredCities = _cities;
  }

  // Function to load training provider data from Firestore
  Future<void> _loadProviderData() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        DocumentSnapshot doc =
            await _firestore.collection('TrainingProvider').doc(user.uid).get();

        if (doc.exists) {
          setState(() {
            _companyNameController.text = doc['company_name'] ?? '';
            _emailController.text = doc['email'] ?? '';
            _originalEmail = doc['email'] ?? ''; // Store the original email
            _selectedLocations = List<String>.from(
                doc['location'] ?? []); // Initialize selected locations
            _locationController.text =
                _selectedLocations.join(', '); // Display the selected locations
          });
        }
      }
    } catch (e) {
      print("Failed to load provider data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile data')),
      );
    }
  }

  // Function to validate email domain or check for exception emails
  bool _isEmailValid(String email) {
    final domain = email.split('@').last;

    // Check if the email is either valid based on domain or in the exception list
    return validDomains.contains(domain) || exceptionEmails.contains(email);
  }

  // Function to check if the email is already used
  Future<bool> _isEmailAlreadyUsed(String email) async {
    // Skip this check if the updated email is the same as the original email
    if (email == _originalEmail) {
      return false;
    }

    final querySnapshot = await _firestore
        .collection('TrainingProvider')
        .where('email', isEqualTo: email)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F9FB),
      appBar: AppBar(
        backgroundColor: Color(0xFF113F67),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildEditableProfileField(
                  'Company Name:', _companyNameController),
              SizedBox(height: 16), // Consistent spacing
              _buildEditableProfileField('Email:', _emailController),
              SizedBox(height: 16), // Consistent spacing
              _buildLocationSelector(),
              if (_isEmailUsed)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'This email is already used. Please choose a different one.',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              // Add Save button at the bottom
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 140, // Set a fixed width
                  child: ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF113F67),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(fontSize: 16, color: Color(0xFFF3F9FB)),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
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
              leading:
                  Icon(Icons.person, color: Color(0xFF113F67)), // Profile icon
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.home, color: Color(0xFF113F67)), // Home icon
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TrainingProviderHomePage()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Color(0xFF113F67)),
              title: Text('Log Out'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Logged Out'),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }

  // Editable profile fields with validation
  Widget _buildEditableProfileField(
      String label, TextEditingController controller) {
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: 8.0), // Add vertical margin for spacing
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // Consistent border radius
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF113F67), width: 2.0),
            borderRadius: BorderRadius.circular(12), // Consistent border radius
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label cannot be empty';
          }
          return null;
        },
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
      _filteredCities = [
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
      ]; // List of cities
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
                        // If search text is empty, show all cities again
                        if (value.isEmpty) {
                          _filteredCities = [
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
                        } else {
                          // Filter cities starting with the letter typed (case-insensitive)
                          _filteredCities = _filteredCities
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

  // Save profile data to Firestore with validation
  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() != true) {
      return; // Validation failed
    }

    final email = _emailController.text;

    // Check if the email is already used by another training provider
    bool isUsed = await _isEmailAlreadyUsed(email);
    if (isUsed) {
      setState(() {
        _isEmailUsed = true;
      });
      return; // Email is already in use
    } else {
      setState(() {
        _isEmailUsed = false;
      });
    }

    if (!_isEmailValid(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid email domain or email is not allowed')),
      );
      return; // Email is invalid
    }

    try {
      User? user = _auth.currentUser;

      if (user != null) {
        await _firestore.collection('TrainingProvider').doc(user.uid).update({
          'company_name': _companyNameController.text,
          'email': email,
          'location':
              _selectedLocations, // Updated to store the selected locations
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      print("Failed to save profile data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile')),
      );
    }
  }
}
