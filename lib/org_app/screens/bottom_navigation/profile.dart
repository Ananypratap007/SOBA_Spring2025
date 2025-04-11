import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:go_router/go_router.dart';
import 'package:location/location.dart';
import 'package:soba_app/config/firebase_config.dart';
import 'package:soba_app/shared/widgets/custom_form_fields.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Tools to get the user location
  final Location _location = Location();
  Timer? _locationTimer;
  StreamSubscription<LocationData>? _locationSubscription;
  bool _locationServiceEnabled = false;

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
    _initLocationService();
    _loadUserData();
  }

  Future<void> _initLocationService() async {
    try {
      // Request permissions
      var permission = await _location.requestPermission();
      if (permission != PermissionStatus.granted) {
        throw 'Location permission denied';
      }

      // Check service status
      _locationServiceEnabled = await _location.serviceEnabled();
      if (!_locationServiceEnabled) {
        _locationServiceEnabled = await _location.requestService();
        if (!_locationServiceEnabled) {
          throw 'Location service disabled';
        }
      }

      // Start periodic updates
      _startLocationUpdates();
    } catch (e) {
      _showLocationError(e.toString());
    }
  }

  void _startLocationUpdates() {
    // Immediate first update
    _updateLocation();

    // Periodic updates every 3 minutes
    _locationTimer = Timer.periodic(const Duration(minutes: 3), (timer) {
      _updateLocation();
    });

    // Continuous updates for better accuracy
    _locationSubscription = _location.onLocationChanged.listen(
      (LocationData currentLocation) async {
        if (currentLocation.latitude != null &&
            currentLocation.longitude != null) {
          await _updateLocationData(
            currentLocation.latitude!,
            currentLocation.longitude!,
          );
        }
      },
      onError: (e) => _showLocationError(e.toString()),
    );
  }

  Future<void> _updateLocation() async {
    try {
      final locationData = await _location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        await _updateLocationData(
          locationData.latitude!,
          locationData.longitude!,
        );
      }
    } catch (e) {
      _showLocationError(e.toString());
    }
  }

  Future<void> _updateLocationData(double lat, double lng) async {
    try {
      final address = await _reverseGeocode(lat, lng);
      await _updateFirestoreLocation(lat, lng, address);

      if (mounted) {
        setState(() => _userData?['location'] = address);
      }
    } catch (e) {
      _showLocationError('Geocoding failed: ${e.toString()}');
    }
  }

  Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      final places = await geocoding.placemarkFromCoordinates(lat, lng);
      if (places.isEmpty) return 'Unknown Location';

      final place = places.first;
      return '${place.locality}, ${place.administrativeArea?.substring(0, 2).toUpperCase()}';
    } catch (e) {
      return 'Location Unavailable';
    }
  }

  Future<void> _updateFirestoreLocation(
      double lat, double lng, String address) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'location': address,
      'coordinates': GeoPoint(lat, lng),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _locationSubscription?.cancel();
    super.dispose();
  }

  void _showLocationError(String error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location Error: $error')),
      );
    }
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
        // Store the value with the unit (e.g., "150.0 lb")
        parsedValue = value;
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

