import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadafi_application/interview.dart';
import 'package:hadafi_application/welcome.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "package:hadafi_application/OpportunityDetailsPage.dart";
import "package:hadafi_application/button.dart";
import 'package:hadafi_application/studentProfilePage.dart';
import 'package:hadafi_application/studentHomePage.dart';

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

  double? _selectedGpaScale;
  String? _tempNationality;
  String? _selectedNationality;
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
    "PowerPoint",
    "Statistical Analysis",
    "Tableau"
  ];

  final List<String> healthSoftSkills = [
    "Accountability",
    "Adaptability",
    "Analytical Thinking",
    "Attention to Detail",
    "Collaboration and Teamwork",
    "Communication",
    "Critical Thinking",
    "Customer Orientation",
    "Decision Making",
    "Dependability",
    "Emotional Intelligence",
    "Empathy",
    "Flexibility to Changing Environments",
    "Interpersonal Skills",
    "Patience",
    "Problem Solving",
    "Resilience",
    "Self-Motivation",
    "Stress Management",
    "Thoroughness",
    "Time Management",
    "Verbal and Written Clarity",
    "Workplace Etiquette",
    "Working Effectively Within Teams"
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
    "Leadership",
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
    "Data Analysis",
    "Data Visualization",
    "Excel",
    "Word",
    "PowerPoint",
    "Microsoft Office Suite",
    "Tableau",
    "Content Management Systems (CMS)",
    "Graphic Design Tools",
    "Basic HTML and CSS",
    "Social Media Management Tools",
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
    "Critical Thinking",
    "Customer Orientation",
    "Decision Making",
    "Dependability",
    "Emotional Intelligence",
    "Empathy",
    "Flexibility to Changing Environments",
    "Interpersonal Skills",
    "Leadership",
    "Patience",
    "Problem Solving",
    "Resilience",
    "Self-Motivation",
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
    "Relationship Building"
  ];

  final List<String> humanitiesManagementSkills = [
    "Adapting to Organizational Changes",
    "Change Management",
    "Client Relationship Management",
    "Conflict Resolution",
    "Crisis Management",
    "Delegation",
    "Facilitating Transitions Smoothly",
    "Leadership",
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
    "Critical Thinking",
    "Decision Making",
    "Dependability",
    "Flexibility to Changing Environments",
    "Interpersonal Skills",
    "Logical Reasoning",
    "Patience",
    "Problem Solving",
    "Resilience",
    "Self-Motivation",
    "Strong Work Ethic",
    "Stress Management",
    "Task Prioritization",
    "Thoroughness",
    "Time Management",
    "Verbal and Written Clarity",
    "Workplace Etiquette",
    "Working Effectively Within Teams"
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
    "Leadership",
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
    "C#",
    "C++",
    "Cloud Architecture",
    "Confluence",
    "CRM systems",
    "CSS",
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
    "Git and GitHub",
    "GCP",
    "Hadoop",
    "HTML",
    "Java",
    "JavaScript",
    "Jest",
    "JIRA",
    "JUnit",
    "Kubernetes",
    "Machine Learning",
    "MATLAB",
    "Microsoft Office Suite",
    "MongoDB",
    "MS Project",
    "Network Fundamentals",
    "NoSQL",
    "Node.js",
    "NLP",
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
    "Selenium",
    "Sketch",
    "SQL",
    "Statistical Analysis",
    "Supervised/Unsupervised Learning",
    "SVN",
    "Swift",
    "Tableau",
    "TensorFlow",
    "Trello",
    "UI/UX Design",
    "User Research",
    "VLOOKUP",
    "Vue.js",
    "Waterfall",
    "Web Development",
    "Word"
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
    'Other',
  ];
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
    'Other'
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
      _isEditing = false;
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
            _gpaController.text = doc['gpa'].toString();
            _majorController.text = doc['major'] ?? '';
            _selectedLocations = List<String>.from(doc['location'] ?? []);
            _locationController.text = _selectedLocations.join(', ');
            _selectedNationality = doc['nationality'] ?? '';
            _nationalityController.text = _selectedNationality!;
            // Separate skills based on predefined lists
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
        SnackBar(content: Text('Failed to load profile data')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      User? user = _auth.currentUser;

      if (user != null) {
        // Combine all selected skills into a single array
        List<String> allSkills = [
          ..._selectedTechnicalSkills,
          ..._selectedManagementSkills,
          ..._selectedSoftSkills
        ];

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
              setState(() {
                _isEditing = false; // Exit edit mode
              });
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
              Text(
                'Personal Information:',
                style: TextStyle(
                  color: Color(0xFF113F67),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
              SizedBox(height: 20),
              Text(
                'Skills:',
                style: TextStyle(
                  color: Color(0xFF113F67),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              _buildSkillsSelector('Technical Skills', _selectedTechnicalSkills,
                  _technicalSkillsController),
              SizedBox(height: 10),
              _buildSkillsSelector('Management Skills',
                  _selectedManagementSkills, _managementSkillsController),
              SizedBox(height: 10),
              _buildSkillsSelector(
                  'Soft Skills', _selectedSoftSkills, _softSkillsController),
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
                          // Restore state variables
                          _selectedNationality = _tempNationality;
                          _selectedLocations =
                              List<String>.from(_tempLocations);
                          _selectedTechnicalSkills =
                              List<String>.from(_tempTechnicalSkills);
                          _selectedManagementSkills =
                              List<String>.from(_tempManagementSkills);
                          _selectedSoftSkills =
                              List<String>.from(_tempSoftSkills);
                          // Update controllers
                          _nationalityController.text =
                              _selectedNationality ?? '';
                          _locationController.text =
                              _selectedLocations.join(', ');
                          _technicalSkillsController.text =
                              _selectedTechnicalSkills.join(', ');
                          _managementSkillsController.text =
                              _selectedManagementSkills.join(', ');
                          _softSkillsController.text =
                              _selectedSoftSkills.join(', ');
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
      child: TextFormField(
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
              RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\$');
          if (!emailRegex.hasMatch(value)) {
            return 'Enter a valid email';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSkillsSelector(String label, List<String> selectedSkills,
      TextEditingController controller) {
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
                      selectedSkills: selectedSkills,
                      controller: controller,
                    );
                  }
                : null,
            child: AbsorbPointer(
              child: TextFormField(
                controller: TextEditingController(
                  text: selectedSkills.join(', '),
                ),
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
                enabled: _isEditing,
                validator: (value) {
                  if (selectedSkills.isEmpty && _isEditing) {
                    return 'Please select at least one skill in $label';
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
                label: Text(
                  skill,
                  style: TextStyle(
                    color: Color(0xFF113F67),
                  ),
                ),
                onDeleted: _isEditing
                    ? () {
                        setState(() {
                          selectedSkills.remove(skill);
                        });
                      }
                    : null, // No action when not in editing mode
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
    required TextEditingController controller,
  }) {
    List<String> availableSkills = [];

    // Retrieve the major from the profile
    String major = _majorController.text;

    // Check if the major is in the health majors list
    final healthMajors = [
      'Clinical Laboratory Sciences',
      'Occupational Therapy',
      'Physical Therapy',
      'Prosthetics and Orthotics',
      'Radiology',
      'Dentistry',
      'Oral and Maxillofacial Surgery',
      'Orthodontics',
      'Biomedical Engineering',
      'Clinical Nutrition',
      'Health Informatics',
      'Medical Laboratory Sciences',
      'Nursing',
      'Public Health',
      'Radiologic Technology',
      'Respiratory Therapy',
      'Medicine (MBBS)',
      'Clinical Pharmacy',
      'Pharmacy'
    ];

    final humanitiesMajors = [
      'Architecture',
      'Graphic Design',
      'Industrial Design',
      'Interior Design',
      'Urban Planning',
      'Accounting',
      'Business Administration',
      'Finance',
      'Human Resources Management',
      'International Business',
      'Marketing',
      'Supply Chain Management',
      'Law',
      'Islamic Law (Sharia)',
      'Economics'
    ];

    // Check the major and assign the appropriate skills list
    if (healthMajors.contains(major)) {
      if (title.contains('Technical')) {
        availableSkills = healthTechnicalSkills;
      } else if (title.contains('Management')) {
        availableSkills = healthManagementSkills;
      } else {
        availableSkills = healthSoftSkills;
      }
    } else if (humanitiesMajors.contains(major)) {
      if (title.contains('Technical')) {
        availableSkills = humanitiesTechnicalSkills;
      } else if (title.contains('Management')) {
        availableSkills = humanitiesManagementSkills;
      } else {
        availableSkills = humanitiesSoftSkills;
      }
    } else {
      // Default to scientific majors
      if (title.contains('Technical')) {
        availableSkills = scientificTechnicalSkills;
      } else if (title.contains('Management')) {
        availableSkills = scientificManagementSkills;
      } else {
        availableSkills = scientificSoftSkills;
      }
    }

    // Show the dialog with the available skills list
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: Column(
                  children: availableSkills.map((skill) {
                    return CheckboxListTile(
                      title: Text(skill),
                      value: selectedSkills.contains(skill),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedSkills.add(skill);
                          } else {
                            selectedSkills.remove(skill);
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
                    // Update the controller to reflect the selected skills
                    controller.text = selectedSkills.join(', ');
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
    // Initialize _filteredNationalities with the full list of nationalities
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
                label: Text(
                  location,
                  style: TextStyle(
                    color: Color(0xFF113F67),
                  ),
                ),
                onDeleted: _isEditing
                    ? () {
                        setState(() {
                          _selectedLocations.remove(location);
                          _selectedLocations = _selectedLocations
                              .where((item) => item != location)
                              .toList();
                          _locationController.text =
                              _selectedLocations.join(', ');
                        });
                      }
                    : null, // No action when not in editing mode
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

  String? _validateGPA(String? value) {
    if (value == null || value.isEmpty) {
      return 'GPA cannot be empty';
    }

    final gpa = double.tryParse(value);
    if (gpa == null) {
      return 'Please enter a valid GPA number';
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

class HadafiDrawer extends StatelessWidget {
  const HadafiDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFFF3F9FB),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF113F67),
              ),
              child: Image.asset(
                'Hadafi/images/LOGO.png',
                fit: BoxFit.contain,
                height: 80,
              ),
            ),
            _buildDrawerItem(context, Icons.person, 'Profile', ProfilePage()),
            _buildDrawerItem(
                context, Icons.home, 'Home', const StudentHomePage()),
            _buildDrawerItem(
                context, Icons.assignment, 'CV Enhancement Tool', null),
            _buildDrawerItem(
              context,
              Icons.chat,
              'Interview Simulator',
              const InterviewPage(),
            ),
            _buildDrawerItem(context, Icons.feedback, 'Feedback', null),
            _buildDrawerItem(context, Icons.group, 'Communities', null),
            _buildDrawerItem(context, Icons.favorite, 'Favorites List', null),
            ListTile(
              leading: const Icon(Icons.contact_mail, color: Color(0xFF113F67)),
              title: const Text('Contact us'),
              onTap: () {
                _launchEmail();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFF113F67)),
              title: const Text('Log Out'),
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

  Widget _buildDrawerItem(
      BuildContext context, IconData icon, String title, Widget? page) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF113F67)),
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
}
