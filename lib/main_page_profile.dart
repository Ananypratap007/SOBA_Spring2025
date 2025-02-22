import 'package:flutter/material.dart';
import 'profile_info_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Pages for each tab
  final List<Widget> _pages = [
    const DashboardPage(), // Home tab
    const MapsPage(), // Settings (Was previously labeled "Map")
    ProfileInfoPage(
      name: "John Doe",
      email: "john.doe@example.com",
      phone: "+1234567890",
      personalDetails: const {
        "Full Name": "John Omari Doe",
        "Affiliated Organization": "ICCEW",
        "Occupation": "Software Engineer",
        "Location": "New York",
      },
      additionalDetails: const {
        "Number of Vehicles": "3",
        "Make": "Honda",
        "Model": "Civic",
        "License Plate": "972 XBT"
      },
      onEditProfile: () {
        print("Edit Profile Clicked");
      },
      onEditPersonal: () {
        // Corrected function name
        print("Edit Personal Details Clicked");
      },
      onEditAdditional: () {
        // Corrected function name
        print("Edit Additional Details Clicked");
      },
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFB076),
      appBar: AppBar(
        title: const Text('Your Profile', textAlign: TextAlign.center),
      ),
      body: _pages[_selectedIndex], // Change content based on tab

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue, // Highlight color
        unselectedItemColor: Colors.grey, // Default color
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map), // Changed from "map" to match SettingsPage
            label: "Map",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Dashboard Page"));
  }
}

class MapsPage extends StatelessWidget {
  const MapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Settings Page"));
  }
}
