import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadafi_application/TrainingProviderHomePage.dart';
import 'dart:ui';

import 'package:hadafi_application/style.dart';

class EditTpPostedOpportunity extends StatefulWidget {
  final String opportunityId;
  const EditTpPostedOpportunity({super.key, required this.opportunityId});

  @override
  State<EditTpPostedOpportunity> createState() =>
      _EditTpPostedOpportunityState();
}

class _EditTpPostedOpportunityState extends State<EditTpPostedOpportunity> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController companyLinkController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController majorController = TextEditingController();
  final TextEditingController gpa4Controller = TextEditingController();
  final TextEditingController gpa5Controller = TextEditingController();
  final TextEditingController jobTypeController = TextEditingController();
  final TextEditingController contactInfoController = TextEditingController();


  String? selectedJobType;
  List<String> selectedLocations = [];
  DateTime? startDate;
  DateTime? endDate;
List<String> selectedMajors = [];

  bool isEditing = false;
  bool isJobTitleValid = true;
  bool isJobTypeValid = true;
  bool isDescriptionValid = true;
  bool isLocationValid = true;
  bool isStartDateValid = true;
  bool isEndDateValid = true;
  bool isDurationValid = true;
  bool isMajorValid = true;
  bool isGpa4Valid = true;
  bool isGpa5Valid = true;
  bool isContactInfoValid = true;

  List<String> selectedSoftSkills = [];
  List<String> selectedTechnicalSkills = [];
  List<String> selectedManagementSkills = [];

  bool isSkillsValid = true;
  bool isGpaValid = true;

  // GPA validation
  String? _validateGPA(String? value, double maxGPA) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    final gpa = double.tryParse(value.trim());
    if (gpa == null) {
      return 'Please enter a valid number';
    }
    if (gpa <= 0) {
      return 'GPA cannot be less than or equal to 0';
    }
    if (gpa > maxGPA) {
      return 'GPA cannot exceed $maxGPA';
    }
    return null;
  }

