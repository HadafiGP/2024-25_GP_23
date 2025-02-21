import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/controller/community_controller.dart';
import 'package:hadafi_application/Community/common/loader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hadafi_application/Community/constants/constants.dart';
import 'package:hadafi_application/Community/repoistory/communitory_repository.dart';

class AddCommunityScreen extends ConsumerStatefulWidget {
  const AddCommunityScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddCommunityScreenState();
}

class _AddCommunityScreenState extends ConsumerState<AddCommunityScreen> {
  final TextEditingController communityNameController = TextEditingController();
  final TextEditingController communityDescription = TextEditingController();
  PageController _pageController = PageController();
  int _currentPage = 0;
  String? avatarPath;
  String? bannerPath;
  List<String> selectedTopics = [];

  Future pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile == null) return;

      setState(() {
        bannerPath = pickedFile.path;
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
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
  void dispose() {
    super.dispose();
    communityNameController.dispose();
    communityDescription.dispose();
    _pageController.dispose();
  }

void nextPage() async {
  if (_currentPage == 0) {
    if (communityNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a community name"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (communityDescription.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a description"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }


    bool communityExists = await ref.read(communityControllerProvider.notifier)
        .checkIfCommunityExists(communityNameController.text.trim());

    if (communityExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Community with this name already exists! Choose another name."),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return; 
    }
  }


  if (_currentPage < 2) {
    _pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}



  void previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void createCommunity() {
    if (communityNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a community name"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (communityDescription.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a description"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedTopics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one topic"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ref.read(communityControllerProvider.notifier).createCommunity(
          communityNameController.text.trim(),
          communityDescription.text.trim(),
          avatarPath ?? Constants.avatarDefault,
          bannerPath ?? Constants.bannerDefault,
          selectedTopics,
          context
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF113F67),
        title: Text(
          'Create Community',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: previousPage,
        ),
      ),
      body: isLoading
          ? const Loader()
          : PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildCommunityInfoPage(),
                _buildCommunityMediaPage(),
                _buildCommunityTopicsPage(),
              ],
            ),
    );
  }

  // Page 1:
  Widget _buildCommunityInfoPage() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          const Text(
            "Step 1 of 3",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.topLeft,
            child: const Text(
              "Write community name & description",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.center,
            child: const Text(
              "A description will help pepole understand your community",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Community Name (Required)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: communityNameController,
            decoration: InputDecoration(
              hintText: "r/Community_name",
              filled: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.all(18),
            ),
            maxLength: 21,
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Community Description (Required)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: communityDescription,
            decoration: InputDecoration(
              hintText: "Description",
              filled: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.all(18),
            ),
            maxLength: 500,
            maxLines: 5,
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: () {
              nextPage();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF113F67),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  "Next",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Page 2:
  Widget _buildCommunityMediaPage() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: const Text(
                  "Step 2 of 3",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.topLeft,
                child: const Text(
                  "Style your community",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.center,
                child: const Text(
                  "Select the banner and avatar of your community",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.topLeft,
                child: const Text(
                  'Choose a Banner (Optional)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      await pickImage(ImageSource.gallery);
                      setState(() {});
                    },
                    icon: Icon(Icons.image, color: Colors.white),
                    label: Text(
                      "Gallery",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 236, 236, 236)),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF113F67)),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await pickImage(ImageSource.camera);
                      setState(() {});
                    },
                    icon: Icon(Icons.camera_alt, color: Colors.white),
                    label: Text(
                      "Camera",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 236, 236, 236)),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF113F67)),
                  ),
                ],
              ),
              if (bannerPath != null) ...[
                const SizedBox(height: 10),
                Align(
                    alignment: Alignment.topLeft,
                    child: Text("✅ Banner selected!",
                        style: TextStyle(color: Colors.green))),
              ],
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.topLeft,
                child: const Text(
                  'Choose an Avatar (Optional)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                          color: const Color.fromARGB(255, 236, 236, 236)),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF113F67)),
                  ),
                  SizedBox(width: 10),
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
                          color: const Color.fromARGB(255, 236, 236, 236)),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF113F67)),
                  ),
                ],
              ),
              if (avatarPath != null) ...[
                const SizedBox(height: 10),
                Align(
                    alignment: Alignment.topLeft,
                    child: Text("✅ Avatar selected!",
                        style: TextStyle(color: Colors.green))),
              ],
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  nextPage();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF113F67),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      "Next",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Page 3:

  Widget _buildCommunityTopicsPage() {
    List<Map<String, dynamic>> topics = [
      {
        "category": "Training Opportunities Related",
        "topics": [
          "Summer Internships",
          "COOP Training",
          'Remote training opportunities',
          'Training search tips'
        ]
      },
      {
        "category": "Industry-Specific Discussions",
        "topics": [
          "Technology & IT",
          "Engineering & Design",
          "Healthcare",
          "Finance & Business",
          "Marketing & Advertising",
          "Law",
          "Freelancing",
        ]
      },
      {
        "category": "Soft Skills  & Personal Development",
        "topics": [
          "Communication Skills",
          "Leadership & Teamwork",
          "CV advice",
        ]
      },
      {
        "category": "University Life & Support",
        "topics": [
          "University Advice",
          "Scholarships & Grants",
          "Balancing Study & Other Work"
        ]
      },
      {
        "category": "Student Networking & Growth",
        "topics": [
          "Events & Career Fairs",
          "Internship Meetups",
          'Industry Expert Q&A Sessions',
          'Mentorship & Career Guidance'
        ]
      },
      {
        "category": "Locations",
        "topics": [
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
        ]
      }
    ];

    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: const Text(
                  "Step 3 of 3",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.topLeft,
                child: const Text(
                  "Choose community topics",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.center,
                child: const Text(
                  "Add up to 3 topics to help users find your community",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Topics: ${selectedTopics.length}/3",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: selectedTopics.length == 3
                        ? Colors.green
                        : Colors.black),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: topics.length,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topics[index]["category"],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Wrap(
                          spacing: 8.0,
                          children: (topics[index]["topics"] as List<String>)
                              .map(
                                (topic) => ChoiceChip(
                                  label: Text(
                                    topic,
                                    style: TextStyle(
                                      color: selectedTopics.contains(topic)
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  selected: selectedTopics.contains(topic),
                                  selectedColor: const Color(0xFF113F67),
                                  checkmarkColor: Colors.white,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        if (selectedTopics.length < 3) {
                                          selectedTopics.add(topic);
                                        }
                                      } else {
                                        selectedTopics.remove(topic);
                                      }
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 10),
                      ],
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  createCommunity();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF113F67),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text(
                  "Create Community",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
