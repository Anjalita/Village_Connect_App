import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PendingUserDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  PendingUserDetailsScreen({required this.user});

  @override
  _PendingUserDetailsScreenState createState() =>
      _PendingUserDetailsScreenState();
}

class _PendingUserDetailsScreenState extends State<PendingUserDetailsScreen> {
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _updateUserActivation(bool activate) async {
    setState(() {
      _isLoading = true;
    });

    final endpoint = activate ? 'activate-user' : 'deactivate-user';
    try {
      final response = await http.post(
        Uri.parse(
            'http://192.168.5.1:3000/$endpoint'), // Replace with your IP address
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, int>{
          'user_id': widget.user['id'],
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true); // Pop with result true
      } else {
        setState(() {
          _errorMessage = 'Failed to update user status';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again later.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pending User Details'),
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false, // Disable back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Username: ${widget.user['username']}',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Name: ${widget.user['name']}',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Phone: ${widget.user['phone']}',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Email: ${widget.user['email']}',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Address: ${widget.user['address']}',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Occupation: ${widget.user['job_title']}',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _updateUserActivation(true),
                          child: Text('Accept'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _updateUserActivation(false),
                          child: Text('Reject'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Center(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