List<String> getFilteredTechnicalSkills() {

  if (selectedMajors.every((major) => healthMajors.contains(major))) {
    return healthTechnicalSkills;
  } else if (selectedMajors.every((major) => humanitiesMajors.contains(major))) {
    return humanitiesTechnicalSkills;
  } else if (selectedMajors.every((major) => !healthMajors.contains(major) && !humanitiesMajors.contains(major))) {
  
    return scientificTechnicalSkills;
  } else {
 
    return technicalSkills;
  }
}

  final List<String> majors = [
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
    'Biomedical Engineering',
    'Chemical Engineering',
    'Civil Engineering',
    'Electrical Engineering',
    'Environmental Engineering',
    'Industrial Engineering',
    'Mechanical Engineering',
    'Petroleum Engineering',
    'Clinical Nutrition',
    'Health Informatics',
    'Medical Laboratory Sciences',
    'Nursing',
    'Public Health',
    'Radiologic Technology',
    'Respiratory Therapy',
    'Medicine (MBBS)',
    'Clinical Pharmacy',
    'Pharmacy',
    'Law',
    'Islamic Law (Sharia)',
    'Economics'
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

      //
  final List<String> jobTypes = ['Internship', 'COOP'];

  final List<String> durations = [
    '4 Weeks',
    '8 Weeks',
    '12 Weeks',
    '4 Months',
    '6 Months',
    '9 Months',
    '1 Year'
  ];
//
  final List<String> cities = [
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
    'Other'
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
    "Verbal and Written Clarity",
    "Workplace Etiquette",
    "Working Effectively Within Teams",
    "Networking",
    "Public Speaking",
    "Presentation Skills",
    "Relationship Building",
    "Willingness to learn"
  ];

  //tech

  final List<String> technicalSkills = [
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

  //mang

  final List<String> managementSkills = [
  "Adapting to Organizational Changes",
  "Change Management",
  "Client Relationship Management",
  "Conflict Resolution",
  "Crisis Management",
  "Creative Project Management",
  "Delegation",
  "Event Planning",
  "Expense Tracking",
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
  "Public Relations Management",
  "Resource Management",
  "Risk Assessment",
  "Stakeholder Management",
  "Strategic Planning",
  "Task Prioritization",
  "Team Building",
  "Timeline Setting"
  ];

  @override
  void initState() {
    super.initState();
    _loadOpportunityData();
  }

  Future<void> _loadOpportunityData() async {
    try {
      final opportunitySnapshot = await FirebaseFirestore.instance
          .collection('opportunity')
          .doc(widget.opportunityId)
          .get();

      final opportunityData = opportunitySnapshot.data();
      if (opportunityData != null) {
        jobTitleController.text = opportunityData['jobTitle'];
        jobTypeController.text = opportunityData['jobType'];
        descriptionController.text = opportunityData['description'];
        selectedLocations = List<String>.from(opportunityData['locations']);
        startDate = DateTime.parse(opportunityData['startDate']);
        endDate = DateTime.parse(opportunityData['endDate']);
        durationController.text = opportunityData['duration'];
        final majorsList = opportunityData['majors'];
if (majorsList is List) {
  selectedMajors = List<String>.from(majorsList);
} else if (majorsList is String) {
  selectedMajors = [majorsList]; 
}

        gpa4Controller.text = opportunityData['gpaOutOf4'];
        gpa5Controller.text = opportunityData['gpaOutOf5'];
        companyLinkController.text = opportunityData['companyLink'];
        contactInfoController.text = opportunityData['contactInfo'];


        selectedSoftSkills = List<String>.from(opportunityData['skills']
            .where((skill) => softSkills.contains(skill)));
        selectedTechnicalSkills = List<String>.from(opportunityData['skills']
            .where((skill) => technicalSkills.contains(skill)));
        selectedManagementSkills = List<String>.from(opportunityData['skills']
            .where((skill) => managementSkills.contains(skill)));

        setState(() {}); 
      }
    } catch (e) {
      print("Error loading opportunity data: $e");
    }
  }

  static const Color mainColor = Color(0xFF113F67);
  static const Color backgroundColor = Color(0xFFF3F9FB);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F9FB),
      appBar: AppBar(
        backgroundColor: Color(0xFF113F67),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text('Edit Opportunity', style: TextStyle(color: Colors.white)),
        actions: [
          if (!isEditing) 
            IconButton(
              icon: const Icon(Icons.edit), 
              onPressed: () {
                setState(() {
                  isEditing = true; 
                });
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          controller: _scrollController, 
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 15),
                _buildTextField('Opportunitiy Title', jobTitleController),
                const SizedBox(height: 15),
                _buildDropdown('Opportunitiy Type', jobTypeController, jobTypes, (value) {
                  setState(() => jobTypeController.text = value);
                }),
                const SizedBox(height: 15),
                _buildTextField('Description', descriptionController, maxLines: 3),
                const SizedBox(height: 15),
                _buildMultiSelectField('Select Locations', cities, selectedLocations),
                const SizedBox(height: 15),
                _buildDatePicker('Start Date', startDate, (picked) {
                  setState(() {
                    startDate = picked;
                  });
                }),
                const SizedBox(height: 15),
                _buildDatePicker('End Date', endDate, (picked) {
                  setState(() {
                    endDate = picked;
                  });
                }),
                const SizedBox(height: 15),
                _buildDropdown('Duration', durationController, durations, (value) {
                  setState(() {
                    durationController.text = value;
                  });
                }),
                const SizedBox(height: 15),
                _buildMultiSelectField('Select Majors', majors, selectedMajors),
                const SizedBox(height: 15),
                  Align(
  alignment: Alignment.centerLeft,  
  child: Text(
    "GPA:",
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Color(0xFF113F67),
    ),
  ),
),

                _buildGpaInputs(),

      Column(
  crossAxisAlignment: CrossAxisAlignment.start,  
  children: [
    Align(
      alignment: Alignment.centerLeft,  
      child: Text(
        "Skills:",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isSkillsValid ? Color(0xFF113F67) : Colors.red,
        ),
      ),
    ),
    Align(
      alignment: Alignment.centerLeft,  
      child: Text(
        "Please choose at least one skill from any category",
        style: TextStyle(
          fontSize: 14,
          color: isSkillsValid ? Color(0xFF113F67) : Colors.red,
        ),
      ),
    ),
  ],
)
,
                const SizedBox(height: 15),
                _buildSkillSelector("Select Soft Skills", softSkills, selectedSoftSkills),
                const SizedBox(height: 15),
                _buildSkillSelector("Select Technical Skills", getFilteredTechnicalSkills(), selectedTechnicalSkills),

                const SizedBox(height: 15),
                _buildSkillSelector("Select Management Skills", managementSkills, selectedManagementSkills),
                const SizedBox(height: 15),
                _buildTextField('Contact Info', contactInfoController),
                const SizedBox(height: 15),
                _buildTextField('Company Apply Link(Optional)', companyLinkController, isRequired: false),
                const SizedBox(height: 30),
                if (isEditing)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _saveData,
                        // style: ElevatedButton.styleFrom(
                        //   backgroundColor: Color(0xFF113F67),
                        //   padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        // ),
                        style: smallButtonStyle,
                        child: const Text('Save', style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {

                            
                            isEditing = false;
                          });
                        },
                        // style: ElevatedButton.styleFrom(
                        //   backgroundColor: Colors.white,
                        //   padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        // ),
                        style:kSecondaryButtonStyle,
                        child: const Text('Cancel', style: TextStyle(color: Color(0xFF113F67))),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }


