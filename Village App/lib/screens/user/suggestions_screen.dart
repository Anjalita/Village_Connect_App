import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting date
import 'package:http/http.dart' as http;
import 'dart:convert';

class SuggestionsScreen extends StatefulWidget {
  final String username;

  SuggestionsScreen({required this.username});

  @override
  _SuggestionsScreenState createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _fetchSuggestions();
  }

  Future<void> _fetchSuggestions() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.5.1:3000/suggestions'), // Replace with your API URL
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _suggestions =
              data.map((dynamic item) => item as Map<String, dynamic>).toList();
        });
      } else {
        print(
            'Failed to load suggestions. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
    }
  }

  Future<void> _postSuggestion() async {
    final title = _titleController.text;
    final content = _contentController.text;

    try {
      final response = await http.post(
        Uri.parse(
            'http://192.168.5.1:3000/createSuggestion'), // Replace with your API URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'username': widget.username,
          'title': title,
          'content': content,
        }),
      );

      if (response.statusCode == 200) {
        _titleController.clear();
        _contentController.clear();
        _fetchSuggestions();
      } else {
        print('Failed to post suggestion. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error posting suggestion: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suggestions'),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/user.png', // Path to your background image
              fit: BoxFit.cover,
              color: const Color.fromARGB(255, 255, 255, 255)
                  .withOpacity(0.5), // Apply opacity to background
              colorBlendMode: BlendMode.lighten,
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _suggestions[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 16.0),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              suggestion['title'] ?? 'No Title',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800], // Title color
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'By ${suggestion['username'] ?? 'Unknown'} on ${DateFormat.yMMMd().format(DateTime.parse(suggestion['created_at'] ?? DateTime.now().toIso8601String()))}',
                              style: TextStyle(
                                color: Colors.grey[600], // Date line color
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              suggestion['content'] ?? 'No Content',
                              style: TextStyle(
                                color: Colors.grey[800], // Content color
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              suggestion['response'] == null ||
                                      suggestion['response'].isEmpty
                                  ? 'Waiting for Admin response'
                                  : 'Admin : ${suggestion['response']}',
                              style: TextStyle(
                                color: suggestion['response'] == null ||
                                        suggestion['response'].isEmpty
                                    ? Colors.red
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.8), // White background with opacity
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      TextField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          labelText: 'Content',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _postSuggestion,
                        child: Text('Post Suggestion'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.teal, // Button background color
                          foregroundColor: Colors.white, // Button text color
                          padding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
