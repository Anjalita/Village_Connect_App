import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AdminEnquiryScreen extends StatefulWidget {
  @override
  _AdminEnquiryScreenState createState() => _AdminEnquiryScreenState();
}

class _AdminEnquiryScreenState extends State<AdminEnquiryScreen> {
  List<Map<String, dynamic>> _queries = [];
  final TextEditingController _responseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchQueries();
  }

  Future<void> _fetchQueries() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.5.1:3000/admin/queries'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _queries =
              data.map((dynamic item) => item as Map<String, dynamic>).toList();
        });
      } else {
        print('Failed to load queries. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching queries: $e');
    }
  }

  Future<void> _respondToQuery(int id) async {
    final responseText = _responseController.text;

    try {
      final res = await http.put(
        Uri.parse('http://192.168.5.1:3000/admin/respondQuery/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'response': responseText,
        }),
      );

      if (res.statusCode == 200) {
        _responseController.clear();
        setState(() {
          final index = _queries.indexWhere((query) => query['id'] == id);
          if (index != -1) {
            _queries[index]['response'] = responseText;
          }
        });
        Navigator.of(context).pop(); // Close the dialog after successful update
      } else {
        print('Failed to respond to query. Status code: ${res.statusCode}');
      }
    } catch (e) {
      print('Error responding to query: $e');
    }
  }

  void _showResponseDialog(int queryId, String currentResponse) {
    _responseController.text = currentResponse;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Respond to Query'),
          content: TextField(
            controller: _responseController,
            decoration: InputDecoration(
              labelText: 'Enter your response',
            ),
            maxLines: 4,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_responseController.text.isNotEmpty) {
                  _respondToQuery(queryId);
                }
              },
              child: Text('Submit Response'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
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
        title: Text('Admin Enquiries'),
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Background image with opacity
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/images/admin.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: _queries.length,
              itemBuilder: (context, index) {
                final query = _queries[index];
                final hasResponse =
                    query['response'] != null && query['response'].isNotEmpty;
                return GestureDetector(
                  onTap: () {
                    _showResponseDialog(query['id'], query['response'] ?? '');
                  },
                  child: Card(
                    margin: EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0), // Add padding here
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            query['matter'] ?? 'No Matter',
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'By ${query['username'] ?? 'Unknown'} on ${DateFormat.yMMMd().format(DateTime.parse(query['time'] ?? DateTime.now().toIso8601String()))}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            hasResponse
                                ? 'Admin: ${query['response']}'
                                : 'Response Awaiting',
                            style: TextStyle(
                              color: hasResponse ? Colors.black : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
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
