import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadafi_application/CV.dart';
import 'package:hadafi_application/Community/CommunityHomeScreen.dart';
import 'package:hadafi_application/favoriteList.dart';
import 'package:hadafi_application/interview.dart';
import 'package:hadafi_application/style.dart';
import 'package:hadafi_application/welcome.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "package:hadafi_application/OpportunityDetailsPage.dart";
import "package:hadafi_application/button.dart";
import 'package:hadafi_application/studentProfilePage.dart';
import 'package:hadafi_application/studentHomePage.dart';
import 'package:hadafi_application/Community/Providers/storage_repository_providers.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _gpaController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  final TextEditingController _technicalSkillsController =
      TextEditingController();
  final TextEditingController _managementSkillsController =
      TextEditingController();
  final TextEditingController _softSkillsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  File? _profileImageFile;
  String? _profilePicUrl;
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _technicalSkills = [];
  final List<String> _managementSkills = [];
  final List<String> _softSkills = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> _selectedTechnicalSkills = [];
  List<String> _selectedManagementSkills = [];
  List<String> _selectedSoftSkills = [];
  List<String> _selectedLocations = [];
  List<String> _filteredNationalities = [];
  List<String> _tempLocations = [];
  List<String> _tempTechnicalSkills = [];
  List<String> _tempManagementSkills = [];
  List<String> _tempSoftSkills = [];
  List<String> _filteredCities = [];

  double? _selectedGpaScale;
  String? _tempNationality;
  String? _selectedNationality;
  String? _emailError;
  bool _isEditing = false;

  final List<String> healthTechnicalSkills = [
    "Data Analysis",
    "Data Visualization",
    "Electronic Health Records (EHR)",
    "EMR (Electronic Medical Records)",
    "Health Informatics",
    "Clinical Decision Support Systems (CDSS)",
    "Medical Imaging Software",
    "DICOM Standards",
    "Healthcare Cybersecurity",
    "HIPAA Compliance",
    "Mobile Health (mHealth)",
    "Telehealth",
    "IoMT (Internet of Medical Things)",
    "Wearable Devices Integration",
    "MATLAB",
    "Excel",
    "Word",
    "Outlook",
    "PowerPoint",
    "Statistical Analysis",
    "Tableau",
    "SharePoint"
  ];

  final List<String> healthSoftSkills = [
    "Accountability",
    "Adaptability",
    "Analytical Thinking",
    "Attention to Detail",
    "Collaboration and Teamwork",
    "Communication",
    "Conflict Resolution",
    "Creative Solutions",
    "Creative writing",
    "Critical Thinking",
    "Customer Orientation",
    "Decision Making",
    "Dependability",
    "Deal with ambiguity",
    "Emotional Intelligence",
    "Empathy",
    "Flexibility to Changing Environments",
    "Ideation Concepts",
    "Interpersonal Skills",
    "Leadership",
    "Logical Reasoning",
    "Multitasking",
    "Patience",
    "Problem Solving",
    "Resilience",
    "Responsibility",
    "Self-Motivation",
    "Strong Work Ethic",
    "Stress Management",
    "Task Prioritization",
    "Thoroughness",
    "Time Management",
    "Verbal and Written Clarity",
    "Workplace Etiquette",
    "Working Effectively Within Teams",
    "Networking",
    "Public Speaking",
    "Presentation Skills",
    "Relationship Building",
    "Willingness to learn"
  ];

  final List<String> healthManagementSkills = [
    "Adapting to Organizational Changes",
    "Change Management",
    "Client Relationship Management",
    "Crisis Management",
    "Delegation",
    "Expense Tracking",
    "Facilitating Transitions Smoothly",
    "Forecasting",
    "Mentorship",
    "Operational Planning",
    "Performance Evaluation",
    "Process Improvement",
    "Resource Management",
    "Risk Assessment",
    "Stakeholder Management",
    "Strategic Planning",
    "Team Building",
    "Timeline Setting"
  ];

  final List<String> humanitiesTechnicalSkills = [
    "Adobe Creative Suite",
    "Content Creation tools",
    "Data Analysis",
    "Data Visualization",
    "Excel",
    "Outlook",
    "Word",
    "PowerPoint",
    "Project Management tools",
    "Microsoft Office Suite",
    "Tableau",
    "Content Management Systems (CMS)",
    "Graphic Design Tools",
    "Basic HTML and CSS",
    "Social Media Management Tools",
    "Social media platforms",
    "Digital Archiving",
    "Citation Management Tools",
    "Editing Software",
    "Web Content Creation",
    "Audio Editing Tools",
    "Video Editing Tools"
  ];

  final List<String> humanitiesSoftSkills = [
    "Accountability",
    "Adaptability",
    "Analytical Thinking",
    "Attention to Detail",
    "Collaboration and Teamwork",
    "Communication",
    "Conflict Resolution",
    "Creative Solutions",
    "Creative writing",
    "Critical Thinking",
    "Customer Orientation",
    "Decision Making",
    "Dependability",
    "Deal with ambiguity",
    "Emotional Intelligence",
    "Empathy",
    "Flexibility to Changing Environments",
    "Ideation Concepts",
    "Interpersonal Skills",
    "Leadership",
    "Logical Reasoning",
    "Multitasking",
    "Patience",
    "Problem Solving",
    "Resilience",
    "Responsibility",
    "Self-Motivation",
    "Strong Work Ethic",
    "Stress Management",
    "Task Prioritization",
    "Thoroughness",
    "Time Management",
    "Verbal and Written Clarity",
    "Workplace Etiquette",
    "Working Effectively Within Teams",
    "Networking",
    "Public Speaking",
    "Presentation Skills",
    "Relationship Building",
    "Willingness to learn"
  ];

  final List<String> humanitiesManagementSkills = [
    "Adapting to Organizational Changes",
    "Change Management",
    "Client Relationship Management",
    "Conflict Resolution",
    "Crisis Management",
    "Delegation",
    "Facilitating Transitions Smoothly",
    "Mentorship",
    "Operational Planning",
    "Performance Evaluation",
    "Process Improvement",
    "Project Planning and Coordination",
    "Resource Management",
    "Stakeholder Management",
    "Strategic Planning",
    "Team Building",
    "Task Prioritization",
    "Timeline Setting",
    "Creative Project Management",
    "Event Planning",
    "Public Relations Management"
  ];

  final List<String> scientificSoftSkills = [
    "Accountability",
    "Adaptability",
    "Analytical Thinking",
    "Attention to Detail",
    "Collaboration and Teamwork",
    "Communication",
    "Conflict Resolution",
    "Creative Solutions",
    "Creative writing",
    "Critical Thinking",
    "Customer Orientation",
    "Decision Making",
    "Dependability",
    "Deal with ambiguity",
    "Emotional Intelligence",
    "Empathy",
    "Flexibility to Changing Environments",
    "Ideation Concepts",
    "Interpersonal Skills",
    "Leadership",
    "Logical Reasoning",
    "Multitasking",
    "Patience",
    "Problem Solving",
    "Resilience",
    "Responsibility",
    "Self-Motivation",
    "Strong Work Ethic",
    "Stress Management",
    "Task Prioritization",
    "Thoroughness",
    "Time Management",
    "Verbal and Written Clarity",
    "Workplace Etiquette",
    "Working Effectively Within Teams",
    "Networking",
    "Public Speaking",
    "Presentation Skills",
    "Relationship Building",
    "Willingness to learn"
  ];

  final List<String> scientificManagementSkills = [
    "Adapting to Organizational Changes",
    "Change Management",
    "Conflict Resolution",
    "Crisis Management",
    "Delegation",
    "Facilitating Transitions Smoothly",
    "Forecasting",
    "Innovation Management",
    "Mentorship",
    "Operational Planning",
    "Performance Evaluation",
    "Process Improvement",
    "Project Lifecycle Management",
    "Project Planning and Coordination",
    "Resource Management",
    "Risk Assessment",
    "Stakeholder Management",
    "Strategic Planning",
    "Task Prioritization",
    "Team Building",
    "Timeline Setting"
  ];

  final List<String> scientificTechnicalSkills = [
    "Adobe XD",
    "Agile",
    "Angular",
    "API integration (REST)",
    "API integration (SOAP)",
    "ASP.NET",
    "AWS",
    "Azure",
    "Big Data Analytics",
    "Bitbucket",
    "Blockchain",
    "C",
    "C#",
    "C++",
    "Cloud Architecture",
    "Confluence",
    "CRM systems",
    "CSS",
    "Cybersecurity Tools",
    "Cybersecurity",
    "Data Analysis",
    "Data Mining",
    "Data Visualization",
    "Database Design",
    "DevOps",
    "Docker",
    "Encryption",
    "Excel",
    "Express",
    "Figma",
    "Firebase",
    "Firewalls",
    "Flutter",
    "Familiarity with laboratory techniques",
    "Git and GitHub",
    "GCP",
    "Golang",
    "Hadoop",
    "HTML",
    "Java",
    "JavaScript",
    "Jest",
    "JIRA",
    "JUnit",
    "Kubernetes",
    "Linux",
    "Machine Learning",
    "MATLAB",
    "Microsoft Office 365",
    "Microsoft Office Suite",
    "MongoDB",
    "MS Project",
    "Network Fundamentals",
    "NoSQL",
    "Node.js",
    "NLP",
    "Outlook",
    "Object-Oriented Programming (OOP)",
    "Oracle APEX",
    "Penetration Testing",
    "PHP",
    "PL/SQL",
    "Postman",
    "Power BI",
    "PowerPoint",
    "Prototyping",
    "Python",
    "R Programming",
    "React",
    "Ruby",
    "Rust",
    "Selenium",
    "Sketch",
    "SQL",
    "Statistical Analysis",
    "Supervised/Unsupervised Learning",
    "SVN",
    "Swift",
    "Troubleshooting Techniques",
    "Tableau",
    "TensorFlow",
    "Trello",
    "Ubuntu",
    "UI/UX Design",
    "User Research",
    "VLOOKUP",
    "Vue.js",
    "Waterfall",
    "Web Development",
    "Word",
    "CAD",
    "Engineering software packages"
  ];

  final List<String> _nationalities = [
    'Algerian',
    'Bahraini',
    'Egyptian',
    'Emirati',
    'Iraqi',
    'Jordanian',
    'Kuwaiti',
    'Lebanese',
    'Omani',
    'Palestinian',
    'Qatari',
    'Saudi',
    'Sudanese',
    'Syrian',
    'Tunisian',
    'Yemeni',
  ];

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
    _loadStudentData();
  }

  void _enterEditMode() {
    setState(() {
      _isEditing = true;
      _tempNationality = _selectedNationality;
      _tempLocations = List<String>.from(_selectedLocations);
      _tempTechnicalSkills = List<String>.from(_selectedTechnicalSkills);
      _tempManagementSkills = List<String>.from(_selectedManagementSkills);
      _tempSoftSkills = List<String>.from(_selectedSoftSkills);
    });
  }

  void _cancelEditMode() {
    setState(() {
      _formKey.currentState?.reset();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _isEditing = false;
      _emailError = null;
      _selectedNationality = _tempNationality;
      _selectedLocations = List<String>.from(_tempLocations);
      _selectedTechnicalSkills = List<String>.from(_tempTechnicalSkills);
      _selectedManagementSkills = List<String>.from(_tempManagementSkills);
      _selectedSoftSkills = List<String>.from(_tempSoftSkills);

      // Update controllers
      _nationalityController.text = _selectedNationality ?? '';
      _locationController.text = _selectedLocations.join(', ');
      _technicalSkillsController.text = _selectedTechnicalSkills.join(', ');
      _managementSkillsController.text = _selectedManagementSkills.join(', ');
      _softSkillsController.text = _selectedSoftSkills.join(', ');
    });
  }

  Future<bool> checkEmailInUse(String email) async {
    try {
      User? user = _auth.currentUser;
      if (user != null && user.email == email) {
        return false;
      }

      final querySnapshot = await _firestore
          .collection('Student')
          .where('email', isEqualTo: email)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking email: $e");
      return false;
    }
  }

  Future<void> _selectProfileImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_profileImageFile == null) return;

    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/${user.uid}.jpg');

      await storageRef.putFile(_profileImageFile!);
      String downloadUrl = await storageRef.getDownloadURL();

      await _firestore.collection('Student').doc(user.uid).update({
        'profilePic': downloadUrl,
      });

      setState(() {
        _profilePicUrl = downloadUrl;
        _profileImageFile = null;
      });
    } catch (e) {
      print("Error uploading profile picture: $e");
    }
  }

  Future<void> _loadStudentData() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        DocumentSnapshot doc =
            await _firestore.collection('Student').doc(user.uid).get();

        if (doc.exists) {
          setState(() {
            _profilePicUrl = doc['profilePic'] ?? ''; // Load profile picture

            _nameController.text = doc['name'] ?? '';
            _emailController.text = doc['email'] ?? '';
            _gpaController.text = doc['gpa'].toString();
            _majorController.text = doc['major'] ?? '';
            _selectedLocations = List<String>.from(doc['location'] ?? []);
            _locationController.text = _selectedLocations.join(', ');
            _selectedNationality = doc['nationality'] ?? '';
            _nationalityController.text = _selectedNationality!;
            List<String> allSkills = List<String>.from(doc['skills'] ?? []);
            _selectedTechnicalSkills = allSkills
                .where((skill) => scientificTechnicalSkills.contains(skill))
                .toList();
            _selectedManagementSkills = allSkills
                .where((skill) => scientificManagementSkills.contains(skill))
                .toList();
            _selectedSoftSkills = allSkills
                .where((skill) => scientificSoftSkills.contains(skill))
                .toList();

            _selectedGpaScale = doc['gpaScale']?.toDouble();
          });
        }
      }
    } catch (e) {
      print("Failed to load student data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load profile data'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if the email is already in use
    final email = _emailController.text.trim();
    final currentEmail = _auth.currentUser?.email;

    if (email != currentEmail) {
      final emailRegex =
          RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(email)) {
        setState(() {
          _emailError = 'Please enter a valid email address';
        });
        return;
      }

      bool isEmailInUse = await checkEmailInUse(email);
      if (isEmailInUse) {
        setState(() {
          _emailError = 'This email is already in use';
        });
        return;
      }
    }

    if (_profileImageFile != null) {
      await _uploadProfileImage();
    }
    setState(() {
      _emailError = null;
    });

    try {
      User? user = _auth.currentUser;

      if (user != null) {
        // Check if the user has at least one skill selected from any category
        if (_selectedTechnicalSkills.isEmpty &&
            _selectedManagementSkills.isEmpty &&
            _selectedSoftSkills.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please select at least one skill'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Combine all selected skills into a single array
        List<String> allSkills = [
          ..._selectedTechnicalSkills,
          ..._selectedManagementSkills,
          ..._selectedSoftSkills
        ];

        // Save the profile data
        await _firestore.collection('Student').doc(user.uid).update({
          'name': _nameController.text,
          'email': _emailController.text,
          'gpa': _gpaController.text,
          'gpaScale': _selectedGpaScale,
          'location': _selectedLocations,
          'nationality': _selectedNationality,
          'skills': allSkills,
        });

        setState(() {
          _isEditing = false; // Exit edit mode after saving
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFFF3F9FB),
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
              onPressed: () {
                setState(() {
                  _isEditing = true; // Enable edit mode
                  _tempNationality = _selectedNationality;
                  _tempLocations = List<String>.from(_selectedLocations);
                  _tempTechnicalSkills =
                      List<String>.from(_selectedTechnicalSkills);
                  _tempManagementSkills =
                      List<String>.from(_selectedManagementSkills);
                  _tempSoftSkills = List<String>.from(_selectedSoftSkills);
                });
              },
            )
        ],
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(_isEditing ? Icons.arrow_back : Icons.menu),
          onPressed: () {
            if (_isEditing) {
              _cancelEditMode();
            } else {
              _scaffoldKey.currentState!.openDrawer();
            }
          },
        ),
      ),
      drawer: HadafiDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 15),
              Text(
                'Personal Information:',
                style: TextStyle(
                  color: Color(0xFF113F67),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: _isEditing ? _selectProfileImage : null,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _profileImageFile != null
                            ? FileImage(_profileImageFile!)
                            : _profilePicUrl != null &&
                                    _profilePicUrl!.isNotEmpty
                                ? NetworkImage(_profilePicUrl!)
                                : AssetImage('assets/default_avatar.png')
                                    as ImageProvider,
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.blue,
                            radius: 18,
                            child: Icon(Icons.camera_alt,
                                color: Colors.white, size: 20),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              SizedBox(height: 15),
              _buildEditableField('Name', _nameController),
              SizedBox(height: 10),
              _buildEmailField(),
              SizedBox(height: 10),
              _buildNonEditableField('Major', _majorController),
              SizedBox(height: 10),
              _buildLocationSelector(),
              SizedBox(height: 10),
              _buildNationalitySelector(),
              SizedBox(height: 10),
              _buildGPASection(),

              const SizedBox(height: 15),
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
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
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

              SizedBox(height: 15),
              Divider(
                color: Colors.grey,
                thickness: 1.5,
                indent: 20,
                endIndent: 20,
              ),
              SizedBox(height: 15),
              Text(
                'Skills:',
                style: TextStyle(
                  color: Color(0xFF113F67),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Display error message if no skills are selected
              if (_selectedTechnicalSkills.isEmpty &&
                  _selectedManagementSkills.isEmpty &&
                  _selectedSoftSkills.isEmpty &&
                  _isEditing)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Please select at least one skill from any category',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              SizedBox(height: 15),
              _buildSkillsSelector('Technical Skills', _selectedTechnicalSkills,
                  (updatedSkills) {
                setState(() {
                  _selectedTechnicalSkills = updatedSkills;
                });
              }),
              SizedBox(height: 10),
              _buildSkillsSelector(
                  'Management Skills', _selectedManagementSkills,
                  (updatedSkills) {
                setState(() {
                  _selectedManagementSkills = updatedSkills;
                });
              }),
              SizedBox(height: 10),
              _buildSkillsSelector('Soft Skills', _selectedSoftSkills,
                  (updatedSkills) {
                setState(() {
                  _selectedSoftSkills = updatedSkills;
                });
              }),

              const SizedBox(height: 30),

              if (_isEditing)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _saveProfile, // Save changes to Firestore
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF113F67),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 35, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),

                      child: Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFFF3F9FB),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false; // Exit edit mode
                          _loadStudentData();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFFFFF),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 35, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 18,
                          color: const Color(0xFF113F67),
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

  Widget _buildNonEditableField(
      String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF113F67)),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        enabled: false, // Field is read only
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
          return null;
        },
      ),
    );
  }

  Widget _buildEmailField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
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
                return 'Email cannot be empty';
              }
              final emailRegex =
                  RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          if (_emailError != null)
            Padding(
              padding: const EdgeInsets.only(top: 9.0),
              child: Text(
                _emailError!,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSkillsSelector(String label, List<String> selectedSkills,
      void Function(List<String>) onSkillsChanged) {
    TextEditingController controller =
        TextEditingController(text: selectedSkills.join(', '));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _isEditing
                ? () {
                    _showSkillsDialog(
                      title: label,
                      selectedSkills: List.from(selectedSkills),
                      onSkillsChanged: (updatedSkills) {
                        setState(() {
                          selectedSkills.clear();
                          selectedSkills.addAll(updatedSkills);
                          controller.text = updatedSkills.join(', ');
                          onSkillsChanged(updatedSkills);
                        });
                      },
                    );
                  }
                : null,
            child: AbsorbPointer(
              absorbing: true,
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: label,
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
                style: TextStyle(
                  color: _isEditing ? Colors.black : Colors.grey,
                ),
                enabled: false,
                validator: (value) {
                  if (_selectedTechnicalSkills.isEmpty &&
                      _selectedManagementSkills.isEmpty &&
                      _selectedSoftSkills.isEmpty &&
                      _isEditing) {
                    return 'Please select at least one skill in any category';
                  }
                  return null;
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children: selectedSkills.map((skill) {
              return Chip(
                label: Text(skill, style: TextStyle(color: Color(0xFF113F67))),
                onDeleted: _isEditing
                    ? () {
                        setState(() {
                          selectedSkills.remove(skill);
                          controller.text = selectedSkills.join(', ');
                          onSkillsChanged(selectedSkills);
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

  void _showSkillsDialog({
    required String title,
    required List<String> selectedSkills,
    required void Function(List<String>) onSkillsChanged,
  }) {
    List<String> availableSkills = [];

    final healthMajors = [
      'Biomedical Engineering',
      'Clinical Laboratory Sciences',
      'Clinical Nutrition',
      'Dentistry',
      "Forensic Science",
      'Health Informatics',
      'Healthcare',
      'Medicine (MBBS)',
      'Medical Laboratory Sciences',
      'Nursing',
      'Nutrition',
      'Oral and Maxillofacial Surgery',
      'Orthodontics',
      'Occupational Therapy',
      'Pharmacy',
      'Public Health',
      'Physical Therapy',
      'Prosthetics and Orthotics',
      'Radiology',
      'Respiratory Therapy',
      'Clinical Pharmacy',
    ];

    final humanitiesMajors = [
      'Biomedical Engineering',
      'Clinical Laboratory Sciences',
      'Clinical Nutrition',
      'Dentistry',
      "Forensic Science",
      'Health Informatics',
      'Healthcare',
      'Medicine (MBBS)',
      'Medical Laboratory Sciences',
      'Nursing',
      'Nutrition',
      'Oral and Maxillofacial Surgery',
      'Orthodontics',
      'Occupational Therapy',
      'Pharmacy',
      'Public Health',
      'Physical Therapy',
      'Prosthetics and Orthotics',
      'Radiology',
      'Respiratory Therapy',
      'Clinical Pharmacy',
    ];
    // Determine the skills list based on major and title
    String major = _majorController.text;
    if (healthMajors.contains(major)) {
      availableSkills = title.contains('Technical')
          ? healthTechnicalSkills
          : title.contains('Management')
              ? healthManagementSkills
              : healthSoftSkills;
    } else if (humanitiesMajors.contains(major)) {
      availableSkills = title.contains('Technical')
          ? humanitiesTechnicalSkills
          : title.contains('Management')
              ? humanitiesManagementSkills
              : humanitiesSoftSkills;
    } else {
      availableSkills = title.contains('Technical')
          ? scientificTechnicalSkills
          : title.contains('Management')
              ? scientificManagementSkills
              : scientificSoftSkills;
    }

    List<String> filteredSkills = List.from(availableSkills);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        List<String> dialogSelectedSkills = List.from(selectedSkills);

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Column(
                children: [
                  Text(title),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Search $title',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filteredSkills = availableSkills
                            .where((skill) => skill
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
                  children: filteredSkills.map((skill) {
                    return CheckboxListTile(
                      title: Text(skill),
                      value: dialogSelectedSkills.contains(skill),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            dialogSelectedSkills.add(skill);
                          } else {
                            dialogSelectedSkills.remove(skill);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    selectedSkills.clear();
                    selectedSkills.addAll(dialogSelectedSkills);
                    onSkillsChanged(selectedSkills);
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

  Widget _buildNationalitySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: _isEditing
            ? () {
                _showNationalityDialog();
              }
            : null, // Disable tapping if not in editing mode
        child: AbsorbPointer(
          child: TextFormField(
            controller: _nationalityController,
            decoration: InputDecoration(
              labelText: 'Nationality',
              labelStyle: TextStyle(
                color: Colors.grey,
              ),
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
            style: TextStyle(
              color: _isEditing ? Colors.black : Colors.grey,
            ),
            enabled: _isEditing, // Only editable when in edit mode
            validator: (value) {
              if (_selectedNationality == null ||
                  _selectedNationality!.isEmpty) {
                return 'Please select your nationality';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  void _showNationalityDialog() {
    setState(() {
      _filteredNationalities = List.from(_nationalities);
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Column(
                children: [
                  Text('Select Nationality'),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Search Nationality',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _filteredNationalities = _nationalities
                            .where((nationality) => nationality
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
                  children: _filteredNationalities.map((nationality) {
                    return RadioListTile<String>(
                      title: Text(nationality),
                      value: nationality,
                      groupValue: _selectedNationality,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedNationality = value;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    _nationalityController.text = _selectedNationality ?? '';
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

  Widget _buildLocationSelector() {
    return Column(
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
              decoration: InputDecoration(
                labelText: 'Location',
                labelStyle: TextStyle(
                  color: Colors.grey,
                ),
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
              style: TextStyle(
                color: _isEditing ? Colors.black : Colors.grey,
              ),
              controller: TextEditingController(
                text: _selectedLocations.join(', '),
              ),
              validator: (value) {
                if (_selectedLocations.isEmpty) {
                  return 'Please select at least one location';
                }
                return null;
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          children: _selectedLocations.map((location) {
            return Chip(
              label: Text(location),
              onDeleted: _isEditing
                  ? () {
                      setState(() {
                        _selectedLocations.remove(location);
                        _locationController.text =
                            _selectedLocations.join(', ');
                      });
                    }
                  : null, // Only allow deletion in edit mode
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showLocationDialog() {
    _filteredCities = _cities;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Column(
                children: [
                  Text('Select Locations (required)'),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Search Cities',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty) {
                          _filteredCities = _cities;
                        } else {
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
                    Navigator.of(context).pop();
                    setState(() {
                      _locationController.text = _selectedLocations.join(', ');
                    });
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      setState(() {
        _locationController.text = _selectedLocations.join(', ');
      });
    });
  }

  String? _validateGPA(String? value) {
    if (value == null || value.isEmpty) {
      return 'GPA cannot be empty';
    }

    final gpa = double.tryParse(value);
    if (gpa == null) {
      return 'Please enter a valid GPA number';
    }

    if (gpa == 0) {
      return 'GPA cannot be 0. Please enter a valid GPA';
    }

    if (gpa > _selectedGpaScale!) {
      return 'GPA cannot exceed $_selectedGpaScale';
    }

    final gpaRegex = RegExp(r'^\d+(\.\d{1,2})?$');
    if (!gpaRegex.hasMatch(value)) {
      return 'Please enter a valid GPA (e.g., 4.00)';
    }

    return null;
  }

  Widget _buildGPASection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isEditing)
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedGpaScale = 4.0;
                      _gpaController.clear();
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
                      _gpaController.clear();
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: TextFormField(
              controller: _gpaController,
              decoration: InputDecoration(
                labelText: 'GPA',
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
              enabled: _isEditing, // Only allow editing when in edit mode
              validator: _validateGPA,
            ),
          ),
        ],
      ),
    );
  }
}

// Email function
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
    final String body =
        Uri.encodeComponent('Dear Admin, I encountered the following issues:');

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

// Logout function
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
      const SnackBar(
        content: Text('Logout failed. Please try again.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