//Helper methods

Widget _buildTextField(String label, TextEditingController controller,
    {int maxLines = 1,
    bool isRequired = true,
    String? Function(String?)? validator}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextFormField(
        controller: controller,
        maxLines: maxLines,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: validator ??
            (isRequired
                ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'This field is required'; 
                    }
                    return null;
                  }
                : null),
        enabled: isEditing, 
      ),
      const SizedBox(height: 5),

    ],
  );
}


Widget _buildDropdown(String label, TextEditingController controller,
    List<String> items, Function(String) onSelected) {
  return GestureDetector(
    onTap: isEditing
        ? () => _showSelectionDialog(label, items, controller, onSelected)
        : null,
    child: AbsorbPointer(
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.arrow_drop_down),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) => value == null || value.trim().isEmpty
            ? 'This field is required'
            : null,
        enabled: isEditing, 
      ),
    ),
  );
}

void _showSelectionDialog(String title, List<String> items, TextEditingController controller, Function(String) onSelected) {
  List<String> filteredItems = List.from(items);  

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Text(
              title,
              style: TextStyle(color: mainColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
     
            TextField(
              decoration: const InputDecoration(labelText: 'Search'),
              onChanged: (value) {
                setState(() {
        
                  filteredItems = items.where((item) => item.toLowerCase().contains(value.toLowerCase())).toList();
                });
              },
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: filteredItems.map((item) => RadioListTile<String>(
              title: Text(item),
              value: item,
              groupValue: controller.text,
              activeColor: mainColor,
              onChanged: (value) {
                controller.text = value!;
                onSelected(value);
                Navigator.of(context).pop(); 
              },
            )).toList(),
          ),
        ),
      ),
    ),
  );
}
Widget _buildMultiSelectField(
  String label,
  List<String> items,
  List<String> selectedItems,
) {
  return FormField<List<String>>(
    validator: (_) {
      if (selectedItems.isEmpty) {
        return 'Please select at least one ';
      }
      return null;
    },
    builder: (state) {
      final contentText =
          selectedItems.isEmpty ? 'No selection' : selectedItems.join(', ');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: isEditing
                ? () async {
                    await _showMultiSelectDialog(label, items, selectedItems);
                    setState(() {
                      state.didChange(selectedItems); 
                    });
                  }
                : null,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: label,
                suffixIcon: const Icon(Icons.arrow_drop_down),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabled: isEditing,
                errorText: state.errorText,
              ),
              child: Text(
                contentText,
                style: TextStyle(
                  fontSize: 16,
                  color: isEditing ? Colors.black : Colors.black54,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children: selectedItems
                .map((item) => Chip(
                      backgroundColor: Colors.white,
                      label: Text(item),
                      deleteIconColor: const Color(0xFF113F67),
                      onDeleted: isEditing
                          ? () {
                              setState(() {
                                selectedItems.remove(item);
                                state.didChange(selectedItems); 
                              });
                            }
                          : null,
                    ))
                .toList(),
          ),
        ],
      );
    },
  );
}


