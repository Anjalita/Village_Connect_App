import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class AnnouncementsScreen extends StatefulWidget {
  @override
  _AnnouncementsScreenState createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  late File _announcementsFile;
  List<Map<String, dynamic>> _announcements = [];

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    final directory = await getApplicationDocumentsDirectory();
    _announcementsFile = File('${directory.path}/announcements.json');
    if (await _announcementsFile.exists()) {
      final jsonString = await _announcementsFile.readAsString();
      setState(() {
        _announcements =
            List<Map<String, dynamic>>.from(json.decode(jsonString));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Announcements')),
      body: ListView.builder(
        itemCount: _announcements.length,
        itemBuilder: (context, index) {
          final announcement = _announcements[index];
          return ListTile(
            title: Text(announcement['title'] ?? 'No Title'),
            subtitle: Text(announcement['content'] ?? 'No Content'),
          );
        },
      ),
    );
  }
}
