import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:soba_app/config/firebase_config.dart';
import 'package:soba_app/shared/widgets/custom_form_fields.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _orgData;
  bool _isLoading = true;
  Duration _checkInDuration = const Duration(minutes: 10);
  bool _wellnessCheckEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() => _userData = userDoc.data());

          if (_userData?['organizationId'] != null) {
            final orgQuery = await _firestore
                .collection('organizations')
                .doc(_userData!['organizationId'])
                .get();

            if (orgQuery.exists) {
              setState(() => _orgData = orgQuery.data());
            }
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showEditDialog(String field, String currentValue, String label) async {
    final TextEditingController controller =
        TextEditingController(text: currentValue == 'N/A' ? '' : currentValue);
    bool isNumberField = field == 'age' || field == 'weight';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $label'),
        content: TextFormField(
          controller: controller,
          keyboardType:
              isNumberField ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            labelText: label,
            hintText: isNumberField ? 'Enter numbers only' : '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newValue = controller.text.trim();
              if (newValue.isNotEmpty) {
                await _updateUserField(field, newValue);
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUserField(String field, String value) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      dynamic parsedValue;
      if (field == 'age') {
        parsedValue = int.tryParse(value);
      } else if (field == 'weight') {
        parsedValue = double.tryParse(value);
      } else {
        parsedValue = value;
      }

      if (parsedValue == null) {
        throw FormatException('Invalid input for $field');
      }

      await _firestore.collection('users').doc(user.uid).update({
        field: parsedValue,
      });

      setState(() => _userData?[field] = parsedValue);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$field updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating $field: ${e.toString()}')),
        );
      }
    }
  }

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

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return hours > 0
        ? '$hours hour${hours == 1 ? '' : 's'} ${minutes > 0 ? 'and $minutes minute${minutes == 1 ? '' : 's'}' : ''}'
        : '$minutes minute${minutes == 1 ? '' : 's'}';
  }

  void _navigateToCheckIn(BuildContext context) async {
    final updatedDuration = await context.push<Duration>(
      '/check-in',
      extra: _checkInDuration,
    );
    if (updatedDuration != null && mounted) {
      setState(() => _checkInDuration = updatedDuration);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_userData == null) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: Text('No user data found')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 65,
                    backgroundColor: const Color(0xFFFF6F61),
                    child: CircleAvatar(
                      radius: 62,
                      backgroundImage: NetworkImage(
                        _userData?['photoUrl'] ??
                            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    toTitleCase(_userData?['name']) ?? 'User',
                    style: TextStyle(
                      fontSize: 24,
                      color: Color(0xFF003366),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    toTitleCase(_userData?['role']) ?? 'MEMBER',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0XFF4CAF93),
                    ),
                  ),
                ],
              ),
            ),

            // Account Information
            SectionWidget(
              title: 'Account Information',
              children: [
                SectionWidget.buildInfoTile(
                    'Full Name', toTitleCase(_userData?['name'])),
                SectionWidget.buildInfoTile('Username', _userData?['username']),
                SectionWidget.buildInfoTile('Email', _userData?['email']),
                SectionWidget.buildInfoTile('Phone', _userData?['phone']),
                const InfoTile(
                  label: 'Password',
                  value: '••••••',
                  hasArrow: true,
                ),
              ],
            ),

            // Personal Information Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          InfoTile(
                            label: 'Race',
                            value: _userData?['race'] ?? 'N/A',
                            hasArrow: true,
                            onTap: () => _showEditDialog(
                              'race',
                              _userData?['race']?.toString().toUpperCase() ??
                                  '',
                              'Race',
                            ),
                          ),
                          InfoTile(
                            label: 'Gender',
                            value: _userData?['gender'] ?? 'N/A',
                            hasArrow: true,
                            onTap: () => _showEditDialog(
                              'gender',
                              _userData?['gender']
                                      ?.toString()
                                      .toUpperCase()
                                      .toUpperCase() ??
                                  '',
                              'Gender',
                            ),
                          ),
                          InfoTile(
                            label: 'Eye color',
                            value: _userData?['eyeColor'] ?? 'N/A',
                            hasArrow: true,
                            onTap: () => _showEditDialog(
                              'eyeColor',
                              _userData?['eyeColor']
                                      ?.toString()
                                      .toUpperCase() ??
                                  '',
                              'Eye Color',
                            ),
                          ),
                          InfoTile(
                            label: 'Hair color',
                            value: _userData?['hairColor'] ?? 'N/A',
                            hasArrow: true,
                            onTap: () => _showEditDialog(
                              'hairColor',
                              _userData?['hairColor']
                                      ?.toString()
                                      .toUpperCase() ??
                                  '',
                              'Hair Color',
                            ),
                          ),
                          InfoTile(
                            label: 'Height',
                            value: _userData?['height'] ?? 'N/A',
                            hasArrow: true,
                            onTap: () => _showEditDialog(
                              'height',
                              _userData?['height']?.toString() ?? '',
                              'Height',
                            ),
                          ),
                          InfoTile(
                            label: 'Weight',
                            value: _userData?['weight'] != null
                                ? '${_userData?['weight']} lb'
                                : 'N/A',
                            hasArrow: true,
                            onTap: () => _showEditDialog(
                              'weight',
                              _userData?['weight']?.toString() ?? '',
                              'Weight',
                            ),
                          ),
                          InfoTile(
                            label: 'Age',
                            value: _userData?['age']?.toString() ?? 'N/A',
                            hasArrow: true,
                            onTap: () => _showEditDialog(
                              'age',
                              _userData?['age']?.toString() ?? '',
                              'Age',
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Organization Section
            if (_orgData != null) ...[
              SectionWidget(
                title: 'Organization',
                children: [
                  SectionWidget.buildInfoTile(
                      'Name', _orgData?['name'].toString().toUpperCase()),
                  SectionWidget.buildInfoTile(
                      'ID', _orgData?['orgId'].toString().toUpperCase()),
                  InfoTile(
                    label: 'Check-In Interval',
                    value: 'Every ${_formatDuration(_checkInDuration)}',
                    hasArrow: true,
                    onTap: () => _navigateToCheckIn(context),
                  ),
                  InfoTile(
                    label: 'Emergency Contacts',
                    value: 'View List',
                    hasArrow: true,
                    onTap: () => context.push('/emergency-contacts'),
                  ),
                  InfoTile(
                    label: 'Wellness Checks',
                    value: _wellnessCheckEnabled ? 'Enabled' : 'Disabled',
                    trailing: Switch(
                      value: _wellnessCheckEnabled,
                      onChanged: (value) =>
                          setState(() => _wellnessCheckEnabled = value),
                    ),
                  ),
                ],
              ),
            ],

            // Settings Section
            SectionWidget(
              title: 'Settings',
              children: [
                const InfoTile(
                  label: 'Notifications',
                  value: '',
                  hasArrow: true,
                ),
                const InfoTile(
                  label: 'Privacy',
                  value: '',
                  hasArrow: true,
                ),
                InfoTile(
                  label: 'Theme',
                  value: 'System Default',
                  hasArrow: true,
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  minimumSize: const Size(250, 25),
                ),
                onPressed: () async {
                  try {
                    await FirebaseConfig.auth.signOut();
                    if (mounted) {
                      context.go('/login');
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error signing out: ${e.toString()}'),
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
