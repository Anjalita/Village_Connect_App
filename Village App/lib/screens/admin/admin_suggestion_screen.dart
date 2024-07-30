import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting date
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminSuggestionsScreen extends StatefulWidget {
  @override
  _AdminSuggestionsScreenState createState() => _AdminSuggestionsScreenState();
}

class _AdminSuggestionsScreenState extends State<AdminSuggestionsScreen> {
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
        print('Failed to load suggestions');
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
    }
  }

  Future<void> _postResponse(
      Map<String, dynamic> suggestion, String responseText) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://192.168.5.1:3000/respondSuggestion'), // Replace with your API URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id': suggestion['id'],
          'response': responseText,
        }),
      );

      if (response.statusCode == 200) {
        _fetchSuggestions(); // Refresh the suggestions after posting a response
      } else {
        print('Failed to post response');
      }
    } catch (e) {
      print('Error posting response: $e');
    }
  }

  void _showResponseDialog(Map<String, dynamic> suggestion) {
    final TextEditingController _responseController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Respond to Suggestion'),
          content: TextField(
            controller: _responseController,
            decoration: InputDecoration(labelText: 'Response'),
            maxLines: 4,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () {
                final responseText = _responseController.text;
                if (responseText.isNotEmpty) {
                  _postResponse(suggestion, responseText);
                }
                Navigator.of(context).pop();
              },
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
        title: Text('Admin Suggestions'),
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false, // Remove the back arrow button
      ),
      body: Stack(
        children: [
          // Background image with opacity
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/images/admin.png', // Update path if needed
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16.0),
                  child: ListTile(
                    title: Text(
                      suggestion['title'] ?? 'No Title',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'By ${suggestion['username'] ?? 'Unknown'} on ${DateFormat.yMMMd().format(DateTime.parse(suggestion['created_at'] ?? DateTime.now().toIso8601String()))}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          suggestion['content'] ?? 'No Content',
                          textAlign: TextAlign.justify, // Justify the text
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          suggestion['response'] == null ||
                                  suggestion['response'].isEmpty
                              ? 'Waiting for admin response'
                              : 'Admin : ${suggestion['response']}',
                          textAlign: TextAlign.justify, // Justify the text
                          style: TextStyle(
                            color: suggestion['response'] == null ||
                                    suggestion['response'].isEmpty
                                ? Colors.red
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _showResponseDialog(suggestion),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
