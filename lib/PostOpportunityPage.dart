import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadafi_application/TrainingProviderHomePage.dart';
import 'package:hadafi_application/style.dart';

class PostOpportunityPage extends StatefulWidget {
  const PostOpportunityPage({super.key});

  @override
  State<PostOpportunityPage> createState() => _PostOpportunityPageState();
}

class _PostOpportunityPageState extends State<PostOpportunityPage> {

  final _formKey = GlobalKey<FormState>();
    final ScrollController _scrollController = ScrollController();

  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController companyLinkController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  
  final TextEditingController gpa4Controller = TextEditingController();
  final TextEditingController gpa5Controller = TextEditingController();
   final TextEditingController jobTypeController = TextEditingController();
   final TextEditingController contactInfoController = TextEditingController();



  List<String> selectedMajors = [];
  String? selectedJobType;
  List<String> selectedLocations = [];
  // List<String> selectedSkills = [];
  DateTime? startDate;
  DateTime? endDate;

  List<String> selectedSoftSkills = [];
List<String> selectedTechnicalSkills = [];
List<String> selectedManagementSkills = [];

  bool isSkillsValid = true;
  bool isJobTitleValid = true;
  bool isJobTypeValid = true;
  bool isDescriptionValid = true;
  bool isLocationValid = true;
  bool isStartDateValid = true;
  bool isEndDateValid = true;
  bool isDurationValid = true;
  bool isMajorsValid = true;
  bool isGpa4Valid = true;
  bool isGpa5Valid = true;
  bool isContactInfoValid = true;



  

  final List<String> majors = [
    'Clinical Laboratory Sciences', 'Occupational Therapy', 'Physical Therapy',
    'Prosthetics and Orthotics', 'Radiology', 'Architecture', 'Graphic Design',
    'Industrial Design', 'Interior Design', 'Urban Planning', 'Accounting',
    'Business Administration', 'Finance', 'Human Resources Management',
    'International Business', 'Management Information Systems', 'Marketing',
    'Supply Chain Management', 'Artificial Intelligence', 'Computer Science',
    'Cybersecurity', 'Data Science', 'Information Systems', 'Information Technology',
    'Software Engineering', 'Dentistry', 'Oral and Maxillofacial Surgery', 'Orthodontics',
    'Biomedical Engineering', 'Chemical Engineering', 'Civil Engineering', 'Electrical Engineering',
    'Environmental Engineering', 'Industrial Engineering', 'Mechanical Engineering', 'Petroleum Engineering',
    'Clinical Nutrition', 'Health Informatics', 'Medical Laboratory Sciences', 'Nursing',
    'Public Health', 'Radiologic Technology', 'Respiratory Therapy', 'Medicine (MBBS)',
    'Clinical Pharmacy', 'Pharmacy', 'Law', 'Islamic Law (Sharia)', 'Economics'
  ];

  final List<String> jobTypes = ['Internship', 'COOP'];

  final List<String> durations = [
    '4 Weeks',
    '8 Weeks',
    '12 Weeks',
    '4 Months',
    '6 Months',
    '9 Months',
    '1 Year',
];

  final List<String> cities = [
    'Abha', 'Al Ahsa', 'Al Khobar', 'Al Qassim', 'Dammam', 'Hail', 'Jeddah',
    'Jizan', 'Jubail', 'Mecca', 'Medina', 'Najran', 'Riyadh', 'Tabuk', 'Taif', 'Other'
  ];

  // final List<String> skills = [
  //   "Adobe XD", "Agile", "Angular", "API integration (REST)", "API integration (SOAP)", "ASP.NET", "AWS",
  //   "Azure", "Big Data Analytics", "Bitbucket", "Blockchain", "C#", "C++", "Cloud Architecture", "Confluence",
  //   "CRM systems", "CSS", "Cybersecurity", "Data Analysis", "Data Mining", "Data Visualization", "Database Design",
  //   "DevOps", "Docker", "Encryption", "Excel", "Express", "Figma", "Firebase", "Firewalls", "Git and GitHub",
  //   "GCP", "Hadoop", "HTML", "Java", "JavaScript", "Jest", "JIRA", "JUnit", "Kubernetes", "Machine Learning",
  //   "MATLAB", "Microsoft Office Suite", "MongoDB", "MS Project", "Network Fundamentals", "NoSQL", "Node.js",
  //   "NLP", "Object-Oriented Programming (OOP)", "Oracle APEX", "Penetration Testing", "PHP", "PL/SQL", "Postman",
  //   "Power BI", "PowerPoint", "Prototyping", "Python", "R Programming", "React", "Ruby", "Selenium", "Sketch",
  //   "SQL", "Statistical Analysis", "Supervised/Unsupervised Learning", "SVN", "Swift", "Tableau", "TensorFlow",
  //   "Trello", "UI/UX Design", "User Research", "VLOOKUP", "Vue.js", "Waterfall", "Web Development", "Word"
  // ];

