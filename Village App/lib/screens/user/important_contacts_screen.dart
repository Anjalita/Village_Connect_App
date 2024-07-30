import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // For making phone calls
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImportantContactsScreen extends StatefulWidget {
  @override
  _ImportantContactsScreenState createState() =>
      _ImportantContactsScreenState();
}

class _ImportantContactsScreenState extends State<ImportantContactsScreen> {
  final List<Map<String, dynamic>> contacts = [
    {
      'name': 'Ambulance',
      'phone': '108', // Replace with actual number
      'icon': Icons.local_hospital,
    },
    {
      'name': 'Fire Station',
      'phone': '101', // Replace with actual number
      'icon': Icons.local_fire_department,
    },
    {
      'name': 'Police',
      'phone': '100', // Replace with actual number
      'icon': Icons.local_police,
    },
  ];

  List<Map<String, dynamic>> adminContacts = [];

  @override
  void initState() {
    super.initState();
    _fetchAdminContacts();
  }

  Future<void> _fetchAdminContacts() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.5.1:3000/admins'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          adminContacts =
              data.map((dynamic item) => item as Map<String, dynamic>).toList();
        });
      } else {
        print(
            'Failed to load admin contacts. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching admin contacts: $e');
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Important Contacts'),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/user.png',
              fit: BoxFit.cover,
              color: const Color.fromARGB(255, 255, 255, 255)
                  .withOpacity(0.5), // Optional opacity
              colorBlendMode: BlendMode.lighten,
            ),
          ),
          // Main Content
          ListView(
            children: [
              // Emergency Contacts
              ...contacts.map((contact) {
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: Container(
                    height: 80, // Increase the height as needed
                    child: Center(
                      child: ListTile(
                        leading:
                            Icon(contact['icon'], color: Colors.teal, size: 40),
                        title: Text(contact['name']),
                        onTap: () => _makePhoneCall(contact['phone']),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                    ),
                  ),
                );
              }).toList(),

              // Admin Contacts
              if (adminContacts.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Admin Contacts',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ...adminContacts.map((admin) {
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: Container(
                      height: 80, // Increase the height as needed
                      child: Center(
                        child: ListTile(
                          leading: Icon(Icons.person,
                              color: Colors.teal, size: 40), // Random icon
                          title: Text(admin['name']),
                          subtitle: Text(admin['job_title'] ?? 'No Job Title'),
                          onTap: () => _makePhoneCall(admin['phone']),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16.0),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
