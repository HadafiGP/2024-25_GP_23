import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/controller/community_controller.dart';
import 'package:hadafi_application/Community/common/loader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hadafi_application/Community/constants/constants.dart';
import 'package:hadafi_application/Community/repoistory/communitory_repository.dart';
import "package:hadafi_application/Community/CommunityHomeScreen.dart";
import 'package:connectivity_plus/connectivity_plus.dart';

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
  String _networkError = '';
  bool _isCheckingNetwork = false;

  //Community Banner: Camera/Gallery
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

  //Community Avatar: Camera/Gallery
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

  Future<bool> hasRealInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException {
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
    //Save community in Firebase
    ref.read(communityControllerProvider.notifier).createCommunity(
        communityNameController.text.trim(),
        communityDescription.text.trim(),
        avatarPath ?? Constants.avatarDefault,
        bannerPath ?? Constants.bannerDefault,
        selectedTopics,
        context);

    //Navigate to the "Create Community" page
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => Communityhomescreen(initialIndex: 0)),
      (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            "Community created successfully! If it doesn't appear, please check your internet."),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
          : SafeArea(
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
        "category": "💼 Training Opportunities Related",
        "topics": [
          "Summer Internships",
          "COOP Training",
          'Remote training opportunities',
          'Training search tips'
        ]
      },
      {
        "category": "📚 Industry-Specific Discussions",
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
        "category": "🌱 Soft Skills  & Personal Development",
        "topics": [
          "Communication Skills",
          "Leadership & Teamwork",
          "CV advice",
        ]
      },
      {
        "category": "🏫 University Life & Support",
        "topics": [
          "University Advice",
          "Scholarships & Grants",
          "Balancing Study & Other Work"
        ]
      },
      {
        "category": "🌐 Student Networking & Growth",
        "topics": [
          "Events & Career Fairs",
          "Internship Meetups",
          'Industry Expert Q&A Sessions',
          'Mentorship & Career Guidance'
        ]
      },
      {
        "category": "📍 Locations",
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
              ElevatedButton(
                onPressed: () async {
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