  final List<String> softSkills = [
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

final List<String> managementSkills = [
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



  static const Color mainColor = Color(0xFF113F67);
  static const Color backgroundColor = Color(0xFFF3F9FB);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text('Post Opportunity', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            controller: _scrollController,
            

          children: [
            const SizedBox(height: 15),

            _buildTextField('Job Title', jobTitleController),
            if (!isJobTitleValid)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text("This field is required", style: TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 15),


            _buildDropdown('Job Type', jobTypeController, jobTypes, (value) {
              setState(() => jobTypeController.text = value);
            }),
            if (!isJobTypeValid)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text("This field is required", style: TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 15),

            _buildTextField('Description', descriptionController, maxLines: 3),
            if (!isDescriptionValid)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text("This field is required", style: TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 15),

            _buildMultiSelectField('Select Locations', cities, selectedLocations),
            if (!isLocationValid)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text("This field is required", style: TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 15),

            _buildDatePicker('Start Date', startDate, (picked) {
              setState(() {
                startDate = picked;
              });
            }),
            if (!isStartDateValid)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text("This field is required", style: TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 15),

            _buildDatePicker('End Date', endDate, (picked) {
              setState(() {
                endDate = picked;
              });
            }),
            if (!isEndDateValid)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text("This field is required", style: TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 15),

            _buildDropdown('Duration', durationController, durations, (value) {
              setState(() {
                durationController.text = value;
              });
            }),
            if (!isDurationValid)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text("This field is required", style: TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 15),

            _buildMultiSelectField('Select Majors', majors, selectedMajors),
            if (!isMajorsValid)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text("Please select at least one major", style: TextStyle(color: Colors.red)),
              ),

            const SizedBox(height: 15),

            Text("GPA:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF113F67))),
            const SizedBox(height: 5),
            _buildGpaInputs(),
            const SizedBox(height: 15),

            // _buildMultiSelectField('Select Skills', skills, selectedSkills),
            // const SizedBox(height: 15),

             /// Skills Section
              Text("Skills:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSkillsValid ? Color(0xFF113F67) : Colors.red)),
              Text(
                "Please choose at least one skill from any category",
                style: TextStyle(fontSize: 14, color: isSkillsValid ? Color(0xFF113F67) : Colors.red),
              ),
              const SizedBox(height: 15),
              _buildSkillSelector("Select Management Skills", managementSkills, selectedManagementSkills),
              const SizedBox(height: 15),
              _buildSkillSelector("Select Soft Skills", softSkills, selectedSoftSkills),
              const SizedBox(height: 15),
              _buildSkillSelector("Select Technical Skills", technicalSkills, selectedTechnicalSkills),
              const SizedBox(height: 30),


              _buildTextField('Contact Info', contactInfoController),
              if (!isContactInfoValid)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text("This field is required", style: TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 15),



            _buildTextField('Company Apply Link(Optional)', companyLinkController, isRequired: false),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                //post button 

               ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isJobTitleValid = jobTitleController.text.trim().isNotEmpty;
                      isJobTypeValid = jobTypeController.text.trim().isNotEmpty;
                      isDescriptionValid = descriptionController.text.trim().isNotEmpty;
                      isLocationValid = selectedLocations.isNotEmpty;
                      isStartDateValid = startDate != null;
                      isEndDateValid = endDate != null;
                      isDurationValid = durationController.text.trim().isNotEmpty;
                      isMajorsValid = selectedMajors.isNotEmpty;
                      isGpa4Valid = gpa4Controller.text.trim().isNotEmpty;
                      isGpa5Valid = gpa5Controller.text.trim().isNotEmpty;
                      isContactInfoValid = contactInfoController.text.trim().isNotEmpty;
                      isSkillsValid = selectedTechnicalSkills.isNotEmpty ||
                          selectedSoftSkills.isNotEmpty ||
                          selectedManagementSkills.isNotEmpty;
                    });

                    bool isValid = isJobTitleValid &&
                        isJobTypeValid &&
                        isDescriptionValid &&
                        isLocationValid &&
                        isStartDateValid &&
                        isEndDateValid &&
                        isDurationValid && 
                        isMajorsValid&&
                        isGpa4Valid &&
                        isGpa5Valid && 
                        isContactInfoValid &&
                        isSkillsValid;

                    if (_formKey.currentState!.validate() && isValid) {
                      print("✅ Valid and ready to post");

                      // ✅ Show loading dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(child: CircularProgressIndicator()),
                      );

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
                            ...selectedTechnicalSkills,
                            ...selectedSoftSkills,
                            ...selectedManagementSkills,
                          ],
                          'providerUid': FirebaseAuth.instance.currentUser!.uid,
                          'createdAt': FieldValue.serverTimestamp(),
                        };

                        await FirebaseFirestore.instance
                            .collection('opportunity')
                            .add(opportunityData);

                        Navigator.pop(context); // Close loading
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Opportunity posted successfully")                      , duration: Duration(seconds: 2),
        backgroundColor: Colors.green,),
                        );

                        // ✅ Navigate to provider homepage
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => TrainingProviderHomePage()),
                        );
                      } catch (e) {
                        Navigator.pop(context); // Close loading
                        print("❌ Error posting opportunity: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Failed to post opportunity: $e")                      , duration: Duration(seconds: 2),
        backgroundColor: Colors.red,),
                          
                        );
                      }
                    } else {
                      print("❌ Fill all required fields including skills");
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style:  kMainButtonStyle,
                  child: const Text('Post', style: TextStyle(color: Colors.white)),
                ),



                //cancel button
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: kSecondaryButtonStyle,
                  child: const Text('Cancel', style: TextStyle(color: mainColor)),
                ),
              ],
            )
          ],
        ),
        ),
      ),
    );
  }

   Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, bool isRequired = true, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator ?? (isRequired ? (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      } : null),
    );
  }


    Widget _buildDropdown(String label, TextEditingController controller, List<String> items, Function(String) onSelected) {
    return GestureDetector(
      onTap: () => _showSelectionDialog(label, items, controller, onSelected),
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(Icons.arrow_drop_down),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) => value == null || value.trim().isEmpty ? 'This field is required' : null,
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
              Text(title, style: TextStyle(color: mainColor, fontWeight: FontWeight.bold)),
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

  Widget _buildMultiSelectField(String label, List<String> items, List<String> selectedItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            _showMultiSelectDialog(label, items, selectedItems);
          },
          child: AbsorbPointer(
            child: TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: label,
                suffixIcon: const Icon(Icons.arrow_drop_down),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              controller: TextEditingController(text: selectedItems.join(', ')),
              validator: (_) {
                if ((label.contains('Location') && selectedLocations.isEmpty) ||
                    (label.contains('Skill') && selectedTechnicalSkills.isEmpty)) {
                  return 'This field is required';
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
  children: selectedItems.map((item) => Chip(
  backgroundColor: Colors.white, // الخلفية بيضاء بدال البنفسجي
  label: Text(
    item,
    style: const TextStyle(color: Colors.black), // النص أسود
  ),
  deleteIconColor: mainColor, // لون أيقونة الحذف
  onDeleted: () {
    setState(() {
      selectedItems.remove(item);
    });
  },
)
).toList(),
)

      ],
    );
  }

  void _showMultiSelectDialog(String title, List<String> items, List<String> selectedItems) {
    List<String> filteredItems = List.from(items);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            children: [
              Text(title, style: TextStyle(color: mainColor, fontWeight: FontWeight.bold)),
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
          content: SingleChildScrollView(
            child: Column(
              children: filteredItems.map((item) => CheckboxListTile(
                value: selectedItems.contains(item),
                title: Text(item),
                activeColor: mainColor,
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      selectedItems.add(item);
                    } else {
                      selectedItems.remove(item);
                    }
                  });
                },
              )).toList(),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            )
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
                style: TextStyle(fontSize: 14, color: Color(0xFF113F67) ),
              ),
        const SizedBox(height: 5),
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

            gpa4Controller.text = gpa.toStringAsFixed(2); // Normalize format
            return null;
          },
        ),
        if (!isGpa4Valid)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text("This field is required", style: TextStyle(color: Colors.red)),
          ),


        const SizedBox(height: 15),

        Text(
                'Minimum GPA Requirement (out of 5)',
                style: TextStyle(fontSize: 14, color: Color(0xFF113F67) ),
              ),
        const SizedBox(height:5),
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

        if (!isGpa5Valid)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text("This field is required", style: TextStyle(color: Colors.red)),
          ),


      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime? selectedDate, Function(DateTime) onPicked) {
  return GestureDetector(
    onTap: () async {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(2023),
        lastDate: DateTime(2030),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: mainColor, // اللون الأساسي (header و الزر)
                onPrimary: Colors.white, // النص في الهيدر
                surface: backgroundColor, // خلفية الحوارات
                onSurface: Colors.black, // النص داخل البودي
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: mainColor, // لون أزرار Cancel و OK
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
        validator: (value) =>
            (value == null || value.trim().isEmpty) ? 'This field is required' : null,
      ),
    ),
  );
}


  Widget _buildSkillSelector(String label, List<String> allSkills, List<String> selectedSkills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showMultiSelectDialog(label, allSkills, selectedSkills),
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                labelText: label,
                suffixIcon: const Icon(Icons.arrow_drop_down),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              controller: TextEditingController(text: selectedSkills.join(', ')),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: selectedSkills
              .map((skill) => Chip(
                    label: Text(skill),
                    backgroundColor: Colors.white,
                    deleteIconColor: const Color(0xFF113F67),
                    onDeleted: () => setState(() => selectedSkills.remove(skill)),
                  ))
              .toList(),
        ),
      ],
    );
  }


}


