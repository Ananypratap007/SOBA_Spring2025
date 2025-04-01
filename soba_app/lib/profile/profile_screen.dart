import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soba_app/profile/profile_presenter.dart';
import 'package:soba_app/auth_state.dart';
import 'package:soba_app/firebase_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    Key? key,
    required this.presenter,
  }) : super(key: key);

  final ProfilePresenter presenter;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 245, 245, 245),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading profile data'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No user data found'));
          }

          Map<String, dynamic> userData =
              snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 50),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundColor: Color(0xFF003366),
                        child: CircleAvatar(
                          radius: 67,
                          backgroundImage: NetworkImage(
                            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        userData['name'] ?? 'No Name',
                        style: TextStyle(
                          fontSize: 24,
                          color: Color(0xFF003366),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userData['affiliatedOrg'] ?? 'No Organization',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0XFF4CAF93),
                        ),
                      ),
                      Text(
                        userData['role'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0XFF4CAF93),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Account Information',
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
                              _InfoTile(
                                label: 'Full Name',
                                value: userData['name'] ?? 'N/A',
                              ),
                              _InfoTile(
                                label: 'Username',
                                value: userData['username'] ?? 'N/A',
                              ),
                              _InfoTile(
                                label: 'Email',
                                value: userData['email'] ?? 'N/A',
                              ),
                              _InfoTile(
                                label: 'Phone Number',
                                value: userData['phone'] ?? 'N/A',
                              ),
                              _InfoTile(
                                label: 'Affiliated Organization',
                                value: userData['affiliatedOrg'] ?? 'N/A',
                              ),
                              _InfoTile(
                                label: 'Role/Title',
                                value: userData['role'] ?? 'N/A',
                              ),
                              _InfoTile(
                                label: 'Password Management',
                                value: '******',
                                hasArrow: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
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
                              _InfoTile(
                                label: 'Race',
                                value: userData['race'] ?? 'N/A',
                              ),
                              _InfoTile(
                                label: 'Gender',
                                value: userData['gender'] ?? 'N/A',
                              ),
                              _InfoTile(
                                label: 'Eye color',
                                value: userData['eyeColor'] ?? 'N/A',
                              ),
                              _InfoTile(
                                label: 'Hair color',
                                value: userData['hairColor'] ?? 'N/A',
                              ),
                              _InfoTile(
                                label: 'Height',
                                value: userData['height'] ?? 'N/A',
                              ),
                              _InfoTile(
                                label: 'Weight',
                                value: userData['weight'] != null
                                    ? '${userData['weight']} lb'
                                    : 'N/A',
                              ),
                              _InfoTile(
                                label: 'Age',
                                value: userData['age']?.toString() ?? 'N/A',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
                              content:
                                  Text('Error signing out: ${e.toString()}'),
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
          );
        },
      ),
    );
  }
}

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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 165,
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (hasArrow)
              const Icon(Icons.arrow_forward_ios, size: 16),
          ],
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
