import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminManagementPage extends StatefulWidget {
  @override
  _AdminManagementPageState createState() => _AdminManagementPageState();
}

class _AdminManagementPageState extends State<AdminManagementPage> {
  List<dynamic> adminUsers = [];
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAdmins();
  }

  Future<void> _fetchAdmins() async {
    final response =
        await http.get(Uri.parse('http://192.168.5.1:3000/admin/users'));

    if (response.statusCode == 200) {
      setState(() {
        adminUsers = json.decode(response.body);
      });
    } else {
      // Handle the error
      print('Failed to load admin users');
    }
  }

  Future<void> _removeAdmin(int userId) async {
    final response = await http.post(
      Uri.parse('http://192.168.5.1:3000/remove-admin'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, int>{
        'user_id': userId,
      }),
    );

    if (response.statusCode == 200) {
      _fetchAdmins();
    } else {
      // Handle the error
      print('Failed to remove admin');
    }
  }

  Future<void> _addAdmin() async {
    final response = await http.post(
      Uri.parse('http://192.168.5.1:3000/add-admin'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': _usernameController.text,
        'password': _passwordController.text,
        'name': _nameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'job_title': _jobTitleController.text,
        'email': _emailController.text,
      }),
    );

    if (response.statusCode == 200) {
      _fetchAdmins();
      Navigator.pop(context); // Close the dialog on success
      _clearForm();
    } else {
      // Handle the error
      print('Failed to add admin');
    }
  }

  void _clearForm() {
    _usernameController.clear();
    _passwordController.clear();
    _nameController.clear();
    _phoneController.clear();
    _addressController.clear();
    _jobTitleController.clear();
    _emailController.clear();
  }

  void _showAddAdminDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add New Admin', style: TextStyle(fontSize: 24)),
                  _buildTextField(
                      _usernameController, 'Username', Icons.person),
                  _buildTextField(_passwordController, 'Password', Icons.lock,
                      obscureText: true),
                  _buildTextField(_nameController, 'Name', Icons.badge),
                  _buildTextField(_phoneController, 'Phone', Icons.phone),
                  _buildTextField(_addressController, 'Address', Icons.home),
                  _buildTextField(_jobTitleController, 'Job Title', Icons.work),
                  _buildTextField(_emailController, 'Email', Icons.email),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                        },
                        child:
                            Text('Cancel', style: TextStyle(color: Colors.red)),
                      ),
                      ElevatedButton(
                        onPressed: _addAdmin,
                        child: Text('Add Admin'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String labelText, IconData icon,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        obscureText: obscureText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Management'),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: 0.5, // Adjust the opacity as needed
            child: Image.asset(
              'assets/images/admin.png', // Ensure this path is correct
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: adminUsers.length,
                  itemBuilder: (context, index) {
                    final admin = adminUsers[index];
                    return Card(
                      color: Colors.white.withOpacity(0.8),
                      margin:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16.0),
                        title: Text(admin['name']),
                        subtitle: Text(admin['email']),
                        trailing: IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removeAdmin(admin['id']),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAdminDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
