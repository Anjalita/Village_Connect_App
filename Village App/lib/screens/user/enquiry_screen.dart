import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class EnquiryScreen extends StatefulWidget {
  final String username;

  EnquiryScreen({required this.username});

  @override
  _EnquiryScreenState createState() => _EnquiryScreenState();
}

class _EnquiryScreenState extends State<EnquiryScreen> {
  final TextEditingController _enquiryController = TextEditingController();
  List<Map<String, dynamic>> _enquiries = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchEnquiries();
  }

  Future<void> _fetchEnquiries() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.5.1:3000/queries?username=${widget.username}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> enquiriesJson = json.decode(response.body);
        setState(() {
          _enquiries =
              enquiriesJson.map((e) => Map<String, dynamic>.from(e)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load enquiries';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _errorMessage = 'An error occurred. Please try again later.';
        _isLoading = false;
      });
    }
  }

  Future<void> _createEnquiry() async {
    final matter = _enquiryController.text;
    if (matter.isEmpty) {
      return;
    }

    final newEnquiry = {
      'username': widget.username,
      'matter': matter,
      'time': DateTime.now().toIso8601String(),
    };

    try {
      final response = await http.post(
        Uri.parse('http://192.168.5.1:3000/createQuery'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newEnquiry),
      );

      if (response.statusCode == 200) {
        setState(() {
          _enquiries.insert(0, newEnquiry);
          _enquiryController.clear();
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to create enquiry';
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _errorMessage = 'An error occurred. Please try again later.';
      });
    }
  }

  DateTime convertUtcToIst(DateTime utcDateTime) {
    return utcDateTime.add(Duration(hours: 5, minutes: 30));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Opacity(
              opacity: 0.5, // Adjust opacity here
              child: Image.asset(
                'assets/images/user.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content on top of background image
          Column(
            children: [
              AppBar(
                title: Text('Enquiries'),
                backgroundColor: Colors.teal,
                elevation: 0,
              ),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                        ? Center(child: Text(_errorMessage))
                        : ListView.builder(
                            itemCount: _enquiries.length,
                            itemBuilder: (context, index) {
                              final enquiry = _enquiries[index];
                              final dateTimeUtc =
                                  DateTime.parse(enquiry['time']);
                              final dateTimeIst = convertUtcToIst(dateTimeUtc);

                              final formattedDate =
                                  DateFormat('dd-MM-yy').format(dateTimeIst);
                              final formattedTime =
                                  DateFormat('hh:mm a').format(dateTimeIst);

                              return Container(
                                margin: EdgeInsets.all(8.0),
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(
                                      0.8), // White background with opacity
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: ListTile(
                                  title: Text(
                                    enquiry['matter'],
                                    style: TextStyle(
                                      fontSize: 18, // Increased font size
                                    ),
                                  ),
                                  subtitle: Text(
                                    '$formattedDate • $formattedTime',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  onTap: () {
                                    _showEnquiryDialog(enquiry);
                                  },
                                ),
                              );
                            },
                          ),
              ),
              Container(
                margin: EdgeInsets.all(0),
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white
                      .withOpacity(1), // White background with opacity
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _enquiryController,
                        decoration: InputDecoration(
                          labelText: 'Enter your enquiry',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.send, color: Colors.teal),
                      onPressed: _createEnquiry,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEnquiryDialog(Map<String, dynamic> enquiry) {
    final dateTimeUtc = DateTime.parse(enquiry['time']);
    final dateTimeIst = convertUtcToIst(dateTimeUtc);

    final formattedDate = DateFormat('dd-MM-yy').format(dateTimeIst);
    final formattedTime = DateFormat('hh:mm a').format(dateTimeIst);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enquiry'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                enquiry['matter'],
                style: TextStyle(
                  fontSize: 18, // Increased font size
                ),
              ),
              SizedBox(height: 16),
              Text(
                enquiry['admin_response'] ?? 'Awaiting response',
                style: TextStyle(
                  color: enquiry['admin_response'] != null
                      ? Colors.black
                      : Colors.red,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '$formattedDate • $formattedTime',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
