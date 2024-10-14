import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadafi_application/interview.dart';
import 'package:hadafi_application/welcome.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StudentHomePage();
  }
}

class HadafiDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            _buildDrawerItem(context, Icons.person, 'Profile', ProfilePage()),
            _buildDrawerItem(context, Icons.home, 'Home',
                StudentHomePage()), // Changed to StudentHomePage
            _buildDrawerItem(
                context, Icons.assignment, 'CV Enhancement Tool', null),
            _buildDrawerItem(
              context,
              Icons.chat,
              'Interview Simulator',
              InterviewPage(),
            ),
            _buildDrawerItem(context, Icons.feedback, 'Feedback', null),
            _buildDrawerItem(context, Icons.group, 'Communities', null),
            _buildDrawerItem(context, Icons.favorite, 'Favorites List', null),
            Divider(),

            ListTile(
              leading: Icon(Icons.logout, color: Color(0xFF113F67)),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context); // Close the drawer

                // Show the logout message
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Logged out'),
                ));

                // Redirect to the WelcomeScreen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        WelcomeScreen(), // Navigate to WelcomeScreen
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, IconData icon, String title, Widget? page) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF113F67)),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        }
      },
    );
  }
}

class StudentHomePage extends StatelessWidget {
  // Changed from HomePage to StudentHomePage
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: HadafiDrawer(),
      appBar: AppBar(
        backgroundColor: Color(0xFF113F67),
        actions: [
          Padding(
            padding: const EdgeInsets.all(1),
            child: Image.asset(
              'Hadafi/images/LOGO.png',
              fit: BoxFit.contain,
              height: 300,
            ),
          ),
        ],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildSectionTitle('Training Opportunities'),
            _buildOpportunitiesTab(),
            _buildSectionTitle('Feedback from Users'),
            _buildFeedbackList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF113F67),
        ),
      ),
    );
  }

  Widget _buildOpportunitiesTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        height: 490,
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                labelColor: Color(0xFF113F67),
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color(0xFF113F67),
                tabs: [
                  Tab(text: 'Best Match'),
                  Tab(text: 'Other'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    OpportunitiesList(title: 'Best Match Opportunities'),
                    OpportunitiesList(title: 'Other Opportunities'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackList() {
    return Container(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 200,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF113F67), width: 2),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 5, spreadRadius: 2),
              ],
            ),
            child: ListTile(
              title: Text('User ${index + 1}'),
              subtitle: Text('This app helped me find a great internship!'),
            ),
          );
        },
      ),
    );
  }
}

class OpportunitiesList extends StatelessWidget {
  final String title;

  OpportunitiesList({required this.title});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Color(0xFF113F67), width: 2),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 5, spreadRadius: 2),
              ],
            ),
            child: ListTile(
              title: Text('$title ${index + 1}'),
              subtitle: Text('Based on your qualifications'),
            ),
          ),
        );
      },
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _gpaController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _certificatesController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<String> _selectedLocations = [];
  List<String> _filteredCities = [];
  double? _selectedGpaScale;
  bool _isEmailUsed = false;
  String _originalEmail = '';

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadStudentData(); // Load student data on profile page load
  }

  // Function to load student data from Firestore
  Future<void> _loadStudentData() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        DocumentSnapshot doc =
            await _firestore.collection('Student').doc(user.uid).get();

        if (doc.exists) {
          setState(() {
            _nameController.text = doc['name'] ?? '';
            _emailController.text = doc['email'] ?? '';
            _originalEmail = doc['email'] ?? '';
            _gpaController.text = doc['gpa'].toString();
            _majorController.text = doc['major'] ?? '';
            _skillsController.text =
                (doc['skills'] as List<dynamic>).join(', ') ?? '';
            _certificatesController.text =
                (doc['certificates'] as List<dynamic>).join(', ') ?? '';
            _selectedLocations = List<String>.from(doc['location'] ?? []);
            _locationController.text = _selectedLocations.join(', ');
          });
        }
      }
    } catch (e) {
      print("Failed to load student data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Color(0xFF113F67),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveProfile, // Save profile changes
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildEditableField('Student Name', _nameController),
              _buildEditableField('Email', _emailController),

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
                  if (gpa == null || gpa <= 0 || gpa > _selectedGpaScale!) {
                    return 'Please enter a valid GPA up to ${_selectedGpaScale!.toStringAsFixed(2)}';
                  }

                  final gpaRegex = RegExp(r'^\d\.\d{2}$');
                  if (!gpaRegex.hasMatch(value)) {
                    return 'Please enter a valid GPA in the format (e.g., 4.80)';
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
                            .clear(); //Clear the GPA field if scale changes
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
                      style: TextStyle(fontSize: 12, color: Colors.white),
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
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ],
              ),

              _buildEditableField('Major', _majorController),
              _buildEditableField('Skills', _skillsController),
              _buildEditableField('Certificates', _certificatesController),
              _buildLocationSelector(),
            ],
          ),
        ),
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
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

  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildLocationSelector() {
    return GestureDetector(
      onTap: _showLocationDialog,
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
      ];
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return; // Validation failed
    }

    final email = _emailController.text;

    // Add GPA validation logic here
    if (!_isGPAValid(_gpaController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Invalid GPA format or exceeds the allowed scale')),
      );
      return;
    }

    // Check if the email is already used by another student, unless it's the user's original email
    if (email != _originalEmail) {
      bool isEmailUsed = await _isEmailAlreadyUsed(email);
      if (isEmailUsed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('This email is already in use by another user.')),
        );
        return; // Email is already in use, stop the update
      }
    }

    try {
      User? user = _auth.currentUser;

      if (user != null) {
        await _firestore.collection('Student').doc(user.uid).update({
          'name': _nameController.text,
          'email': email,
          'gpa': _gpaController.text,
          'major': _majorController.text,
          'skills': _skillsController.text.split(', '),
          'certificates': _certificatesController.text.split(', '),
          'location': _selectedLocations,
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

  bool _isGPAValid(String gpa) {
    double? gpaValue = double.tryParse(gpa);
    if (gpaValue == null) {
      return false; // Invalid GPA format
    }
    return gpaValue >= 0.0 && gpaValue <= _selectedGpaScale!;
  }

  Future<bool> _isEmailAlreadyUsed(String email) async {
    final querySnapshot = await _firestore
        .collection('Student')
        .where('email', isEqualTo: email)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }
}
