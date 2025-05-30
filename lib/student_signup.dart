import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/provider.dart';
import 'package:hadafi_application/signup_widget.dart';
import 'package:hadafi_application/StudentHomepage.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/style.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:hadafi_application/Community/controller/community_controller.dart';
import 'package:hadafi_application/Community/Providers/storage_repository_providers.dart';
import 'package:hadafi_application/Community/common/loader.dart';
import 'package:hadafi_application/Community/constants/constants.dart';
import 'dart:convert';
import 'dart:async';

class StudentSignupScreen extends StatefulWidget {
  const StudentSignupScreen({super.key});

  @override
  _StudentSignupScreenState createState() => _StudentSignupScreenState();
}

class _StudentSignupScreenState extends State<StudentSignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _majorKey = GlobalKey();
  final _locationKey = GlobalKey();
  final _nationalityKey = GlobalKey();

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  final TextEditingController _gpaController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final List<String> _selectedLocations = [];
  final List<String> _selectedTechnicalSkills = [];
  final List<String> _selectedManagementSkills = [];
  final List<String> _selectedSoftSkills = [];
  List<String> _filteredMajors = [];
  List<String> _filteredCities = [];
  List<String> _filteredNationalities = [];
  List<String> _currentTechnicalSkills = [];
  List<String> _currentSoftSkills = [];
  List<String> _currentManagementSkills = [];

// Repeat for soft skills and management skills
  String? avatarPath;
  String? _emailError; // To hold the "email already in use" error
  String? _selectedNationality;
  String? _selectedMajor;

  double? _selectedGpaScale; // Store selected GPA scale

  bool _isSkillsSelected = true; // Tracks if at least one skill is selected
  bool _isCheckingEmail = false; // show loading indicator for email check
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _hasAttemptedSubmit = false; // Add this line
  bool _isMajorSelected = false;

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

// List of all available majors
  final List<String> _majors = [
    'Architecture',
    'Accounting',
    'Anthropology',
    'Artificial Intelligence',
    'Arts',
    'Administrative',
    'Arabic',
    'Advertising',
    'Business',
    'Business Administration',
    'Biomedical Engineering',
    'Business Informatics',
    'Biological Science',
    'Biology',
    'Clinical Laboratory Sciences',
    'Computer Science',
    'Criminal Justice',
    'Computer Engineering',
    'Computer Information Systems',
    'Computer Programming',
    'Cybersecurity',
    'Chemistry',
    'Chemical Engineering',
    'Clinical Nutrition',
    'Civil Engineering',
    'Commerce',
    'Communication',
    'Comparative Literature',
    'Data Science',
    'Dentistry',
    'Data Analytics',
    'Design',
    'Drafting',
    'Electrical Engineering',
    'Environmental Engineering',
    'Economics',
    'Education',
    'Electronics',
    'Engineering',
    'English',
    'Environmental Science',
    'Finance',
    'Film',
    'Fine Arts',
    'Foreign Language',
    'Forensic science',
    'Forestry',
    'Graphic Design',
    'General Studies',
    'Geography',
    'Geology',
    'Government',
    'Health Informatics',
    'Human Resources Management',
    'Healthcare',
    'History',
    'Hospitality Management',
    'Human Computer Interaction',
    'Islamic Law (Sharia)',
    'International Business',
    'Information System',
    'Information Technology',
    'Industrial Design',
    'Interior Design',
    'Industrial Engineering',
    'Journalism',
    'Law',
    'Liberal Arts',
    'Linguistics',
    'Literature',
    'Medicine (MBBS)',
    'Medical Laboratory Sciences',
    'Mechanical Engineering',
    'Management Information Systems',
    'Marketing',
    'Management',
    'Mathematics',
    'Media',
    'Music',
    'Manufacturing Engineering',
    'Nursing',
    'Nutrition',
    'Oral and Maxillofacial Surgery',
    'Orthodontics',
    'Occupational Therapy',
    'Organization Development',
    'Pharmacy',
    'Petroleum Engineering',
    'Public Health',
    'Public Policy',
    'Physical Therapy',
    'Prosthetics and Orthotics',
    'Public Administration',
    'Public Relations',
    'Philosophy',
    'Physics',
    'Political Science',
    'Psychology',
    'Radiology',
    'Respiratory Therapy',
    'Religion',
    'Risk Management',
    'Supply Chain Management',
    'Software Engineering',
    'Science',
    'Sociology',
    'Statistics',
    'Safety Engineering',
    'Telecommunications',
    'Theatre',
    'Translation',
    'Urban Planning',
    'Visual Arts'
  ];

