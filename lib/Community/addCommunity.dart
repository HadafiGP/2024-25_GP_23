import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/controller/community_controller.dart';
import 'package:hadafi_application/Community/common/loader.dart';
import 'package:hadafi_application/StudentHomePage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hadafi_application/Community/constants/constants.dart';
import 'package:hadafi_application/Community/repoistory/communitory_repository.dart';
import "package:hadafi_application/Community/CommunityHomeScreen.dart";
import 'package:connectivity_plus/connectivity_plus.dart';

class CreateACommunity extends ConsumerStatefulWidget {
  const CreateACommunity({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddCommunityScreenState();
}

class _AddCommunityScreenState extends ConsumerState<CreateACommunity> {
  final TextEditingController communityNameController = TextEditingController();
  final TextEditingController communityDescription = TextEditingController();
  PageController _pageController = PageController();
  int _currentPage = 0;
  String? avatarPath;
  String? bannerPath;
  List<String> selectedTopics = [];
  String _networkError = '';
  bool _isCheckingNetwork = false;
  bool _isCreatingCommunity = false;

  //Community Banner: Camera/Gallery
  Future pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile == null) {
        _showError("Image selection cancelled.");
        return;
      }

      final file = File(pickedFile.path);

      if (!file.existsSync()) {
        _showError("Selected file is missing or deleted.");
        return;
      }

      final fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        // 5 MB limit
        _showError("File too large. Please select an image under 5MB.");
        return;
      }

      final extension = pickedFile.path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
        _showError("Unsupported file format. Use JPG, PNG, or GIF.");
        return;
      }

      setState(() {
        bannerPath = pickedFile.path;
      });
    } on PlatformException catch (e) {
      _showError("Permission denied or system error: $e");
    } catch (e) {
      _showError("Unexpected error: $e");
    }
  }

  //Community Avatar: Camera/Gallery
  Future pickImage2(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile == null) {
        _showError("Image selection cancelled.");
        return;
      }

      final file = File(pickedFile.path);

      if (!file.existsSync()) {
        _showError("Selected file is missing or deleted.");
        return;
      }

      final fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        _showError("File too large. Please select an image under 5MB.");
        return;
      }

      final extension = pickedFile.path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
        _showError("Unsupported file format. Use JPG, PNG, or GIF.");
        return;
      }

      setState(() {
        avatarPath = pickedFile.path;
      });
    } on PlatformException catch (e) {
      _showError("Permission denied or system error: $e");
    } catch (e) {
      _showError("Unexpected error: $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
    communityNameController.dispose();
    communityDescription.dispose();
    _pageController.dispose();
  }

  Future<bool> hasFirestoreConnection() async {
    try {
      await FirebaseFirestore.instance
          .collection('Community')
          .limit(1)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 10));
      return true;
    } catch (_) {
      return false;
    }
  }

  //Coomunity creation pages
  Future<void> nextPage() async {
    if (_currentPage == 0) {
      final name = communityNameController.text.trim();
      final description = communityDescription.text.trim();

      if (name.isEmpty) {
        _showError("Please enter a community name");
        return;
      }
      if (description.isEmpty) {
        _showError("Please enter a description");
        return;
      }

      setState(() => _isCheckingNetwork = true);
      bool communityExists = false;

      try {
        communityExists = await ref
            .read(communityControllerProvider.notifier)
            .checkIfCommunityExists(name)
            .timeout(const Duration(seconds: 10));
      } catch (e) {
        _showBanner("No internet connection. Please check your network.");
        setState(() => _isCheckingNetwork = false);
        return;
      }

      setState(() => _isCheckingNetwork = false);

      if (communityExists) {
        _showError(
            "Community with this name already exists! Choose another name.");
        return;
      }
    }

    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showBanner(String message) {
    setState(() => _networkError = message);
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) setState(() => _networkError = '');
    });
  }

//Navigates through the creation steps, if in the first page navigate back to the "Create Community" page
  void previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage = _currentPage - 1;
      });
    } else {
      Navigator.pop(context);
    }
  }

