import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // For making phone calls

class ImportantContactsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> contacts = [
    {
      'name': 'Ambulance',
      'phone': '102', // Replace with actual number
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
        title: Text('Emergency Contacts'),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: Container(
              height: 80, // Increase the height as needed
              child: Center(
                child: ListTile(
                  leading: Icon(contact['icon'], color: Colors.teal, size: 40),
                  title: Text(contact['name']),
                  onTap: () => _makePhoneCall(contact['phone']),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