Future<void> _showMultiSelectDialog(
  String title, List<String> items, List<String> selectedItems) async {
  List<String> filteredItems = List.from(items);

  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Text(
              title,
              style: TextStyle(color: mainColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(labelText: 'Search'),
              onChanged: (value) {
                setState(() {
                  filteredItems = items
                      .where((item) => item.toLowerCase().contains(value.toLowerCase()))
                      .toList();
                });
              },
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            children: filteredItems
                .map((item) => CheckboxListTile(
                      value: selectedItems.contains(item),
                      title: Text(item),
                      activeColor: mainColor,
     onChanged: (checked) {
  setState(() {
    if (checked == true) {
      if (!selectedItems.contains(item)) {
        selectedItems.add(item); 
      }
    } else {
      selectedItems.remove(item);
    }
  });
},

                    ))
                .toList(),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
  setState(() {
    selectedItems = selectedItems.toSet().toList();
  });
  Navigator.pop(context);
},

            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}






  Widget _buildGpaInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Minimum GPA Requirement (out of 4)',
          style: TextStyle(fontSize: 14, color: Color(0xFF113F67)),
        ),
        const SizedBox(height: 10),
        _buildTextField(
          'GPA (out of 4)',
          gpa4Controller,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter GPA out of 4';
            }

            final gpa = double.tryParse(value.trim());
            if (gpa == null) {
              return 'Please enter a valid number';
            }
            if (gpa <= 0) {
              return 'GPA cannot be 0';
            }
            if (gpa > 4.0) {
              return 'GPA must not exceed 4.00';
            }

            final regex = RegExp(r'^\d+(\.\d{1,2})?$');
            if (!regex.hasMatch(value.trim())) {
              return 'Use up to two decimal places (e.g., 3.25)';
            }

            gpa4Controller.text = gpa.toStringAsFixed(2); 
            return null;
          },
        ),
        const SizedBox(height: 15),
        Text(
          'Minimum GPA Requirement (out of 5)',
          style: TextStyle(fontSize: 14, color: Color(0xFF113F67)),
        ),
        const SizedBox(height: 10),
        _buildTextField(
          'GPA (out of 5)',
          gpa5Controller,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter GPA out of 5';
            }

            final gpa = double.tryParse(value.trim());
            if (gpa == null) {
              return 'Please enter a valid number';
            }
            if (gpa <= 0) {
              return 'GPA cannot be 0';
            }
            if (gpa > 5.0) {
              return 'GPA must not exceed 5.00';
            }

            final regex = RegExp(r'^\d+(\.\d{1,2})?$');
            if (!regex.hasMatch(value.trim())) {
              return 'Use up to two decimal places (e.g., 4.50)';
            }

            gpa5Controller.text = gpa.toStringAsFixed(2);
            return null;
          },
        ),
      ],
    );
  }


