import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProfilePage extends StatefulWidget {
  final String username;

  UserProfilePage({required this.username});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _isEditing = false;
  Map<String, dynamic> _userData = {};
  bool _isLoading = true;
  String _errorMessage = '';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      print('Fetching data for username: ${widget.username}');
      final response = await http.get(
        Uri.parse(
            'http://192.168.5.1:3000/user/profile?username=${widget.username}'),
      );

      print('Response status: ${response.statusCode}');
      //print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _userData = data;
          _nameController.text = data['name'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _addressController.text = data['address'] ?? '';
          _jobTitleController.text = data['job_title'] ?? '';
          _emailController.text = data['email'] ?? '';
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _errorMessage = 'User not found. Please check the username.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load user data: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _errorMessage = 'An error occurred while fetching user data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserData() async {
    try {
      final response = await http.put(
        Uri.parse('http://192.168.5.1:3000/user/profile/update'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'username': widget.username,
          'name': _nameController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'job_title': _jobTitleController.text,
          'email': _emailController.text,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isEditing = false;
          _fetchUserData(); // Refresh user data
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to update user data: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred while updating user data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Adjusts the body to avoid the keyboard overlay
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _updateUserData();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/user_home',
                ModalRoute.withName('/'),
                arguments: widget.username,
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 75, // Increased size
                          backgroundImage: _userData['dpUrl'] != null
                              ? NetworkImage(_userData['dpUrl'])
                              : AssetImage('assets/images/user.jpg')
                                  as ImageProvider,
                        ),
                        SizedBox(height: 16.0),
                        _buildTextField('Name', _nameController,
                            Color.fromARGB(255, 51, 138, 128)),
                        _buildTextField('Phone Number', _phoneController,
                            Color.fromARGB(255, 51, 138, 128)),
                        _buildTextField('Address', _addressController,
                            Color.fromARGB(255, 51, 138, 128)),
                        _buildTextField('Job Title', _jobTitleController,
                            Color.fromARGB(255, 51, 138, 128)),
                        _buildTextField('Email', _emailController,
                            Color.fromARGB(255, 51, 138, 128)),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: color), // Change label color
          border: OutlineInputBorder(),
        ),
        enabled: _isEditing,
        style: TextStyle(color: color), // Change text color
      ),
    );
  }
}
