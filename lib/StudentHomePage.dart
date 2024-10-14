import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadafi_application/interview.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StudentHomePage();
  }
}

class HadafiDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color(0xFFF3F9FB),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF113F67),
              ),
              child: Image.asset(
                'Hadafi/images/LOGO.png',
                fit: BoxFit.contain,
                height: 80,
              ),
            ),
            _buildDrawerItem(context, Icons.person, 'Profile', ProfilePage()),
            _buildDrawerItem(context, Icons.home, 'Home',
                StudentHomePage()), // Changed to StudentHomePage
            _buildDrawerItem(
                context, Icons.assignment, 'CV Enhancement Tool', null),
            _buildDrawerItem(
              context,
              Icons.chat,
              'Interview Simulator',
              InterviewPage(),
            ),
            _buildDrawerItem(context, Icons.feedback, 'Feedback', null),
            _buildDrawerItem(context, Icons.group, 'Communities', null),
            _buildDrawerItem(context, Icons.favorite, 'Favorites List', null),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Color(0xFF113F67)),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Logged out')));
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
      leading: Icon(icon, color: Color(0xFF113F67)),
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
}

class StudentHomePage extends StatelessWidget {
  // Changed from HomePage to StudentHomePage
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: HadafiDrawer(),
      appBar: AppBar(
        backgroundColor: Color(0xFF113F67),
        actions: [
          Padding(
            padding: const EdgeInsets.all(1),
            child: Image.asset(
              'Hadafi/images/LOGO.png',
              fit: BoxFit.contain,
              height: 300,
            ),
          ),
        ],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildSectionTitle('Training Opportunities'),
            _buildOpportunitiesTab(),
            _buildSectionTitle('Feedback from Users'),
            _buildFeedbackList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF113F67),
        ),
      ),
    );
  }

  Widget _buildOpportunitiesTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        height: 490,
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                labelColor: Color(0xFF113F67),
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color(0xFF113F67),
                tabs: [
                  Tab(text: 'Best Match'),
                  Tab(text: 'Other'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    OpportunitiesList(title: 'Best Match Opportunities'),
                    OpportunitiesList(title: 'Other Opportunities'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackList() {
    return Container(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 200,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF113F67), width: 2),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 5, spreadRadius: 2),
              ],
            ),
            child: ListTile(
              title: Text('User ${index + 1}'),
              subtitle: Text('This app helped me find a great internship!'),
            ),
          );
        },
      ),
    );
  }
}

class OpportunitiesList extends StatelessWidget {
  final String title;

  OpportunitiesList({required this.title});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Color(0xFF113F67), width: 2),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 5, spreadRadius: 2),
              ],
            ),
            child: ListTile(
              title: Text('$title ${index + 1}'),
              subtitle: Text('Based on your qualifications'),
            ),
          ),
        );
      },
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _gpaController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _certificatesController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadStudentData(); // Load student data on profile page load
  }

  // Function to load student data from Firestore
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
            _gpaController.text = doc['gpa'] ?? '';
            _majorController.text = doc['major'] ?? '';
            _skillsController.text =
                (doc['skills'] as List<dynamic>).join(', ') ?? '';
            _certificatesController.text =
                (doc['certificates'] as List<dynamic>).join(', ') ?? '';
            _locationController.text =
                (doc['location'] as List<dynamic>).join(', ') ?? '';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: HadafiDrawer(),
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Color(0xFF113F67),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Profile saved')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildEditableField('Student Name', _nameController),
            _buildEditableField('Email', _emailController),
            _buildEditableField('GPA', _gpaController),
            _buildEditableField('Major', _majorController),
            _buildEditableField('Skills', _skillsController),
            _buildEditableField('Certificates', _certificatesController),
            _buildEditableField('Location', _locationController),
          ],
        ),
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
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
