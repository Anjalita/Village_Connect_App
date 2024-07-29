import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'admin_announcements_screen.dart';
import 'admin_enquiry_screen.dart';
import 'admin_suggestion_screen.dart';
import 'admin_console_screen.dart'; // Import your AdminConsolePage

class AdminHomeScreen extends StatefulWidget {
  final String username;

  AdminHomeScreen({required this.username});

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  List<Map<String, dynamic>> _pendingUsers = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _selectedIndex = 0;
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _fetchPendingUsers();
  }

  Future<void> _fetchPendingUsers() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.5.1:3000/pending-users'), // Replace with your IP address
      );

      if (response.statusCode == 200) {
        setState(() {
          _pendingUsers =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load pending users';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again later.';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserActivation(int userId, bool activate) async {
    final endpoint = activate ? 'activate-user' : 'deactivate-user';
    try {
      final response = await http.post(
        Uri.parse(
            'http://192.168.5.1:3000/$endpoint'), // Replace with your IP address
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, int>{'user_id': userId}),
      );

      if (response.statusCode == 200) {
        _fetchPendingUsers(); // Refresh the list
      } else {
        setState(() {
          _errorMessage = 'Failed to update user status';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again later.';
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pending User Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Username: ${user['username']}',
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('Name: ${user['name']}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('Phone: ${user['phone']}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('Email: ${user['email']}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('Address: ${user['address']}',
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('Occupation: ${user['job_title']}',
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                          _updateUserActivation(user['id'], true);
                        },
                        child: Text('Accept'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                          _updateUserActivation(user['id'], false);
                        },
                        child: Text('Reject'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image with opacity
          Opacity(
            opacity: 0.5, // Adjust the opacity value as needed
            child: Image.asset(
              'assets/images/admin.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          // Main content
          Column(
            children: [
              // AppBar
              _selectedIndex == 0
                  ? AppBar(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Village Connect Admin'),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.admin_panel_settings,
                                    color: Colors.black),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AdminConsolePage(), // Navigate to the Admin Console Page
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.logout, color: Colors.black),
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, '/');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      backgroundColor:
                          Colors.teal, // Set background to transparent
                      elevation: 0, // Remove shadow
                      automaticallyImplyLeading: false, // Disable back button
                    )
                  : Container(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  children: <Widget>[
                    _buildPendingUsersPage(),
                    AdminAnnouncementPage(),
                    AdminEnquiryScreen(),
                    AdminSuggestionsScreen(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement),
            label: 'Announcements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer),
            label: 'Enquiries',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.speaker_notes),
            label: 'Suggestions',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildPendingUsersPage() {
    return Scaffold(
      backgroundColor:
          Colors.transparent, // Ensure the background is transparent
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0), // Add padding here
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _pendingUsers.length,
                          itemBuilder: (context, index) {
                            final user = _pendingUsers[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16.0),
                                title: Text(user['name']),
                                subtitle:
                                    Text('Occupation: ${user['job_title']}'),
                                onTap: () {
                                  _showUserDetails(
                                      user); // Show the details in a dialog
                                },
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.check,
                                          color: Colors.green),
                                      onPressed: () {
                                        _updateUserActivation(user['id'], true);
                                      },
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.close, color: Colors.red),
                                      onPressed: () {
                                        _updateUserActivation(
                                            user['id'], false);
                                      },
                                    ),
                                  ],
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
}
