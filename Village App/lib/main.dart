import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// Import your screens
import 'screens/login_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/user/user_home_screen.dart';
import 'screens/admin/admin_announcements_screen.dart';
import 'screens/user/user_profile.dart';
import 'screens/admin/admin_enquiry_screen.dart';
import 'screens/admin/admin_suggestion_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(VillageApp());
}

class VillageApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Village Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/admin_home': (context) {
          final username =
              ModalRoute.of(context)!.settings.arguments as String?;
          return AdminHomeScreen(username: username ?? '');
        },
        '/user_home': (context) {
          final username =
              ModalRoute.of(context)!.settings.arguments as String?;
          return UserHomeScreen(username: username ?? '');
        },
        '/announcements': (context) =>
            AdminAnnouncementPage(), // Add route for announcements
        '/profile': (context) {
          final username =
              ModalRoute.of(context)!.settings.arguments as String?;
          return UserProfilePage(username: username ?? '');
        },
        '/admin-enquiries': (context) =>
            AdminEnquiryScreen(), // Add route for admin enquiries
        '/admin-suggestions': (context) =>
            AdminSuggestionsScreen(), // Add route for admin suggestions
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => LoginScreen());
      },
    );
  }
}

// Function to write data to a file
Future<void> writeData(String filename, String data) async {
  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path;
  final file = File('$path/$filename');
  await file.writeAsString(data);
}

// Function to read data from a file
Future<String> readData(String filename) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/$filename');
    String data = await file.readAsString();
    return data;
  } catch (e) {
    return 'Error reading data: $e';
  }
}
