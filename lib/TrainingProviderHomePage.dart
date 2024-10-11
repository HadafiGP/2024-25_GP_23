import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrainingProviderHomePage extends StatefulWidget {
  const TrainingProviderHomePage({Key? key}) : super(key: key);

  @override
  _TrainingProviderHomePageState createState() =>
      _TrainingProviderHomePageState();
}

class _TrainingProviderHomePageState extends State<TrainingProviderHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _userId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userId = _auth.currentUser?.uid; // Get the current logged-in user's ID
  }

  Future<void> _addJob() async {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Job'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Job Title',
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Job Description',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _firestore
                    .collection('TrainingProvider')
                    .doc(_userId)
                    .collection('Jobs')
                    .add({
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'created_at': FieldValue.serverTimestamp(),
                });
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteJob(String jobId) async {
    await _firestore
        .collection('TrainingProvider')
        .doc(_userId)
        .collection('Jobs')
        .doc(jobId)
        .delete();
  }

  Future<void> _editJob(
      String jobId, String currentTitle, String currentDescription) async {
    TextEditingController titleController =
        TextEditingController(text: currentTitle);
    TextEditingController descriptionController =
        TextEditingController(text: currentDescription);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Job'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Job Title',
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Job Description',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _firestore
                    .collection('TrainingProvider')
                    .doc(_userId)
                    .collection('Jobs')
                    .doc(jobId)
                    .update({
                  'title': titleController.text,
                  'description': descriptionController.text,
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Provider Home'),
        backgroundColor: const Color(0xFF113F67),
      ),
      body: _userId == null
          ? const Center(child: Text('No user logged in'))
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('TrainingProvider')
                  .doc(_userId)
                  .collection('Jobs')
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (_isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text('No job postings found.'));
                }
                var jobs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    var job = jobs[index];
                    return ListTile(
                      title: Text(job['title']),
                      subtitle: Text(job['description']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editJob(
                                job.id, job['title'], job['description']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteJob(job.id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addJob,
        backgroundColor: const Color(0xFF113F67),
        child: const Icon(Icons.add),
      ),
    );
  }
}
