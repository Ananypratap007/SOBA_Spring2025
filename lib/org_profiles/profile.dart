import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use a SingleChildScrollView if the content might overflow
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 245, 245, 245),
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section (User Avatar & Basic Info)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Profile Image
                  CircleAvatar(
                    radius: 65,
                    backgroundColor: Color(0xFFFF6F61),
                    child: CircleAvatar(
                      radius: 62,
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Greeting and name
                  const Text(
                    'Hello, Alexander',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Experience
                  const SizedBox(height: 8),
                  Text(
                    'Regional Administrator',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),

            // Account Information
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: const Text(
                      'Account Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      color: Colors.white, // Background color
                      padding: const EdgeInsets.all(16.0), // Optional padding
                      child: Column(
                        children: const [
                          _InfoTile(
                            label: 'Full Name',
                            value: 'Alexander Washington',
                          ),
                          _InfoTile(
                            label: 'Username',
                            value: 'walex01',
                          ),
                          _InfoTile(
                            label: 'Email',
                            value: 'alexwashington@red-cross.com',
                          ),
                          _InfoTile(
                            label: 'Phone Number',
                            value: '+1 323 456 7890',
                          ),
                          _InfoTile(
                            label: 'Affiliated Organization',
                            value: 'Red Cross USA',
                          ),
                          _InfoTile(
                            label: 'Password Management',
                            value: '******',
                            hasArrow: true,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),

            // Organization Settings
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: const Text(
                      'Organization Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      color: Colors.white, // Background color
                      padding: const EdgeInsets.all(16.0), // Optional padding
                      child: Column(
                        children: const [
                          _InfoTile(
                            label: 'Check-In',
                            value: 'Every 10 minutes',
                            hasArrow: true,
                          ),
                          _InfoTile(
                            label: 'Emergency Contact',
                            value: 'Jeremy Westin',
                            hasArrow: true,
                          ),
                          _InfoTile(
                            label: 'Wellness Check-Up',
                            value: 'Deactivate',
                            hasArrow: true,
                          ),
                          _InfoTile(
                            label: 'Theme & Appearance',
                            value: '',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Privacy & Security
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: const Text(
                      'Privacy & Security',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      color: Colors.white, // Background color
                      padding: const EdgeInsets.all(16.0), // Optional padding
                      child: Column(
                        children: const [
                          _InfoTile(
                            label: 'Privacy Settings',
                            value: '',
                            hasArrow: true,
                          ),
                          _InfoTile(
                            label: 'Two-Factor Authentication',
                            value: '',
                          ),
                          _InfoTile(
                            label: 'Managed Connected Accounts',
                            value: '',
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// A simple reusable ListTile widget for displaying info
class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final bool hasArrow;

  const _InfoTile({
    Key? key,
    required this.label,
    required this.value,
    this.hasArrow = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: value.isNotEmpty ? Text(value) : null,
      trailing: hasArrow ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      dense: true,
    );
  }
}
