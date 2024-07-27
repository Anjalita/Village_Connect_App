import 'package:flutter/material.dart';

class VillageInfoScreen extends StatelessWidget {
  final List<Map<String, String>> villageInfo = [
    {'name': 'President', 'phone': '1234567890'},
    {'name': 'Secretary', 'phone': '0987654321'},
    {'name': 'Treasurer', 'phone': '1112233445'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Village Info')),
      body: ListView.builder(
        itemCount: villageInfo.length,
        itemBuilder: (context, index) {
          final info = villageInfo[index];
          return ListTile(
            title: Text(info['name'] ?? 'No Name'),
            subtitle: Text(info['phone'] ?? 'No Phone Number'),
          );
        },
      ),
    );
  }
}