//Save community to Firstore if all required information is filled
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

    setState(() => _isCreatingCommunity = true);
    //Save community in Firebase
    () async {
      final canReachFirestore = await hasFirestoreConnection();
      if (!canReachFirestore) {
        _showBanner("Cannot reach Firestore. Please check your internet.");
        setState(() => _isCreatingCommunity = false);
        return;
      }

      // Proceed to create community
      try {
        await ref.read(communityControllerProvider.notifier).createCommunity(
              communityNameController.text.trim(),
              communityDescription.text.trim(),
              avatarPath ?? Constants.avatarDefault,
              bannerPath ?? Constants.bannerDefault,
              selectedTopics,
              context,
            );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Community created successfully!"),
            duration: Duration(seconds: 5),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
        setState(() {
          _isCreatingCommunity = false;
          communityNameController.clear();
          communityDescription.clear();
          selectedTopics.clear();
          avatarPath = null;
          bannerPath = null;
          _currentPage = 0;
          _pageController.jumpToPage(0);
        });
      } catch (e) {
        _showBanner("Unexpected error occurred. Please try again.");
        setState(() => _isCreatingCommunity = false);
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Communities", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF113F67),
        leading: _currentPage == 0
            ? Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: previousPage,
              ),
      ),
      drawer: _currentPage == 0 ? const HadafiDrawer() : null,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_networkError.isNotEmpty)
              buildNetworkErrorBanner(_networkError),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
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
            ),
          ],
        ),
      ),
    );
  }

  // Page 1:
  Widget _buildCommunityInfoPage() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: const Text(
              "Step 1 of 3",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 152, 161, 168),
              ),
            ),
          ),
          const SizedBox(height: 5),
          const Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Community Name (Required)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF113F67),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: communityNameController,
            decoration: InputDecoration(
              hintText: "Pick a name that represents your community well.",
              hintStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 152, 161, 168),
              ),
              filled: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.all(18),
            ),
            maxLength: 21,
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Community Description (Required)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF113F67),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: communityDescription,
            decoration: InputDecoration(
              hintText:
                  "A description will help pepole understand your community",
              hintStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 152, 161, 168),
              ),
              filled: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.all(18),
            ),
            maxLength: 500,
            maxLines: 5,
          ),
          const SizedBox(height: 40),
          _isCheckingNetwork
              ? const CircularProgressIndicator()
              : GestureDetector(
                  onTap: () async {
                    await nextPage();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF113F67),
                      borderRadius: BorderRadius.circular(30),
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
                )
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
                    color: Color.fromARGB(255, 152, 161, 168),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.topLeft,
                child: const Text(
                  "Style your community",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF113F67),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.topLeft,
                child: const Text(
                  "A banner and avatar define your community's identity",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 152, 161, 168),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.topLeft,
                child: const Text(
                  'Choose a Banner (Optional)',
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
                        backgroundColor:
                            const Color.fromARGB(255, 0, 118, 208)),
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
                        backgroundColor: const Color.fromARGB(255, 0, 176, 15)),
                  ),
                ],
              ),
              if (bannerPath != null) ...[
                const SizedBox(height: 10),
                Align(
                    alignment: Alignment.topLeft,
                    child: Text("✅ Banner selected!",
                        style: TextStyle(
                            color: const Color.fromARGB(255, 0, 176, 15)))),
              ],
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.topLeft,
                child: const Text(
                  'Choose an Avatar (Optional)',
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
                          color: const Color.fromARGB(255, 236, 236, 236)),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 0, 118, 208)),
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
                        backgroundColor: const Color.fromARGB(255, 0, 176, 15)),
                  ),
                ],
              ),
              if (avatarPath != null) ...[
                const SizedBox(height: 10),
                Align(
                    alignment: Alignment.topLeft,
                    child: Text("✅ Avatar selected!",
                        style: TextStyle(
                            color: const Color.fromARGB(255, 0, 176, 15)))),
              ],
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () {
                  nextPage();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF113F67),
                    borderRadius: BorderRadius.circular(30),
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
        "category": "💼 Training Opportunities Related",
        "topics": [
          "Internships",
          "COOP Training",
          'Remote',
          'On-site',
          'Hybrid',
          'Paid',
          'Unpaid',
          "Over The Summer",
          'Full-time',
          'Part-time',
          'Government Sector',
          'Private Sector',
          'Training search tips',
        ]
      },
      {
        "category": "📚 Industry-Specific Discussions",
        "topics": [
          'Business & Management',
          'Education & Training',
          'Information Technology & Computer Science',
          'Engineering & Industrial Technologies',
          'Healthcare & Medical Fields',
          'Arts, Design & Creative Media',
          'Humanities & Social Sciences',
          'Law, Government & Public Policy',
          'Science & Mathematics',
          'Hospitality & Tourism'
        ]
      },
      {
        "category": "🌱 Soft Skills  & Personal Development",
        "topics": [
          "Communication Skills",
          "Leadership & Teamwork",
          "CV advice",
          'Workplace Etiquette',
          'Presentation & Public Speaking Skills',
          'Interview Preparation'
        ]
      },
      {
        "category": "🏫 University Life & Support",
        "topics": [
          "University Advice",
          "Scholarships & Grants",
          "Balancing Study & Other Work",
          'Clubs, Volunteering & Extracurricular',
          'COOP Report Templates & Examples'
        ]
      },
      {
        "category": "🌐 Student Networking & Growth",
        "topics": [
          'Hackathons & Competition',
          "Internship Meetups",
          'Networking for Introverts',
          'Networking Tips',
          'Industry Expert Q&A',
          "Events & Career Fairs",
          'Mentorship & Career Guidance',
          'Professional Associations',
          'Online Networking & Profile Building',
          'Student Conferences & Summits',
        ]
      },
      {
        "category": "📍 Locations",
        "topics": [
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
                    color: Color.fromARGB(255, 152, 161, 168),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    "Choose community topics",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF113F67),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "(${selectedTopics.length}/3)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: selectedTopics.length == 3
                          ? Colors.red
                          : Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.topLeft,
                child: const Text(
                  "Add up to 3 topics to help others find your community.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 152, 161, 168),
                  ),
                ),
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF113F67),
                          ),
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
                                    ),
                                  ),
                                  selected: selectedTopics.contains(topic),
                                  selectedColor:
                                      const Color.fromARGB(255, 0, 118, 208),
                                  checkmarkColor: Colors.white,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        if (selectedTopics.length < 3) {
                                          selectedTopics.add(topic);
                                        } else {
                                          // Trying to add more than 3 topics.
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Only 3 topics can be added"),
                                              duration: Duration(seconds: 2),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
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
              _isCreatingCommunity
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        createCommunity();
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: const Color(0xFF113F67),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // نفس الزوايا
                        ),
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

  Widget buildNetworkErrorBanner(String message) {
    return Container(
      width: double.infinity,
      color: Colors.red,
      padding: const EdgeInsets.all(12),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: Colors.white),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
