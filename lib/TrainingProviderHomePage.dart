import 'package:flutter/material.dart';

class TrainingProviderHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF096499),
        iconTheme: IconThemeData(color: Colors.white), // White menu button
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'Hadafi/images/LOGO.png', // Path to the logo
              fit: BoxFit.contain,
              height: 50, // Adjust logo size
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF096499),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Navigate to Post New Opportunity page'),
                ));
              },
              child: Text(
                'Post New Opportunity',
                style:
                    TextStyle(color: Colors.white), // Set text color to white
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Posted Opportunities',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF096499),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Example number of posted opportunities
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFF096499), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text('Opportunity ${index + 1}'),
                        subtitle:
                            Text('Details about opportunity ${index + 1}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Deleted Opportunity ${index + 1}'),
                            ));
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
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
                'Hadafi/images/LOGO.png',
                fit: BoxFit.contain,
                height: 80,
              ),
            ),
            ListTile(
              leading:
                  Icon(Icons.person, color: Color(0xFF2F83C5)), // Profile icon
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProviderProfilePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.home, color: Color(0xFF2F83C5)), // Home icon
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Color(0xFF2F83C5)),
              title: Text('Log Out'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Logged Out'),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProviderProfilePage extends StatefulWidget {
  @override
  _ProviderProfilePageState createState() => _ProviderProfilePageState();
}

class _ProviderProfilePageState extends State<ProviderProfilePage> {
  // Variables to hold editable fields
  String companyName = 'Example Corp.';
  String email = 'example@corp.com';
  String companyLocation = 'Riyadh, Saudi Arabia';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Color(0xFF096499), // AppBar color set to match theme
        iconTheme: IconThemeData(color: Colors.white), // White icon color
        actions: [
          IconButton(
            icon: Icon(Icons.save,
                color: Colors.white), // Save icon color to white
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Profile Updated'),
              ));
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEditableProfileField('Company Name:', companyName, (value) {
              setState(() {
                companyName = value;
              });
            }),
            SizedBox(height: 16), // Consistent spacing
            _buildEditableProfileField('Email:', email, (value) {
              setState(() {
                email = value;
              });
            }),
            SizedBox(height: 16), // Consistent spacing
            _buildEditableProfileField('Company Location:', companyLocation,
                (value) {
              setState(() {
                companyLocation = value;
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
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
                'Hadafi/images/LOGO.png',
                fit: BoxFit.contain,
                height: 80,
              ),
            ),
            ListTile(
              leading:
                  Icon(Icons.person, color: Color(0xFF2F83C5)), // Profile icon
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.home, color: Color(0xFF2F83C5)), // Home icon
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TrainingProviderHomePage()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Color(0xFF2F83C5)),
              title: Text('Log Out'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Logged Out'),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableProfileField(
      String label, String initialValue, ValueChanged<String> onChanged) {
    TextEditingController controller =
        TextEditingController(text: initialValue);
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: 8.0), // Add vertical margin for spacing
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // Consistent border radius
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF096499), width: 2.0),
            borderRadius: BorderRadius.circular(12), // Consistent border radius
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
