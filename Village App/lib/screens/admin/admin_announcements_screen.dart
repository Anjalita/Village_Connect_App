import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AdminAnnouncementPage extends StatefulWidget {
  @override
  _AdminAnnouncementPageState createState() => _AdminAnnouncementPageState();
}

class _AdminAnnouncementPageState extends State<AdminAnnouncementPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _message = '';
  List<Map<String, dynamic>> _announcements = [];
  int? _currentAnnouncementId; // Track the current announcement being updated

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.5.1:3000/announcements'), // Replace with your IP address
      );

      if (response.statusCode == 200) {
        setState(() {
          _announcements =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        setState(() {
          _message = 'Failed to load announcements';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'An error occurred. Please try again later.';
      });
    }
  }

  Future<void> _createAnnouncement() async {
    final title = _titleController.text;
    final content = _contentController.text;

    try {
      final response = await http.post(
        Uri.parse(
            'http://192.168.5.1:3000/createAnnouncement'), // Replace with your IP address
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'title': title,
          'content': content,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _message = 'Announcement created successfully';
          _fetchAnnouncements(); // Refresh the announcements list
          _titleController.clear();
          _contentController.clear();
        });
      } else {
        setState(() {
          _message = 'Failed to create announcement';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'An error occurred. Please try again later.';
      });
    }
  }

  Future<void> _deleteAnnouncement(int id) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'http://192.168.5.1:3000/deleteAnnouncement/$id'), // Replace with your IP address
      );

      if (response.statusCode == 200) {
        setState(() {
          _message = 'Announcement deleted successfully';
          _fetchAnnouncements(); // Refresh the announcements list
        });
      } else {
        setState(() {
          _message = 'Failed to delete announcement';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'An error occurred. Please try again later.';
      });
    }
  }

  Future<void> _updateAnnouncement(int id, String title, String content) async {
    try {
      final response = await http.put(
        Uri.parse(
            'http://192.168.5.1:3000/updateAnnouncement/$id'), // Replace with your IP address
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'title': title,
          'content': content,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _message = 'Announcement updated successfully';
          _fetchAnnouncements(); // Refresh the announcements list
          _currentAnnouncementId =
              null; // Clear the current announcement being updated
          _titleController.clear();
          _contentController.clear();
        });
      } else {
        setState(() {
          _message = 'Failed to update announcement';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'An error occurred. Please try again later.';
      });
    }
  }

  void _showUpdateDialog(int id, String currentTitle, String currentContent) {
    _titleController.text = currentTitle;
    _contentController.text = currentContent;
    _currentAnnouncementId = id;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Announcement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _currentAnnouncementId =
                  null; // Clear the current announcement being updated
              // Clear the text fields when cancel is pressed
              _titleController.clear();
              _contentController.clear();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_currentAnnouncementId != null) {
                _updateAnnouncement(_currentAnnouncementId!,
                    _titleController.text, _contentController.text);
              }
              Navigator.pop(context);
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      final DateFormat formatter = DateFormat('dd-MM-yy');
      return formatter.format(dateTime);
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allow body to extend behind AppBar
      appBar: AppBar(
        title: Text('Announcements'),
        backgroundColor: Colors.teal, // Set AppBar color
        elevation: 0, // Remove shadow
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Announcements list
                Expanded(
                  child: ListView.builder(
                    itemCount: _announcements.length,
                    shrinkWrap:
                        true, // Ensure it takes up only the space it needs
                    physics: BouncingScrollPhysics(), // Enable bounce effect
                    itemBuilder: (context, index) {
                      final announcement = _announcements[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.5)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(announcement['title']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(announcement['content'],
                                  textAlign: TextAlign.justify),
                              SizedBox(height: 4),
                              Text(
                                'Created at: ${_formatDate(announcement['created_at'])}', // Only date
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _deleteAnnouncement(announcement['id']),
                          ),
                          onTap: () => _showUpdateDialog(
                            announcement['id'],
                            announcement['title'],
                            announcement['content'],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                // New announcement section
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6.0,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          labelText: 'Content',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 5,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _createAnnouncement,
                        child: Text('Create Announcement'),
                      ),
                      if (_message.isNotEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _message,
                              style:
                                  TextStyle(color: Colors.green, fontSize: 16),
                            ),
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
