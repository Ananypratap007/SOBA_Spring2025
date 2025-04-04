import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soba_app/shared/widgets/emergency_contacts_list.dart';
import 'package:soba_app/shared/widgets/custom_form_fields.dart';
import 'package:soba_app/shared/widgets/add_emergecy_contacts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _orgData;
  Map<String, dynamic>? _userData;
  final Duration _checkInDuration = const Duration(minutes: 10);
  bool _wellnessCheckEnabled = false;
  bool _isLoading = true;
  bool _needsRefresh = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Load user data
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        _userData = userDoc.data()!;
        _wellnessCheckEnabled = _userData?['wellnessChecksEnabled'] ?? false;
      }

      // Load organization data
      final orgId = userDoc.data()?['organizationId'];
      if (orgId != null) {
        final orgDoc =
            await _firestore.collection('organizations').doc(orgId).get();
        if (orgDoc.exists) {
          _orgData = orgDoc.data();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _needsRefresh = false;
        });
      }
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }

  void _navigateToCheckIn(BuildContext context) {
    context.push('/check-in-settings');
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('User not logged in')));
    }

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _needsRefresh = true);
          await _loadInitialData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 60),
              _buildProfileHeader(),
              _buildAccountSection(),
              _buildPersonalInfoSection(),
              if (_orgData != null) _buildOrganizationSection(),
              _buildSettingsSection(),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(String field, String currentValue, String label) async {
    final controller = TextEditingController(text: currentValue);
    final isNumberField = field == 'age' || field == 'weight';

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
            hintText: isNumberField ? 'Numbers only' : '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
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

      if (parsedValue == null) throw FormatException('Invalid input');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({field: parsedValue});

      // Update local data immediately for better UX
      setState(() {
        _userData = {...?_userData, field: parsedValue};
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$field updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  // Modified builder methods to use local _userData instead of parameters
  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 70,
          backgroundColor: const Color(0xFF003366),
          child: CircleAvatar(
            radius: 67,
            backgroundImage: NetworkImage(
              _userData?['photoUrl'] ?? 'https://via.placeholder.com/150',
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _userData?['name'] ?? 'No Name',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF003366),
          ),
        ),
        Text(
          _userData?['orgName'] ?? 'No Organization',
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF4CAF93),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return SectionWidget(
      title: 'Account Information',
      children: [
        InfoTile(label: 'Full Name', value: _userData?['name']),
        InfoTile(label: 'Username', value: _userData?['username']),
        InfoTile(label: 'Email', value: _userData?['email']),
        InfoTile(label: 'Phone', value: _userData?['phone']),
        InfoTile(label: 'Organization', value: _userData?['orgName']),
        InfoTile(label: 'Role', value: _userData?['role']),
        InfoTile(
          label: 'Password',
          value: '•••••••',
          hasArrow: true,
          onTap: () => context.push('/change-password'),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection() {
    return SectionWidget(
      title: 'Personal Information',
      children: [
        _buildEditableTile('race', 'Race', toTitleCase(_userData?['race'])),
        _buildEditableTile('gender', 'Gender', _userData?['gender']),
        _buildEditableTile('eyeColor', 'Eye Color', _userData?['eyeColor']),
        _buildEditableTile('hairColor', 'Hair Color', _userData?['hairColor']),
        _buildEditableTile('height', 'Height', _userData?['height']),
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
        _buildEditableTile('age', 'Age', _userData?['age']),
      ],
    );
  }

  Widget _buildEditableTile(String field, String label, dynamic value) {
    return InfoTile(
      label: label,
      value: value?.toString() ?? 'Not provided',
      hasArrow: true,
      onTap: () => _showEditDialog(
        field,
        value?.toString() ?? '',
        label,
      ),
    );
  }

  Widget _buildOrganizationSection() {
    final contactCount = _userData?['emergencyContacts']?.length ?? 0;
    return SectionWidget(
      title: 'Organization',
      children: [
        InfoTile(label: 'Name', value: _orgData?['name']),
        InfoTile(label: 'ID', value: _orgData?['orgId']),
        InfoTile(
          label: 'Check-In Interval',
          value: 'Every ${_formatDuration(_checkInDuration)}',
        ),
        InfoTile(
          label: 'Emergency Contacts',
          value: '$contactCount ${contactCount == 1 ? 'contact' : 'contacts'}',
          hasArrow: true,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EmergencyContactsScreen(),
              ),
            );
            // Refresh after returning from contacts screen
            if (mounted) {
              setState(() => _isLoading = true);
              await _loadInitialData();
            }
          },
        ),
        InfoTile(
          label: 'Wellness Checks',
          value: _wellnessCheckEnabled ? 'Enabled' : 'Disabled',
          trailing: Switch(
            value: _wellnessCheckEnabled,
            onChanged: (value) async {
              final user = _auth.currentUser;
              if (user != null) {
                await _firestore.collection('users').doc(user.uid).update({
                  'wellnessChecksEnabled': value,
                });
              }
              setState(() => _wellnessCheckEnabled = value);
            },
          ),
        )
      ],
    );
  }

  Widget _buildSettingsSection() {
    return SectionWidget(
      title: 'Settings',
      children: [
        InfoTile(
          label: 'Notifications',
          value: '',
          hasArrow: true,
          onTap: () => context.push('/notifications'),
        ),
        InfoTile(
          label: 'Privacy',
          value: '',
          hasArrow: true,
          onTap: () => context.push('/privacy'),
        ),
        InfoTile(
          label: 'Theme',
          value: 'System Default',
          hasArrow: true,
          onTap: () => context.push('/theme-settings'),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () async {
          await _auth.signOut();
          if (mounted) context.go('/login');
        },
        child: const Text(
          'Logout',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           SizedBox(
//             height: 40,
//           ),
//           // Top Profile Header
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(
//               vertical: 24.0,
//               horizontal: 16.0,
//             ),
//             child: Column(
//               children: [
//                 CircleAvatar(
//                   radius: 65,
//                   backgroundColor: Color(0xFF003366),
//                   child: CircleAvatar(
//                     radius: 62.5,
//                     backgroundColor: Colors.white,
//                     child: Icon(
//                       Icons.person,
//                       size: 40,
//                       color: const Color(0xFF003366),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   'Ananya Gupta',
//                   style: TextStyle(
//                     fontSize: 30,
//                     color: Color(0xFF003366),
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 3),
//                 const Text(
//                   'Nurse',
//                   style: TextStyle(
//                     color: Color(0XFF4CAF93),
//                     fontSize: 22,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           Expanded(
//             child: SafeArea(
//               // Wrap only the scrollable content in SafeArea
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     // Personal Information Card (Expandable)
//                     _buildInfoContainer(
//                       icon: Icons.person,
//                       title: 'Personal Information',
//                       details: [
//                         _DetailItem(label: 'Full Name', value: 'Ananya Gupta'),
//                         _DetailItem(
//                             label: 'Affiliated Organization',
//                             value: 'Red Cross'),
//                         // ... rest of your items
//                       ],
//                     ),

//                     // Vehicle Information Card for Vehicle 1 (Expandable)
//                     _buildExpandableInfoCard(
//                       icon: Icons.directions_car,
//                       title: 'Vehicle 1',
//                       details: [
//                         _DetailItem(label: 'Make', value: 'Toyota'),
//                         _DetailItem(label: 'Model', value: 'Camry'),
//                         _DetailItem(label: 'License Plate', value: 'ABC 123'),
//                       ],
//                     ),

//                     // Vehicle Information Card for Vehicle 2 (Expandable)
//                     _buildExpandableInfoCard(
//                       icon: Icons.directions_car,
//                       title: 'Vehicle 2',
//                       details: [
//                         _DetailItem(label: 'Make', value: 'Honda'),
//                         _DetailItem(label: 'Model', value: 'Civic'),
//                         _DetailItem(label: 'License Plate', value: '972 XBT'),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           // Logout Button at the very bottom
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Card(
//               color: Colors.red,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               elevation: 2,
//               child: InkWell(
//                 onTap: () async {
//                   try {
//                     await FirebaseConfig.auth.signOut();
//                     if (mounted) {
//                       context.go('/login');
//                     }
//                   } catch (e) {
//                     if (mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                             content:
//                                 Text('Error signing out: ${e.toString()}')),
//                       );
//                     }
//                   }
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Center(
//                     child: Text(
//                       'Logout',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Builds a Card with an ExpansionTile that displays an icon, title,
//   /// and an expandable list of details.
//   Widget _buildExpandableInfoCard({
//     required IconData icon,
//     required String title,
//     required List<_DetailItem> details,
//   }) {
//     return Card(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8),
//       ),
//       elevation: 0, // Remove default elevation
//       color: const Color.fromARGB(255, 10, 74, 139), // Updated card color
//       child: Container(
//         decoration: BoxDecoration(
//           color: const Color.fromARGB(255, 10, 74, 139), // Match card color
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2), // Shadow color
//               blurRadius: 6, // Blur radius
//               offset: const Offset(0, 4), // Offset for shadow
//             ),
//           ],
//         ),
//         child: ExpansionTile(
//           tilePadding: const EdgeInsets.all(16),
//           iconColor: Colors.white, // Set arrow icon color when expanded
//           collapsedIconColor:
//               Colors.white, // Set arrow icon color when collapsed
//           title: Row(
//             children: [
//               CircleAvatar(
//                 backgroundColor: Colors.white,
//                 child: Icon(icon, color: const Color(0xFF003366)), // Icon color
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   color: Colors.white, // Set text color to white
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           children: details.map((detail) {
//             if (detail.isSubheading) {
//               return Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16.0,
//                   vertical: 4.0,
//                 ),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(
//                       width: 140,
//                       child: Text(
//                         detail.label,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors
//                               .white, // Set subheading text color to white
//                         ),
//                       ),
//                     ),
//                     const SizedBox(),
//                   ],
//                 ),
//               );
//             } else {
//               return Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16.0,
//                   vertical: 4.0,
//                 ),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(
//                       width: 140,
//                       child: Text(
//                         '${detail.label}:',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white, // Set label text color to white
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: Text(
//                         detail.value,
//                         style: const TextStyle(
//                           color: Colors.white, // Set value text color to white
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }
//           }).toList(),
//         ),
//       ),
//     );
//   }
// }

// /// Simple class to hold label/value pairs for the detail rows.
// /// You can also mark an item as a subheading if you want to style it differently.
// class _DetailItem {
//   final String label;
//   final String value;
//   final bool isSubheading;

//   _DetailItem({
//     required this.label,
//     required this.value,
//     this.isSubheading = false,
//   });

//   /// Named constructor to create a "subheading" item (e.g., "Biological Info")
//   _DetailItem.subheading(String heading)
//       : label = heading,
//         value = '',
//         isSubheading = true;
// }

// // Template for Personal Information

// Widget _buildInfoContainer({
//   required IconData icon,
//   required String title,
//   required List<_DetailItem> details,
// }) {
//   return Container(
//     decoration: BoxDecoration(
//       color: const Color.fromARGB(255, 10, 74, 139),
//       borderRadius: BorderRadius.circular(8),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.2),
//           blurRadius: 6,
//           offset: const Offset(0, 4),
//         ),
//       ],
//     ),
//     child: Column(
//       children: [
//         // Header section
//         Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               CircleAvatar(
//                 backgroundColor: Colors.white,
//                 child: Icon(icon, color: const Color(0xFF003366)),
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // Details section
//         Padding(
//           padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
//           child: Column(
//             children: details.map((detail) {
//               if (detail.isSubheading) {
//                 return Padding(
//                   padding: const EdgeInsets.only(top: 8, bottom: 4),
//                   child: Text(
//                     detail.label,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 );
//               } else {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 4),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(
//                         width: 200, // Fixed width for labels
//                         child: Text(
//                           '${detail.label}:',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                           overflow: TextOverflow.ellipsis, // Prevent wrapping
//                         ),
//                       ),
//                       const SizedBox(width: 8), // Space between label and value
//                       Expanded(
//                         child: Text(
//                           detail.value,
//                           style: const TextStyle(
//                             color: Colors.white,
//                           ),
//                           overflow: TextOverflow.ellipsis, // Prevent wrapping
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }
//             }).toList(),
//           ),
//         ),
//       ],
//     ),
//   );
// }
