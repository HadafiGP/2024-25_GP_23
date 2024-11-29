import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadafi_application/signup_widget.dart';
import 'package:hadafi_application/StudentHomepage.dart';
import 'package:crypto/crypto.dart';
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

  final List<String> _technicalSkills = [
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
    "Financial Forecasting",
    "Financial Modeling",
    "Firewalls",
    "Git and GitHub",
    "GCP",
    "Google Ads",
    "Google Analytics",
    "Hadoop",
    "HTML",
    "Investment Analysis",
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

  final List<String> _softSkills = [
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
    "Goal-Oriented Mindset",
    "Influence",
    "Interpersonal Skills",
    "Leadership",
    "Logical Reasoning",
    "Motivational Skills",
    "Negotiation",
    "Networking",
    "Openness to New Ideas",
    "Organization",
    "Patience",
    "Presentation Skills",
    "Problem Solving",
    "Proactive Initiative",
    "Public Speaking",
    "Relationship Building",
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

  final List<String> _managementSkills = [
    "Adapting to Organizational Changes",
    "Budgeting Tools",
    "Business Strategy",
    "Change Management",
    "Client Relationship Management",
    "Conflict Resolution",
    "Cost Analysis",
    "Crisis Management",
    "Delegation",
    "Expense Tracking",
    "Facilitating Transitions Smoothly",
    "Forecasting",
    "Innovation Management",
    "Leadership",
    "Mentorship",
    "Operational Planning",
    "People Management",
    "Performance Evaluation",
    "Process Improvement",
    "Project Lifecycle Management",
    "Project Planning and Coordination",
    "Resource Management",
    "Risk Assessment",
    "Stakeholder Management",
    "Strategic Planning",
    "Supply Chain Management",
    "Task Prioritization",
    "Team Building",
    "Timeline Setting",
    "Vendor Management"
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

// List of all available majors (no college dependency)
  final List<String> _majors = [
    'Clinical Laboratory Sciences',
    'Occupational Therapy',
    'Physical Therapy',
    'Prosthetics and Orthotics',
    'Radiology',
    'Architecture',
    'Graphic Design',
    'Industrial Design',
    'Interior Design',
    'Urban Planning',
    'Arabic Language and Literature',
    'English Language and Literature',
    'Geography',
    'History',
    'Psychology',
    'Sociology',
    'Accounting',
    'Business Administration',
    'Finance',
    'Human Resources Management',
    'International Business',
    'Management Information Systems',
    'Marketing',
    'Supply Chain Management',
    'Artificial Intelligence',
    'Computer Science',
    'Cybersecurity',
    'Data Science',
    'Information Systems',
    'Information Technology',
    'Software Engineering',
    'Dentistry',
    'Oral and Maxillofacial Surgery',
    'Orthodontics',
    'Art Education',
    'Counseling and Guidance',
    'Educational Technology',
    'Early Childhood Education',
    'Physical Education',
    'Special Education',
    'Biomedical Engineering',
    'Chemical Engineering',
    'Civil Engineering',
    'Electrical Engineering',
    'Environmental Engineering',
    'Industrial Engineering',
    'Mechanical Engineering',
    'Petroleum Engineering',
    'Environmental Studies',
    'Geographical Information Systems (GIS)',
    'Geology',
    'Clinical Nutrition',
    'Health Informatics',
    'Medical Laboratory Sciences',
    'Nursing',
    'Public Health',
    'Radiologic Technology',
    'Respiratory Therapy',
    'Islamic History',
    'Islamic Studies',
    'Quranic Studies',
    'Islamic Law (Sharia)',
    'Law',
    'Medicine (MBBS)',
    'Surgery',
    'Clinical Pharmacy',
    'Pharmaceutical Sciences',
    'Pharmacy',
    'Biology',
    'Chemistry',
    'Environmental Science',
    'Mathematics',
    'Physics',
    'Anthropology',
    'International Relations',
    'Political Science',
    'Social Work',
    'Agribusiness',
    'Agricultural Engineering',
    'Animal Science',
    'Food Science and Nutrition',
    'Plant Science',
    'Auditing',
    'Public Relations',
    'Frontend Development',
    'Economics'
  ];

  final GlobalKey<FormFieldState<String>> _nameKey = GlobalKey();
  final GlobalKey<FormFieldState<String>> _emailKey = GlobalKey();
  final GlobalKey<FormFieldState<String>> _passwordKey = GlobalKey();
  final GlobalKey<FormFieldState<String>> _gpaKey = GlobalKey();

  void _scrollToFirstError() {
    // تحقق من الحقول المرتبطة بـ TextFormField
    for (var key in [_nameKey, _emailKey, _passwordKey, _gpaKey]) {
      if (key.currentState != null && key.currentState is FormFieldState) {
        final fieldState = key.currentState as FormFieldState<String>;
        if (!fieldState.validate()) {
          final context = key.currentContext;
          if (context != null) {
            final renderBox = context.findRenderObject() as RenderBox;
            final offset = renderBox.localToGlobal(Offset.zero).dy;

            _scrollController.animateTo(
              offset - 100, // تعديل المسافة لتكون واضحة أسفل الحقل
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
          return; // توقف بعد العثور على أول حقل يحتوي على خطأ
        }
      }
    }

    // تحقق من القيم غير المرتبطة بـ FormFieldState
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

// دالة مساعدة لتحريك الشاشة إلى الحقل بناءً على GlobalKey
  void _scrollToElement(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      final renderBox = context.findRenderObject() as RenderBox;
      final offset = renderBox.localToGlobal(Offset.zero).dy;

      _scrollController.animateTo(
        offset - 100, // مسافة أعلى الحقل
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

    // Add a listener to clear email error when the user changes the email input
    _emailController.addListener(() {
      if (_emailError != null) {
        setState(() {
          _emailError = null;
        });
      }
    });
    _filteredMajors.addAll(_majors); // Initialize with all majors
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
                controller: _scrollController, // ScrollController
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
                      _buildTextField(
                        'Password (required)',
                        _passwordController, key: _passwordKey,

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
                        onChanged: (value) =>
                            _validatePassword(value), // Call validation method
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
                      _buildPasswordGuidance(), //password guidance here

                      const SizedBox(height: 15),

                      _buildMajorDropdown(key: _majorKey),
                      const SizedBox(height: 15),
                      _buildLocationSelector(key: _locationKey),
                      const SizedBox(height: 15),
                      _buildNationalitySelector(key: _nationalityKey),
                      const SizedBox(height: 15),

// GPA Scale and GPA Field Placement
                      Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Align buttons to the left
                        children: [
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

                      const SizedBox(height: 25),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Skills: ",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _isSkillsSelected
                                        ? Color(0xFF113F67)
                                        : Colors.red, // Conditional color
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                              height: 8), // Add some spacing if needed
                          Text(
                            "Please choose at least one skill from any category",
                            style: TextStyle(
                              fontSize: 14,
                              color: _isSkillsSelected
                                  ? Color(0xFF113F67)
                                  : Colors.red, // Same conditional color
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),
                      _buildManagementSkillsSelector(), // Management Skills Dropdown
                      const SizedBox(height: 15),
                      _buildSoftSkillsSelector(), // Soft Skills Dropdown
                      const SizedBox(height: 15),
                      _buildTechnicalSkillsSelector(), // Technical Skills Dropdown
                      const SizedBox(height: 25),
                      _isLoading
                          ? CircularProgressIndicator()
                          : // Sign Up button with separate skills validation
                          ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _hasAttemptedSubmit = true;

                                  // Manually validate skills selection
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
                                  _signUp(); // Proceed if form and skills validation pass
                                }
                              },
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    Key? key,
    bool isPassword = false,
    bool enabled = true,
    String? Function(String?)? validator,
    Function(String)? onChanged, // Add onChanged parameter
    Widget? suffixIcon, // New parameter for suffix icon
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible, // Toggle visibility
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: suffixIcon, //suffix icon
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
      color = Colors.green; // Met criteria: Green
      icon = Icons.check_circle; // Check icon
    } else if (_hasAttemptedSubmit) {
      color = Colors.red; // Unmet criteria after submit attempt: Red
      icon = Icons.cancel; // Cancel icon
    } else {
      color = Colors.grey; // Unmet criteria before submit: Grey
      icon = Icons.radio_button_unchecked; // Neutral icon
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
          controller: _majorController, // Use the dedicated controller
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
      _filteredMajors = _majors; // Initialize with all majors
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
                      _majorController.text =
                          _selectedMajor!; // Update controller text
                    }
                    Navigator.of(context)
                        .pop(); // Close dialog when OK is pressed
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
            _showSkillsDialog("Select Technical Skills", _technicalSkills,
                _selectedTechnicalSkills);
          },
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Select Technical Skills',
                suffixIcon: const Icon(Icons.arrow_drop_down),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              controller: TextEditingController(
                text: _selectedTechnicalSkills
                    .join(', '), // Display selected skills as text
              ),
            ),
          ),
        ),
        const SizedBox(height: 8), // Space between TextFormField and Chips

        // Display selected skills as Chips
        Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          children: _selectedTechnicalSkills.map((skill) {
            return Chip(
              label: Text(skill),
              onDeleted: () {
                setState(() {
                  _selectedTechnicalSkills
                      .remove(skill); // Remove skill from list
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

// Management Skills Dropdown
  Widget _buildManagementSkillsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            _showSkillsDialog("Select Management Skills", _managementSkills,
                _selectedManagementSkills);
          },
          child: AbsorbPointer(
            child: TextFormField(
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
        const SizedBox(height: 8), // Space between TextFormField and Chips

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

// Soft Skills Dropdown
  Widget _buildSoftSkillsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            _showSkillsDialog(
                "Select Soft Skills", _softSkills, _selectedSoftSkills);
          },
          child: AbsorbPointer(
            child: TextFormField(
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
        const SizedBox(height: 8), // Space between TextFormField and Chips

        // Display selected skills as Chips
        Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          children: _selectedSoftSkills.map((skill) {
            return Chip(
              label: Text(skill),
              onDeleted: () {
                setState(() {
                  _selectedSoftSkills.remove(skill); // Remove skill from list
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
    List<String> filteredSkillsList =
        List.from(skillsList); // Make a copy for filtering
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
                        filteredSkillsList = skillsList
                            .where((skill) => skill
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
                    setState(
                        () {}); // This updates the selected skills display when dialog closes
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Make sure to update the main screen after dialog closes to reflect selected skills as chips
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
              controller: TextEditingController(
                  text: _selectedLocations
                      .join(', ')), // Update field with selected locations
              validator: (value) {
                if (_selectedLocations.isEmpty) {
                  return 'Please select at least one location';
                }
                return null;
              },
            ),
          ),
        ),
        const SizedBox(height: 8), // Space between TextFormField and Chips

        // Display selected locations as Chips
        Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          children: _selectedLocations.map((location) {
            return Chip(
              label: Text(location),
              onDeleted: () {
                setState(() {
                  _selectedLocations
                      .remove(location); // Remove location from list
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showLocationDialog() {
    _filteredCities = _cities; // Reset the filtered cities list

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
                    Navigator.of(context).pop(); // Close dialog
                    setState(
                        () {}); // Refresh the main widget state to reflect changes
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
        _locationController.text = _selectedLocations
            .join(', '); // Ensure field text is updated after dialog
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
    _emailController
        .dispose(); // Dispose of the controller when the widget is removed
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

        List<String> allSkills = [
          ..._selectedTechnicalSkills,
          ..._selectedManagementSkills,
          ..._selectedSoftSkills
        ];

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
        // Re-run form validation to display the error immediately
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