// Cupertino Picker for the height
  void _showHeightPicker() {
    int selectedFeet = 5;
    int selectedInches = 6;
    int selectedCm = 170;
    String selectedUnit = 'ft';

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: 250,
              child: Row(
                children: [
                  // Feet or CM picker
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 40,
                      scrollController: FixedExtentScrollController(
                        initialItem: selectedUnit == 'ft'
                            ? selectedFeet - 4
                            : selectedCm - 100,
                      ),
                      onSelectedItemChanged: (index) {
                        setModalState(() {
                          if (selectedUnit == 'ft') {
                            selectedFeet = index + 4;
                          } else {
                            selectedCm = index + 100;
                          }
                        });
                      },
                      children: selectedUnit == 'ft'
                          ? List.generate(
                              4,
                              (index) => Center(child: Text("${index + 4} ft")),
                            )
                          : List.generate(
                              150,
                              (index) =>
                                  Center(child: Text("${index + 100} cm")),
                            ),
                    ),
                  ),

                  // Inches picker (only for ft)
                  if (selectedUnit == 'ft')
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedInches,
                        ),
                        onSelectedItemChanged: (index) {
                          setModalState(() => selectedInches = index);
                        },
                        children: List.generate(
                          12,
                          (index) => Center(child: Text("$index in")),
                        ),
                      ),
                    )
                  else
                    const Spacer(), // For alignment

                  // Unit picker
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 40,
                      scrollController: FixedExtentScrollController(
                        initialItem: selectedUnit == 'cm' ? 0 : 1,
                      ),
                      onSelectedItemChanged: (index) {
                        setModalState(() {
                          selectedUnit = index == 0 ? 'cm' : 'ft';
                        });
                      },
                      children: const [
                        Center(child: Text("cm")),
                        Center(child: Text("ft")),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() async {
      String formattedHeight;
      if (selectedUnit == 'ft') {
        formattedHeight = "$selectedFeet' $selectedInches\"";
      } else {
        formattedHeight = "$selectedCm cm";
      }

      await _updateUserField("height", formattedHeight);
    });
  }

  // Weight Picker
  void _showWeightPicker() {
    double selectedWeight = 150.0;
    String selectedUnit = 'lb';

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: 250,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Weight Picker
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 40,
                      scrollController: FixedExtentScrollController(
                        initialItem: selectedUnit == 'lb'
                            ? (selectedWeight - 80).toInt()
                            : ((selectedWeight - 30) / 0.5).round(),
                      ),
                      onSelectedItemChanged: (index) {
                        setModalState(() {
                          selectedWeight = selectedUnit == 'lb'
                              ? 80 + index.toDouble()
                              : 30 + index * 0.5;
                        });
                      },
                      children: selectedUnit == 'lb'
                          ? List.generate(
                              321,
                              (index) => Center(
                                child: Text("${80 + index}"),
                              ),
                            )
                          : List.generate(
                              301,
                              (index) => Center(
                                child: Text(
                                    (30 + index * 0.5).toStringAsFixed(1)),
                              ),
                            ),
                    ),
                  ),

                  // Unit Picker
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 40,
                      scrollController: FixedExtentScrollController(
                        initialItem: selectedUnit == 'lb' ? 0 : 1,
                      ),
                      onSelectedItemChanged: (index) {
                        setModalState(() {
                          selectedUnit = index == 0 ? 'lb' : 'kg';
                          // Optionally reset weight for visual consistency
                          selectedWeight = selectedUnit == 'lb' ? 150 : 68.0;
                        });
                      },
                      children: const [
                        Center(child: Text("lb")),
                        Center(child: Text("kg")),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() async {
      final formattedWeight =
          "${selectedWeight.toStringAsFixed(1)} $selectedUnit";
      await _updateUserField("weight", formattedWeight);
    });
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
                    toTitleCase(_userData?['name'] ?? '') ?? 'User',
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
                          SectionWidget.buildInfoTile(
                              'Current Location', _userData?['location']),
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
                            value: toTitleCase(_userData?['gender']) ?? 'N/A',
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
                            value: toTitleCase(
                                _userData?['eyeColor']?.toString() ?? 'N/A'),
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
                            value: toTitleCase(
                                _userData?['hairColor']?.toString() ?? 'N/A'),
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
                            value: _userData?['height']?.toString() ?? 'N/A',
                            hasArrow: true,
                            onTap: _showHeightPicker,
                          ),
                          InfoTile(
                            label: 'Weight',
                            value: _userData?['weight']?.toString() ?? 'N/A',
                            hasArrow: true,
                            onTap: _showWeightPicker,
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
