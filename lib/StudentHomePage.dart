import 'package:flutter/material.dart';

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
                color: Color(0xFF096499),
              ),
              child: Image.asset(
                'assets/images/LOGO.png',
                fit: BoxFit.contain,
                height: 80,
              ),
            ),
            _buildDrawerItem(context, Icons.person, 'Profile', ProfilePage()),
            _buildDrawerItem(context, Icons.home, 'Home',
                StudentHomePage()), // Changed to StudentHomePage
            _buildDrawerItem(
                context, Icons.assignment, 'CV Enhancement Tool', null),
            _buildDrawerItem(context, Icons.chat, 'Interview Simulator', null),
            _buildDrawerItem(context, Icons.feedback, 'Feedback', null),
            _buildDrawerItem(context, Icons.group, 'Communities', null),
            _buildDrawerItem(context, Icons.favorite, 'Favorites List', null),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Color(0xFF2F83C5)),
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
      leading: Icon(icon, color: Color(0xFF2F83C5)),
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
        backgroundColor: Color(0xFF096499),
        actions: [
          Padding(
            padding: const EdgeInsets.all(1),
            child: Image.asset(
              'assets/images/LOGO.png',
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
          color: Color(0xFF096499),
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
                labelColor: Color(0xFF096499),
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color(0xFF096499),
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
              border: Border.all(color: Color(0xFF096499), width: 2),
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
              border: Border.all(color: Color(0xFF096499), width: 2),
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
  final TextEditingController _nameController =
      TextEditingController(text: "Jane Doe");
  final TextEditingController _emailController =
      TextEditingController(text: "jane.doe@example.com");
  final TextEditingController _gpaController =
      TextEditingController(text: "3.8");
  final TextEditingController _majorController =
      TextEditingController(text: "Software Engineering");
  final TextEditingController _skillsController =
      TextEditingController(text: "Dart, Flutter, Java");
  final TextEditingController _certificatesController =
      TextEditingController(text: "AWS Certified Developer");
  final TextEditingController _locationController =
      TextEditingController(text: "City, Country");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: HadafiDrawer(),
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Color(0xFF096499),
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
