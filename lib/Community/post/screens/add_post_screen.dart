import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/controller/community_controller.dart';
import 'package:hadafi_application/StudentHomePage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hadafi_application/Community/model/community_model.dart';
import 'package:hadafi_application/Community/post/controller/post_controller.dart';
import 'package:hadafi_application/Community/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPostScreen extends ConsumerStatefulWidget {
  const AddPostScreen({super.key});

  @override
  ConsumerState<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends ConsumerState<AddPostScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<File> _imageFiles = []; // Changed to List<File>
  bool _isLoading = false;
  Community? _selectedCommunity;
  PageController _pageController = PageController();
  int _currentPage = 0;
  String _networkError = '';
  bool _isCheckingNetwork = false;
  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFiles != null) {
      setState(() {
        // Keep only up to 4 images
        final newImages = pickedFiles.map((file) => File(file.path)).toList();
        final remainingSlots = 4 - _imageFiles.length;
        if (remainingSlots > 0) {
          _imageFiles.addAll(newImages.take(remainingSlots));
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  // Add this method to check Firestore connection
  Future<bool> hasFirestoreConnection() async {
    try {
      await FirebaseFirestore.instance
          .collection('posts') // Changed to posts collection
          .limit(1)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 10));
      return true;
    } catch (_) {
      return false;
    }
  }

  void _showBanner(String message) {
    setState(() => _networkError = message);
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) setState(() => _networkError = '');
    });
  }

  // Modify the submitPost method to check connection
  Future<void> _submitPost() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    if (_selectedCommunity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a community')),
      );
      return;
    }

    setState(() => _isCheckingNetwork = true);
    final canReachFirestore = await hasFirestoreConnection();
    setState(() => _isCheckingNetwork = false);

    if (!canReachFirestore) {
      _showBanner("Cannot reach server. Please check your internet.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(PostControllerProvider.notifier).sharedPost(
            context: context,
            title: _titleController.text.trim(),
            selectedCommunity: _selectedCommunity!,
            description: _descriptionController.text.trim(),
            imageFiles: _imageFiles.isNotEmpty ? _imageFiles : null,
          );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Add this widget to show network errors
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

  @override
  Widget build(BuildContext context) {
    final userCommunities =
        ref.watch(userCommunityProvider(ref.read(uidProvider) ?? ''));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create Post",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF113F67),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              previousPage, // Replace with Navigator.pop(context) if needed
        ),
      ),
      drawer: _currentPage == 0 ? const HadafiDrawer() : null,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          if (_networkError.isNotEmpty) buildNetworkErrorBanner(_networkError),
          Expanded(
            child: userCommunities.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (communities) {
                if (communities.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "You haven't joined any community yet.\nJoin a community first to share posts.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  );
                }

                // Set default selected community if not set
                if (_selectedCommunity == null && communities.isNotEmpty) {
                  _selectedCommunity = communities.first;
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Select Community (Required)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF113F67),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0.0, vertical: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF113F67),
                                Color.fromRGBO(105, 185, 255, 1),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<Community>(
                                value: _selectedCommunity,
                                isExpanded: true,
                                hint: const Text(
                                  'Select a community',
                                  style: TextStyle(color: Colors.black54),
                                ),
                                items: communities.map((community) {
                                  return DropdownMenuItem<Community>(
                                    value: community,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(community.avatar),
                                          radius: 14,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(community.name),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (community) {
                                  setState(() {
                                    _selectedCommunity = community;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      // Title Label
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Post Title (Required)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF113F67),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

// Title TextField
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'Write a clear and catchy title.',
                          hintStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 152, 161, 168),
                          ),
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.all(18),
                        ),
                        maxLength: 50,
                      ),
                      const SizedBox(height: 20),

// Description Label
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Post Description (Optional)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF113F67),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

// Description TextField
                      TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          hintText: 'Add more details about your post...',
                          hintStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 152, 161, 168),
                          ),
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.all(18),
                        ),
                        maxLines: 5,
                        maxLength: 300,
                      ),

                      const SizedBox(height: 16),

                      if (_imageFiles.isNotEmpty)
                        Column(
                          children: [
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1,
                              ),
                              itemCount: _imageFiles.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        _imageFiles[index],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                    Positioned(
                                        top: 4,
                                        right: 4,
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.9),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                              child: IconButton(
                                            onPressed: () =>
                                                _removeImage(index),
                                            icon: Icon(
                                              Icons.close,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                            padding: EdgeInsets
                                                .zero, // Remove default padding
                                            constraints:
                                                BoxConstraints(), // Remove minimum size constraints
                                            splashRadius:
                                                18, // Control the splash effect size
                                          )),
                                        )),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      // Update the Add Image button to show remaining slots
                      if (_imageFiles.length < 4)
                        Center(
                          child: ElevatedButton(
                            onPressed: _pickImages,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF113F67),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'Add Image (${4 - _imageFiles.length} remaining)',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Submit Button
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        Center(
                          child: ElevatedButton(
                            onPressed: _submitPost,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              backgroundColor: const Color(0xFF113F67),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Post',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

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
}