Widget _buildDatePicker(
      String label, DateTime? selectedDate, Function(DateTime) onPicked) {
    return GestureDetector(
      onTap: () async {
        if (isEditing) { 
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(2023),
            lastDate: DateTime(2030),
            builder: (context, child) {
              return Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light(
                    primary: mainColor,
                    onPrimary: Colors.white,
                    surface: backgroundColor,
                    onSurface: Colors.black,
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: mainColor,
                    ),
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            onPicked(picked);
          }
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(
            text: selectedDate != null
                ? '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}'
                : '',
          ),
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) => (value == null || value.trim().isEmpty)
              ? 'This field is required'
              : null,
          enabled: isEditing,
        ),
      ),
    );
  }

Widget _buildSkillSelector(
  String label,
  List<String> allSkills,
  List<String> selectedSkills,
) {
  return FormField<List<String>>(
    validator: (_) {
      if (selectedSoftSkills.isEmpty &&
          selectedTechnicalSkills.isEmpty &&
          selectedManagementSkills.isEmpty) {
        return 'Please choose at least one skill';
      }
      return null;
    },
    builder: (state) {
      final contentText =
          selectedSkills.isEmpty ? 'No skills selected' : selectedSkills.join(', ');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: isEditing
                ? () async {
                    await _showMultiSelectDialog(label, allSkills, selectedSkills);
                    setState(() {
                      state.didChange(selectedSkills); 
                    });
                  }
                : null,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: label,
                suffixIcon: const Icon(Icons.arrow_drop_down),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabled: isEditing,
                errorText: state.errorText,
              ),
              child: Text(
                contentText,
                style: TextStyle(
                  fontSize: 16,
                  color: isEditing ? Colors.black : Colors.black54,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: selectedSkills
                .map(
                  (skill) => Chip(
                    label: Text(skill),
                    backgroundColor: Colors.white,
                    deleteIconColor: const Color(0xFF113F67),
                    onDeleted: isEditing
                        ? () {
                            setState(() {
                              selectedSkills.remove(skill);
                              state.didChange(selectedSkills);
                            });
                          }
                        : null,
                  ),
                )
                .toList(),
          ),
        ],
      );
    },
  );
}




void _saveData() async {
  if (_formKey.currentState!.validate()) {

    if (selectedSoftSkills.isEmpty && selectedTechnicalSkills.isEmpty && selectedManagementSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one skill")
                                                  , duration: Duration(seconds: 2),
        backgroundColor: Colors.red,),
      );
      return;
    }


    final gpa4 = double.tryParse(gpa4Controller.text);
    final gpa5 = double.tryParse(gpa5Controller.text);

    if (gpa4 != null && (gpa4 <= 0 || gpa4 > 4.0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("GPA out of 4 should be between 0 and 4.0")                      , duration: Duration(seconds: 2),
        backgroundColor: Colors.red,),
      );
      return;
    }

    if (gpa5 != null && (gpa5 <= 0 || gpa5 > 5.0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("GPA out of 5 should be between 0 and 5.0")                      , duration: Duration(seconds: 2),
        backgroundColor: Colors.red,),
      );
      return;
    }

    try {
     
      final opportunityData = {
        'jobTitle': jobTitleController.text.trim(),
        'jobType': jobTypeController.text.trim(),
        'description': descriptionController.text.trim(),
        'locations': selectedLocations,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'duration': durationController.text.trim(),
        'majors': selectedMajors,

        'gpaOutOf4': gpa4Controller.text.trim(),
        'gpaOutOf5': gpa5Controller.text.trim(),
        'companyLink': companyLinkController.text.trim(),
        'contactInfo': contactInfoController.text.trim(),
  'skills': [
  ...{...selectedTechnicalSkills},
  ...{...selectedSoftSkills},
  ...{...selectedManagementSkills},
],

        'providerUid': FirebaseAuth.instance.currentUser!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      };


      await FirebaseFirestore.instance
          .collection('opportunity')
          .doc(widget.opportunityId)
          .update(opportunityData);


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Opportunity updated successfully")                      , duration: Duration(seconds: 2),
        backgroundColor: Colors.green,),
      );


      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TrainingProviderHomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update opportunity: $e")                      , duration: Duration(seconds: 2),
        backgroundColor: Colors.red,),
      );
    }
  }
}




}