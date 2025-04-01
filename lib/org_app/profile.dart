/// The above code defines a Flutter application that displays a user profile screen with account
/// information, organization settings, privacy & security options, and allows for interactions like
/// updating check-in duration and enabling wellness check-up.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Profile'),
      centerTitle: true,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go('/'),
      ),
    );
  }

  Duration _checkInDuration = const Duration(minutes: 10);
  bool _wellnessCheckEnabled = false;
  List<Map<String, String>> _emergencyContacts =
      []; // List to hold the emergency contacts

  String _formatDuration(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes % 60;

    if (hours == 0) {
      return '$minutes minute${minutes == 1 ? '' : 's'}';
    } else if (minutes == 0) {
      return '$hours hour${hours == 1 ? '' : 's'}';
    } else {
      return '$hours hour${hours == 1 ? '' : 's'} and $minutes minute${minutes == 1 ? '' : 's'}';
    }
  }

  void _navigateToCheckIn(BuildContext context) async {
    final updatedDuration = await context.push<Duration>(
      '/check-in',
      extra: _checkInDuration,
    );
    if (updatedDuration != null) {
      setState(() => _checkInDuration = updatedDuration);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use a SingleChildScrollView if the content might overflow
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 245, 245, 245),
      appBar: _buildAppBar(),
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
                      padding: const EdgeInsets.all(12.0), // Optional padding
                      child: Column(
                        children: [
                          _InfoTile(
                            label: 'Check-In',
                            value: 'Every ${_formatDuration(_checkInDuration)}',
                            hasArrow: true,
                            onTap: () => _navigateToCheckIn(context),
                          ),
                          _InfoTile(
                            label: 'Emergency Contact',
                            value: Hive.box('emergencyContacts').isNotEmpty
                                ? Hive.box('emergencyContacts')
                                    .values
                                    .map<String>((e) => e['name'] as String)
                                    .join(', ')
                                : 'None Added',
                            hasArrow: true,
                            onTap: () async {
                              final contact =
                                  await context.push<Map<String, String>>(
                                      '/emergency-contacts');
                              if (contact != null) {
                                setState(() => _emergencyContacts.add(contact));
                              }
                            },
                          ),
                          _InfoTile(
                            label: 'Wellness Check-Up',
                            value: '',
                            trailing: Transform.scale(
                                scale: 0.65,
                                child: Switch(
                                    value: _wellnessCheckEnabled,
                                    activeColor: Colors.green,
                                    onChanged: (bool value) {
                                      setState(() {
                                        _wellnessCheckEnabled = value;
                                      });
                                    })),
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

            const SizedBox(height: 4),
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
  final VoidCallback? onTap;
  final Widget? trailing;

  const _InfoTile({
    Key? key,
    required this.label,
    required this.value,
    this.hasArrow = false,
    this.onTap,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: value.isNotEmpty ? Text(value) : null,
      trailing: trailing ??
          (hasArrow ? const Icon(Icons.arrow_forward_ios, size: 16) : null),
      dense: true,
      onTap: onTap,
    );
  }
}
