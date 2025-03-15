import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soba_app/profile/profile_presenter.dart';
import 'package:soba_app/auth_state.dart';

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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Wrap the scrollable content in Expanded so it takes up available space.
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Top Profile Header
                    Container(
                      width: double.infinity,
                      color: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        vertical: 24.0,
                        horizontal: 16.0,
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Ananya Gupta',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'ananyabusiness@hotmail.com',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '123-456-7890',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Personal Information Card (Expandable)
                    _buildExpandableInfoCard(
                      icon: Icons.person,
                      title: 'Personal Information',
                      details: [
                        _DetailItem(label: 'Full Name', value: 'Ananya Gupta'),
                        _DetailItem(label: 'Affiliated Organization', value: 'Red Cross'),
                        _DetailItem(label: 'Role/Time', value: 'Nurse'),
                        _DetailItem(label: 'Location', value: 'Norman, OK'),
                        _DetailItem.subheading('Biological Info'),
                        _DetailItem(label: 'Sex', value: 'Male'),
                        _DetailItem(label: 'Weight', value: '150lbs'),
                        _DetailItem(label: 'Age', value: '22'),
                        _DetailItem(label: 'Height', value: '5\'10'),
                        _DetailItem(label: 'Race', value: 'Asian (Indian)'),
                        _DetailItem(label: 'Hair Color', value: 'Black'),
                      ],
                    ),

                    // Vehicle Information Card for Vehicle 1 (Expandable)
                    _buildExpandableInfoCard(
                      icon: Icons.directions_car,
                      title: 'Vehicle 1',
                      details: [
                        _DetailItem(label: 'Make', value: 'Toyota'),
                        _DetailItem(label: 'Model', value: 'Camry'),
                        _DetailItem(label: 'License Plate', value: 'ABC 123'),
                      ],
                    ),

                    // Vehicle Information Card for Vehicle 2 (Expandable)
                    _buildExpandableInfoCard(
                      icon: Icons.directions_car,
                      title: 'Vehicle 2',
                      details: [
                        _DetailItem(label: 'Make', value: 'Honda'),
                        _DetailItem(label: 'Model', value: 'Civic'),
                        _DetailItem(label: 'License Plate', value: '972 XBT'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Logout Button at the very bottom
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
                child: InkWell(
                  onTap: () {
                  isLoggedIn = false; // update the auth state
                  context.go('/login');
                  },

                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a Card with an ExpansionTile that displays an icon, title,
  /// and an expandable list of details.
  Widget _buildExpandableInfoCard({
    required IconData icon,
    required String title,
    required List<_DetailItem> details,
  }) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 2,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(icon, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        children: details.map((detail) {
          if (detail.isSubheading) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 140,
                    child: Text(
                      detail.label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(),
                ],
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 140,
                    child: Text(
                      '${detail.label}:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(child: Text(detail.value)),
                ],
              ),
            );
          }
        }).toList(),
      ),
    );
  }
}

/// Simple class to hold label/value pairs for the detail rows.
/// You can also mark an item as a subheading if you want to style it differently.
class _DetailItem {
  final String label;
  final String value;
  final bool isSubheading;

  _DetailItem({
    required this.label,
    required this.value,
    this.isSubheading = false,
  });

  /// Named constructor to create a "subheading" item (e.g., "Biological Info")
  _DetailItem.subheading(String heading)
      : label = heading,
        value = '',
        isSubheading = true;
}