/////////////////////////////////////////////////////
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

  final List<String> softSkills = [
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

  void _updateSkillsBasedOnMajor(String? major) {
    if (major == null || major.isEmpty) {
      setState(() {
        _isMajorSelected = false;
        _currentTechnicalSkills.clear();
        _currentSoftSkills.clear();
        _currentManagementSkills.clear();
        _selectedTechnicalSkills.clear();
        _selectedSoftSkills.clear();
        _selectedManagementSkills.clear();
      });
      return;
    }

    setState(() {
      _isMajorSelected = true;

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

      final List<String> humanitiesMajors = [
        'Accounting',
        'Administrative',
        'Anthropology',
        'Arts',
        'Arabic',
        'Advertising',
        'Business',
        'Business Administration',
        'Business Informatics',
        'Commerce',
        'Communication',
        'Comparative Literature',
        'Design',
        'Drafting',
        'Economics',
        'Education',
        'English',
        'Film',
        'Fine Arts',
        'Foreign Language',
        'Forestry',
        'Graphic Design',
        'General Studies',
        'Geography',
        'Geology',
        'Government',
        'Hospitality Management',
        'Human Resources Management',
        'History',
        'Human Computer Interaction',
        'Islamic Law (Sharia)',
        'International Business',
        'Interior Design',
        'Journalism',
        'Law',
        'Liberal Arts',
        'Linguistics',
        'Literature',
        'Marketing',
        'Management',
        'Media',
        'Music',
        'Organization Development',
        'Public Policy',
        'Public Administration',
        'Public Relations',
        'Philosophy',
        'Political Science',
        'Psychology',
        'Religion',
        'Risk Management',
        'Supply Chain Management',
        'Sociology',
        'Theatre',
        'Translation',
        'Visual Arts'
      ];
      if (healthMajors.contains(major)) {
        _currentTechnicalSkills = List.from(healthTechnicalSkills);
        _currentSoftSkills = List.from(softSkills);
        _currentManagementSkills = List.from(healthManagementSkills);
      } else if (humanitiesMajors.contains(major)) {
        _currentTechnicalSkills = List.from(humanitiesTechnicalSkills);
        _currentSoftSkills = List.from(softSkills);
        _currentManagementSkills = List.from(humanitiesManagementSkills);
      } else {
        _currentTechnicalSkills = List.from(scientificTechnicalSkills);
        _currentSoftSkills = List.from(softSkills);
        _currentManagementSkills = List.from(scientificManagementSkills);
      }

      _selectedTechnicalSkills.clear();
      _selectedManagementSkills.clear();
      _selectedSoftSkills.clear();
    });
  }

  final GlobalKey<FormFieldState<String>> _nameKey = GlobalKey();
  final GlobalKey<FormFieldState<String>> _emailKey = GlobalKey();
  final GlobalKey<FormFieldState<String>> _passwordKey = GlobalKey();
  final GlobalKey<FormFieldState<String>> _gpaKey = GlobalKey();

  void _scrollToFirstError() {
    for (var key in [_nameKey, _emailKey, _passwordKey, _gpaKey]) {
      if (key.currentState != null && key.currentState is FormFieldState) {
        final fieldState = key.currentState as FormFieldState<String>;
        if (!fieldState.validate()) {
          final context = key.currentContext;
          if (context != null) {
            final renderBox = context.findRenderObject() as RenderBox;
            final offset = renderBox.localToGlobal(Offset.zero).dy;

            _scrollController.animateTo(
              offset - 100,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
          return;
        }
      }
    }

    if (_selectedMajor == null) {
      _scrollToElement(_majorKey);
      return;
    }
    if (_selectedLocations.isEmpty) {
      _scrollToElement(_locationKey);
      return;
    }
    if (_selectedNationality == null) {
      _scrollToElement(_nationalityKey);
      return;
    }
  }

  void _scrollToElement(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      final renderBox = context.findRenderObject() as RenderBox;
      final offset = renderBox.localToGlobal(Offset.zero).dy;

      _scrollController.animateTo(
        offset - 100,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _validatePassword(String password) {
    setState(() {
      _isMinLength = password.length >= 8;
      _hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
      _hasLowercase = RegExp(r'[a-z]').hasMatch(password);
      _hasNumber = RegExp(r'[0-9]').hasMatch(password);
      _hasSpecialChar = RegExp(r'[!@#\$&*~]').hasMatch(password);
      _hasSpecialChar = RegExp(r'[!@#\$&*\.\~]').hasMatch(password);
      _hasAttemptedSubmit = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _filteredCities = _cities;
    _isMajorSelected = false;
    _filteredMajors.addAll(_majors);
    _emailController.addListener(() {
      if (_emailError != null) {
        setState(() {
          _emailError = null;
        });
      }
    });
    _filteredMajors.addAll(_majors);
  }

  Future pickImage2(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile == null) return;

      setState(() {
        avatarPath = pickedFile.path;
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
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
                controller: _scrollController,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Student Sign Up',
                        style: TextStyle(
                          fontSize: kFontSizeLarge,
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField('Full Name (required)', _nameController,
                          key: _nameKey, validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      }),
                      const SizedBox(height: 15),

                      _buildTextField(
                        'Email (required)',
                        _emailController,
                        key: _emailKey,
                        validator: (value) {
                          if (_emailError != null) {
                            return _emailError;
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
                      _buildTextField(
                        'Password (required)',
                        _passwordController,
                        key: _passwordKey,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password.';
                          }

                          // Password constraints
                          final passwordValid = value.length >= 8 &&
                              RegExp(r'[A-Z]').hasMatch(value) &&
                              RegExp(r'[a-z]').hasMatch(value) &&
                              RegExp(r'[0-9]').hasMatch(value) &&
                              RegExp(r'[!@#\$&*\.\~]').hasMatch(value);

                          if (!passwordValid) {
                            return '';
                          }

                          return null;
                        },
                        onChanged: (value) => _validatePassword(value),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildPasswordGuidance(),

                      const SizedBox(height: 15),

                      _buildMajorDropdown(key: _majorKey),
                      const SizedBox(height: 15),
                      _buildLocationSelector(key: _locationKey),
                      const SizedBox(height: 15),
                      _buildNationalitySelector(key: _nationalityKey),
                      const SizedBox(height: 15),

// GPA Scale and GPA Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // GPA Scale Buttons
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedGpaScale = 4.0;
                                    _gpaController.clear();
                                  });
                                },
                                key: _gpaKey,
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
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          // GPA Input Field
                          _buildTextField(
                            'GPA (required)',
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
                        ],
                      ),
                      const SizedBox(height: 15),

                      Divider(
                        color: Colors.grey,
                        thickness: 1.5,
                        indent: 20,
                        endIndent: 20,
                      ),
                      SizedBox(height: 15),
                      Align(
                        alignment: Alignment.topLeft,
                        child: const Text(
                          'Choose an Avatar (Optional):',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF113F67),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              await pickImage2(ImageSource.gallery);
                              setState(() {});
                            },
                            icon: Icon(Icons.image, color: Colors.white),
                            label: Text(
                              "Gallery",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      const Color.fromARGB(255, 236, 236, 236)),
                            ),
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 0, 118, 208)),
                          ),
                          SizedBox(width: 15),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await pickImage2(ImageSource.camera);
                              setState(() {});
                            },
                            icon: Icon(Icons.camera_alt, color: Colors.white),
                            label: Text(
                              "Camera",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      const Color.fromARGB(255, 236, 236, 236)),
                            ),
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 0, 176, 15)),
                          ),
                        ],
                      ),
                      if (avatarPath != null) ...[
                        const SizedBox(height: 10),
                        Align(
                            alignment: Alignment.topLeft,
                            child: Text("✅ Avatar selected!",
                                style: TextStyle(
                                    color: const Color.fromARGB(
                                        255, 0, 176, 15)))),
                      ],

                      SizedBox(height: 15),
                      Divider(
                        color: Colors.grey,
                        thickness: 1.5,
                        indent: 20,
                        endIndent: 20,
                      ),
                      SizedBox(height: 15),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            textAlign: TextAlign.left,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Skills: ",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _isSkillsSelected
                                        ? Color(0xFF113F67)
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Please choose at least one skill from any category",
                            style: TextStyle(
                              fontSize: 14,
                              color: _isSkillsSelected
                                  ? Color(0xFF113F67)
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),
                      _buildManagementSkillsSelector(),
                      const SizedBox(height: 15),
                      _buildSoftSkillsSelector(),
                      const SizedBox(height: 15),
                      _buildTechnicalSkillsSelector(),

                      const SizedBox(height: 30),

                      _isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _hasAttemptedSubmit = true;

                                  _isSkillsSelected = _selectedTechnicalSkills
                                          .isNotEmpty ||
                                      _selectedManagementSkills.isNotEmpty ||
                                      _selectedSoftSkills.isNotEmpty;
                                });
                                if (!_formKey.currentState!.validate()) {
                                  _scrollToFirstError();
                                  return;
                                }
                                if (_formKey.currentState!.validate() &&
                                    _isSkillsSelected) {
                                  _signUp();
                                }
                              },
                              style: kMainButtonStyle,
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    Key? key,
    bool isPassword = false,
    bool enabled = true,
    String? Function(String?)? validator,
    Function(String)? onChanged,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildPasswordGuidance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPasswordCriteriaRow(
            "Must be at least 8 characters.", _isMinLength),
        _buildPasswordCriteriaRow(
            "Must contain an uppercase letter.", _hasUppercase),
        _buildPasswordCriteriaRow(
            "Must contain a lowercase letter.", _hasLowercase),
        _buildPasswordCriteriaRow("Must contain a number.", _hasNumber),
        _buildPasswordCriteriaRow(
            "Must contain a special character.", _hasSpecialChar),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildPasswordCriteriaRow(String text, bool isValid) {
    Color color;
    IconData icon;

    if (isValid) {
      color = Colors.green;
      icon = Icons.check_circle;
    } else if (_hasAttemptedSubmit) {
      color = Colors.red;
      icon = Icons.cancel;
    } else {
      color = Colors.grey;
      icon = Icons.radio_button_unchecked;
    }

    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildMajorDropdown({Key? key}) {
    return GestureDetector(
      onTap: () {
        _showMajorDialog();
      },
      child: AbsorbPointer(
        child: TextFormField(
          key: key,
          decoration: InputDecoration(
            labelText: 'Select Major (required)',
            suffixIcon: const Icon(Icons.arrow_drop_down),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          controller: _majorController,
          validator: (value) {
            if (_selectedMajor == null) {
              return 'Please choose your major';
            }
            return null;
          },
        ),
      ),
    );
  }

  void _showMajorDialog() {
    setState(() {
      _filteredMajors = _majors;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Column(
                children: [
                  Text('Select Major (required)'),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Search Major',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _filteredMajors = _majors
                            .where((major) => major
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
                  children: _filteredMajors.map((major) {
                    return RadioListTile<String>(
                      title: Text(major),
                      value: major,
                      groupValue: _selectedMajor,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedMajor =
                              value; // Only update the selected major
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    if (_selectedMajor != null) {
                      setState(() {
                        _majorController.text = _selectedMajor!;
                        _updateSkillsBasedOnMajor(
                            _selectedMajor); // Update skills based on major
                      });
                    }
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

  Widget _buildTechnicalSkillsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            if (!_isMajorSelected) {
              // Show snackbar warning if no major is selected
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please choose your major first.'),
                  backgroundColor: Colors.red,
                ),
              );
            } else {
              _showSkillsDialog(
                "Select Technical Skills",
                _currentTechnicalSkills,
                _selectedTechnicalSkills,
              );
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              enabled: _isMajorSelected,
              decoration: InputDecoration(
                labelText: 'Select Technical Skills',
                suffixIcon: const Icon(Icons.arrow_drop_down),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              controller: TextEditingController(
                text: _selectedTechnicalSkills.join(', '),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          children: _selectedTechnicalSkills.map((skill) {
            return Chip(
              label: Text(skill),
              onDeleted: () {
                setState(() {
                  _selectedTechnicalSkills.remove(skill);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildManagementSkillsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            if (!_isMajorSelected) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please choose your major first.'),
                  backgroundColor: Colors.red,
                ),
              );
            } else {
              _showSkillsDialog(
                "Select Management Skills",
                _currentManagementSkills,
                _selectedManagementSkills,
              );
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              enabled: _isMajorSelected, // Enable only if a major is selected
              decoration: InputDecoration(
                labelText: 'Select Management Skills',
                suffixIcon: const Icon(Icons.arrow_drop_down),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              controller: TextEditingController(
                text: _selectedManagementSkills.join(', '),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Display selected skills as Chips
        Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          children: _selectedManagementSkills.map((skill) {
            return Chip(
              label: Text(skill),
              onDeleted: () {
                setState(() {
                  _selectedManagementSkills
                      .remove(skill); // Remove skill from list
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSoftSkillsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            if (!_isMajorSelected) {
              // Show snackbar warning if no major is selected
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please choose your major first.'),
                  backgroundColor: Colors.red,
                ),
              );
            } else {
              _showSkillsDialog("Select Soft Skills", _currentSoftSkills,
                  _selectedSoftSkills);
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              enabled: _isMajorSelected,
              decoration: InputDecoration(
                labelText: 'Select Soft Skills',
                suffixIcon: const Icon(Icons.arrow_drop_down),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              controller: TextEditingController(
                text: _selectedSoftSkills.join(', '),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          children: _selectedSoftSkills.map((skill) {
            return Chip(
              label: Text(skill),
              onDeleted: () {
                setState(() {
                  _selectedSoftSkills.remove(skill);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showSkillsDialog(
      String title, List<String> skillsList, List<String> selectedSkills) {
    List<String> filteredSkillsList = List.from(skillsList);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Column(
                children: [
                  Text(title),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Search Skills',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        // Filter skills based on the search input
                        filteredSkillsList = skillsList
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
                  children: filteredSkillsList.map((skill) {
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
                    Navigator.of(context).pop();
                    setState(() {});
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      setState(() {});
    });
  }

  Widget _buildLocationSelector({Key? key}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            _showLocationDialog();
          },
          child: AbsorbPointer(
            child: TextFormField(
              key: key,
              decoration: InputDecoration(
                labelText: 'Select Locations (required)',
                suffixIcon: const Icon(Icons.arrow_drop_down),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              controller:
                  TextEditingController(text: _selectedLocations.join(', ')),
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
              onDeleted: () {
                setState(() {
                  _selectedLocations.remove(location);
                });
              },
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
                    setState(() {});
                  },
                  child: Text('OK'),
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

  Widget _buildNationalitySelector({Key? key}) {
    return GestureDetector(
      onTap: () {
        _showNationalityDialog();
      },
      child: AbsorbPointer(
        child: TextFormField(
          key: key,
          controller: _nationalityController,
          decoration: InputDecoration(
            labelText: 'Select Nationality (required)',
            suffixIcon: const Icon(Icons.arrow_drop_down),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator: (value) {
            if (_selectedNationality == null) {
              return 'Please choose your nationality';
            }
            return null;
          },
        ),
      ),
    );
  }

  void _showNationalityDialog() {
    setState(() {
      _filteredNationalities = _nationalities;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Column(
                children: [
                  Text('Select Nationality (required)'),
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

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Encrypt password using SHA-256
  String _encryptPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Store user data in Firestore and Firebase Authentication with Timeout and Error Handling
  Future<void> _signUp() async {
    setState(() {
      // Check if at least one skill is selected
      _isSkillsSelected = _selectedTechnicalSkills.isNotEmpty ||
          _selectedManagementSkills.isNotEmpty ||
          _selectedSoftSkills.isNotEmpty;
      _hasAttemptedSubmit = true;
    });
    if (!_isSkillsSelected || !_formKey.currentState!.validate()) {
      return; // If the form is not valid, return and show errors
    }

    setState(() {
      _isLoading = true;
      _emailError = null;
    });

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          )
          .timeout(Duration(seconds: 15));

      User? user = userCredential.user;

      if (user != null) {
        // Encrypt password before saving it to Firestore
        String encryptedPassword = _encryptPassword(_passwordController.text);

        List<String> allSkills = [
          ..._selectedTechnicalSkills,
          ..._selectedManagementSkills,
          ..._selectedSoftSkills
        ];
        String avatarUrl = Constants.avatarDefault;
        String bannerUrl = Constants.bannerDefault;

        final storageRepository =
            ProviderScope.containerOf(context).read(firebaseStorageProvider);

        if (avatarPath != null) {
          avatarUrl = await storageRepository.uploadImageToStorage(
              'avatars', user.uid, avatarPath!);
        }

        // Store user data in Firestore
        await _firestore.collection('Student').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': encryptedPassword, // Store encrypted password
          'major': _selectedMajor, // Store selected major
          'skills': allSkills, // Store all skills in a single array
          'gpa': _gpaController.text.trim(),
          'gpaScale': _selectedGpaScale, // Save selected GPA scale
          'location': _selectedLocations,
          'nationality': _selectedNationality,
          'uid': user.uid,
          'role': 'student', // Store the user role as 'student'
          'profilePic': avatarUrl,
        });

        ProviderScope.containerOf(context).read(uidProvider.notifier).state =
            user.uid;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StudentHomePage()),
        );
      }
    } on TimeoutException {
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
        _formKey.currentState!.validate();
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
