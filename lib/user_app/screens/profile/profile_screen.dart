import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:soba_app/config/firebase_config.dart';
import 'package:soba_app/config/firebase_storage_helper.dart';
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
  final _imagePicker = ImagePicker();
  File? _selectedImage;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _orgData;
  bool _isLoading = true;
  bool _wellnessCheckEnabled = false;
  bool _isUploadingImage = false;
  
  // Expansion state for sections
  bool _isAccountInfoExpanded = false;
  bool _isPersonalInfoExpanded = false;
  bool _isOrgInfoExpanded = false;
  bool _isSettingsExpanded = false;
  bool _connected = false; // Add this variable to track device connection status
  bool _isVehicleInfoExpanded = false; // Add a new state variable for the vehicle section

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

  // Future<void> _loadUserData() async {
  //   try {
  //     final user = _auth.currentUser;
  //     if (user != null) {
  //       final userDoc =
  //           await _firestore.collection('users').doc(user.uid).get();
  //       if (userDoc.exists) {
  //         setState(() => _userData = userDoc.data());

  //         if (_userData?['orgId'] != null) {
  //           final orgQuery = await _firestore
  //               .collection('organizations')
  //               .doc(_userData!['orgId'])
  //               .get();
  //           if (orgQuery.exists) {
  //             setState(() => _orgData = orgQuery.data() as Map<String, dynamic>);
  //           }
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error loading data: ${e.toString()}')),
  //     );
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isLoading = false);
  //     }
  //   }
  // }

  Future<void> _loadUserData() async {
  try {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() => _userData = userDoc.data());

        final orgId = _userData?['orgId'];
        if (orgId != null) {
          final orgDocSnap = await _firestore
    .collection('organizations')
    .where('orgId', isEqualTo: _userData?['orgId'])
    .limit(1)
    .get();

if (orgDocSnap.docs.isNotEmpty) {
  setState(() => _orgData = orgDocSnap.docs.first.data());
}

        }
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error loading data: ${e.toString()}')),
    );
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}


  // void _loadOrgData() async {
  //   if (_userData != null && _userData!['orgId'] != null) {
  //     final orgSnapshot = await _firestore
  //         .collection('organizations')
  //         .doc(_userData!['orgId'])
  //         .get();
  //     if (orgSnapshot.exists) {
  //       setState(() {
  //         _orgData = orgSnapshot.data() as Map<String, dynamic>;
  //       });
  //     }
  //   }
  // }

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

  // Method to pick and upload profile image
  Future<void> _pickAndUploadImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF003366),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Change Profile Picture',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Camera option
                _buildImageSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _getImageAndUpload(ImageSource.camera);
                  },
                ),
                // Gallery option
                _buildImageSourceOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _getImageAndUpload(ImageSource.gallery);
                  },
                ),
                // Remove photo option (if there's already a profile photo)
                if (_userData?['photoUrl'] != null)
                  _buildImageSourceOption(
                    icon: Icons.delete,
                    label: 'Remove',
                    onTap: () {
                      Navigator.pop(context);
                      _removeProfilePhoto();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Widget for image source option
  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0XFF4CAF93),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Method to get image from camera or gallery and upload
  Future<void> _getImageAndUpload(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 75, // Reduce image quality for faster uploads
      );
      
      if (pickedFile == null) return;
      
      setState(() {
        _selectedImage = File(pickedFile.path);
        _isUploadingImage = true;
      });
      
      // Upload the image to Firebase Storage
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      
      final imageUrl = await FirebaseStorageHelper.uploadProfileImage(
        file: _selectedImage!,
        context: context,
      );
      
      // Update the user's photoUrl in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': imageUrl,
      });
      
      // Update local state
      setState(() {
        _userData?['photoUrl'] = imageUrl;
        _isUploadingImage = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully!')),
        );
      }
    } catch (e) {
      setState(() => _isUploadingImage = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile picture: ${e.toString()}')),
        );
      }
    }
  }

  // Method to remove profile photo
  Future<void> _removeProfilePhoto() async {
    try {
      setState(() => _isUploadingImage = true);
      
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      
      // Update the user's photoUrl in Firestore to null or a default placeholder
      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': null, // Or use a default placeholder URL
      });
      
      // Update local state
      setState(() {
        _userData?['photoUrl'] = null;
        _isUploadingImage = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture removed')),
        );
      }
    } catch (e) {
      setState(() => _isUploadingImage = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing profile picture: ${e.toString()}')),
        );
      }
    }
  }

  // Helper: get vehicles stored with keys starting with "vehicle"
  List<MapEntry<String, dynamic>> _getUserVehicles() {
    if (_userData == null) return [];
    final vehicles = _userData!.entries.where((entry) => entry.key.startsWith("vehicle")).toList();
    vehicles.sort((a, b) {
      int aNum = int.tryParse(a.key.replaceFirst("vehicle", "")) ?? 0;
      int bNum = int.tryParse(b.key.replaceFirst("vehicle", "")) ?? 0;
      return aNum.compareTo(bNum);
    });
    return vehicles;
  }

  // Dialog to add or edit a vehicle.
  Future<void> _showVehicleDialog({String? vehicleKey, Map<String, dynamic>? vehicleData}) async {
    final isEditing = vehicleKey != null;
    final licenseController = TextEditingController(text: vehicleData?['licensePlate'] ?? '');
    final makeController = TextEditingController(text: vehicleData?['make'] ?? '');
    final modelController = TextEditingController(text: vehicleData?['model'] ?? '');
    final colorController = TextEditingController(text: vehicleData?['color'] ?? '');
  
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Vehicle' : 'Add Vehicle'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: licenseController,
                decoration: const InputDecoration(labelText: 'License Plate #'),
              ),
              TextField(
                controller: makeController,
                decoration: const InputDecoration(labelText: 'Make'),
              ),
              TextField(
                controller: modelController,
                decoration: const InputDecoration(labelText: 'Model'),
              ),
              TextField(
                controller: colorController,
                decoration: const InputDecoration(labelText: 'Color'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final license = licenseController.text.trim();
              final make = makeController.text.trim();
              final model = modelController.text.trim();
              final color = colorController.text.trim();
              
              if (license.isEmpty || make.isEmpty || model.isEmpty || color.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All fields are required')),
                );
                return;
              }
              
              // Determine key to update: If not editing, assign next available vehicle key.
              String keyToUpdate = vehicleKey ?? '';
              if (!isEditing) {
                final currentCount = _getUserVehicles().length;
                keyToUpdate = 'vehicle${currentCount + 1}';
              }
              
              final vehicleMap = {
                'licensePlate': license,
                'make': make,
                'model': model,
                'color': color,
              };
              
              final user = _auth.currentUser;
              if (user != null) {
                await _firestore.collection('users').doc(user.uid).update({
                  keyToUpdate: vehicleMap,
                });
                setState(() {
                  _userData?[keyToUpdate] = vehicleMap;
                });
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Vehicle ${isEditing ? 'updated' : 'added'} successfully!')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteVehicle(String vehicleKey) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    // Delete the specific vehicle key from Firestore.
    await _firestore.collection('users').doc(user.uid).update({
      vehicleKey: FieldValue.delete(),
    });
    
    // Remove it locally.
    setState(() {
      _userData?.remove(vehicleKey);
    });
    
    // Re-index the remaining vehicles.
    final vehicles = _getUserVehicles()
        .where((entry) => entry.value is Map<String, dynamic>)
        .toList();
    
    // Create a new mapping with consecutive keys.
    Map<String, dynamic> newVehicles = {};
    for (int i = 0; i < vehicles.length; i++) {
      newVehicles['vehicle${i + 1}'] = vehicles[i].value;
    }
    
    // Update Firestore document with the new mapping.
    // This update will overwrite the existing vehicle fields.
    await _firestore.collection('users').doc(user.uid).update(newVehicles);
    
    // Update local _userData: remove all old vehicle keys and add the reindexed ones.
    setState(() {
      _userData?.removeWhere((key, value) => key.startsWith('vehicle'));
      _userData?.addAll(newVehicles);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vehicle deleted and vehicles reindexed')),
    );
  }

  Widget _buildVehicleTile(String vehicleKey, Map<String, dynamic> vehicleData) {
    final String make = vehicleData['make'] ?? 'Unknown';
    final String model = vehicleData['model'] ?? 'Unknown';
    final String licensePlate = vehicleData['licensePlate'] ?? 'N/A';
    final String color = vehicleData['color'] ?? 'N/A';
    
    return Card(
      color: Colors.transparent,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title displays Make and Model
            Text(
              "$make $model",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            // License Plate field
            Text(
              "License Plate #: $licensePlate",
              style: const TextStyle(color: Colors.white),
            ),
            // Color field
            Text(
              "Color: $color",
              style: const TextStyle(color: Colors.white),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Edit button
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
                  onPressed: () {
                    _showVehicleDialog(vehicleKey: vehicleKey, vehicleData: vehicleData);
                  },
                ),
                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white70, size: 20),
                  onPressed: () {
                    _deleteVehicle(vehicleKey);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0XFF4CAF93),
        body: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_userData == null) {
      return Scaffold(
        backgroundColor: const Color(0XFF4CAF93),
        body: const Center(child: Text('No user data found', style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color(0XFF4CAF93)),
        child: SafeArea(
          child: Column(
            children: [
              // Profile Header in top section
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: _isUploadingImage
                                ? const CircularProgressIndicator(color: Color(0XFF4CAF93))
                                : CircleAvatar(
                                    radius: 47,
                                    backgroundImage: NetworkImage(
                                      _userData?['photoUrl'] ??
                                          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                                    ),
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0XFF4CAF93),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      toTitleCase(_userData?['name']) ?? 'User',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black54,
                            offset: Offset(1, 1),
                          )
                        ],
                      ),
                    ),
                    Text(
                      toTitleCase(_userData?['role']) ?? 'MEMBER',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content area with sections and logout at bottom
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF003366),
                  ),
                  child: Stack(
                    children: [
                      // Scrollable content (all sections)
                      SingleChildScrollView(
                        padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 80),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Account Information Dropdown
                            _buildExpandableSection(
                              title: 'Account Information',
                              isExpanded: _isAccountInfoExpanded,
                              onToggle: () => setState(() => _isAccountInfoExpanded = !_isAccountInfoExpanded),
                              children: [
                                _buildInfoTile('Full Name', toTitleCase(_userData?['name'])),
                                _buildInfoTile('Username', _userData?['username']),
                                _buildInfoTile('Email', _userData?['email']),
                                _buildInfoTile('Phone', _userData?['phone']),
                                _buildInfoTile('Password', '••••••', hasArrow: true),
                                // if (_userData?['orgId'] != null && _orgData != null)
                                  _buildInfoTile('Organization', toTitleCase(_orgData?['name']) ?? 'N/A'),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Personal Information Dropdown
                            _buildExpandableSection(
                              title: 'Personal Information',
                              isExpanded: _isPersonalInfoExpanded,
                              onToggle: () => setState(() => _isPersonalInfoExpanded = !_isPersonalInfoExpanded),
                              children: [
                                _buildInfoTile('Current Location', _userData?['location']),
                                _buildInfoTile(
                                  'Race', 
                                  _userData?['race'] ?? 'N/A', 
                                  hasArrow: true,
                                  onTap: () => _showEditDialog(
                                    'race',
                                    _userData?['race']?.toString().toUpperCase() ?? '',
                                    'Race',
                                  ),
                                ),
                                _buildInfoTile(
                                  'Gender',
                                  toTitleCase(_userData?['gender']) ?? 'N/A',
                                  hasArrow: true,
                                  onTap: () => _showEditDialog(
                                    'gender',
                                    _userData?['gender']?.toString().toUpperCase() ?? '',
                                    'Gender',
                                  ),
                                ),
                                _buildInfoTile(
                                  'Eye Color',
                                  toTitleCase(_userData?['eyeColor']?.toString() ?? 'N/A'),
                                  hasArrow: true,
                                  onTap: () => _showEditDialog(
                                    'eyeColor',
                                    _userData?['eyeColor']?.toString().toUpperCase() ?? '',
                                    'Eye Color',
                                  ),
                                ),
                                _buildInfoTile(
                                  'Hair Color',
                                  toTitleCase(_userData?['hairColor']?.toString() ?? 'N/A'),
                                  hasArrow: true,
                                  onTap: () => _showEditDialog(
                                    'hairColor',
                                    _userData?['hairColor']?.toString().toUpperCase() ?? '',
                                    'Hair Color',
                                  ),
                                ),
                                _buildInfoTile(
                                  'Height',
                                  _userData?['height']?.toString() ?? 'N/A',
                                  hasArrow: true,
                                  onTap: _showHeightPicker,
                                ),
                                _buildInfoTile(
                                  'Weight',
                                  _userData?['weight']?.toString() ?? 'N/A',
                                  hasArrow: true,
                                  onTap: _showWeightPicker,
                                ),
                                _buildInfoTile(
                                  'Age',
                                  _userData?['age']?.toString() ?? 'N/A',
                                  hasArrow: true,
                                  onTap: () => _showEditDialog(
                                    'age',
                                    _userData?['age']?.toString() ?? '',
                                    'Age',
                                  ),
                                ),
                              ],
                            ),

                            if (_orgData != null) ...[
                              const SizedBox(height: 16),
                              // Organization Information Dropdown
                              _buildExpandableSection(
                                title: 'Organization',
                                isExpanded: _isOrgInfoExpanded,
                                onToggle: () => setState(() => _isOrgInfoExpanded = !_isOrgInfoExpanded),
                                children: [
                                  _buildInfoTile('Name', _orgData?['name'].toString().toUpperCase()),
                                  _buildInfoTile('ID', _orgData?['orgId'].toString().toUpperCase()),
                                  _buildInfoTile(
                                    'Emergency Contacts',
                                    'View List',
                                    hasArrow: true,
                                    onTap: () => context.push('/emergency-contacts'),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Wellness Checks',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Switch(
                                        value: _wellnessCheckEnabled,
                                        onChanged: (value) => setState(() => _wellnessCheckEnabled = value),
                                        activeColor: Color(0XFF4CAF93),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 16),
                            
                            // New Vehicle Information Section
                            _buildExpandableSection(
                              title: 'Vehicle Information',
                              isExpanded: _isVehicleInfoExpanded,
                              onToggle: () => setState(() => _isVehicleInfoExpanded = !_isVehicleInfoExpanded),
                              children: [
                                Column(
                                  children: [
                                    ..._getUserVehicles()
                                        .where((entry) => entry.value is Map<String, dynamic>)
                                        .map((entry) => _buildVehicleTile(entry.key, entry.value as Map<String, dynamic>)),
                                    if (_getUserVehicles().length < 3)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            _showVehicleDialog();
                                          },
                                          icon: const Icon(Icons.add, size: 20),
                                          label: const Text('Add Vehicle'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0XFF4CAF93),
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            // Settings Dropdown
                            _buildExpandableSection(
                              title: 'Settings',
                              isExpanded: _isSettingsExpanded,
                              onToggle: () => setState(() => _isSettingsExpanded = !_isSettingsExpanded),
                              children: [
                                _buildInfoTile('Notifications', '', hasArrow: true),
                                _buildInfoTile('Privacy', '', hasArrow: true),
                                _buildInfoTile('Theme', 'System Default', hasArrow: true),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Device Status Container - Moved outside of settings
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.devices, color: Colors.white, size: 22),
                                      SizedBox(width: 10),
                                      Text(
                                        "Device Status",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: const Color(0XFF4CAF93).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              _connected ? Icons.wifi : Icons.wifi_off,
                                              color: _connected ? Colors.green[200] : Colors.red[200],
                                              size: 24,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              _connected ? "Connected" : "Disconnected",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              _connected = !_connected;
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _connected 
                                                ? Colors.red.shade700
                                                : const Color(0XFF4CAF93),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            minimumSize: const Size(50, 40),
                                            elevation: 2,
                                          ),
                                          child: Text(
                                            _connected ? "Disconnect" : "Connect",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Add extra padding at the bottom to ensure scroll area extends past the logout button
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                      
                      // Fixed logout button at bottom
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          decoration: BoxDecoration(
                            color: Color(0xFF003366),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFF003366).withOpacity(0.8),
                                Color(0xFF003366),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, -4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.logout_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              label: const Text(
                                'LOGOUT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                                minimumSize: const Size(220, 20),
                                elevation: 5,
                                shadowColor: Colors.red.shade900.withOpacity(0.5),
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
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0XFF4CAF93),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 8),
          _buildInfoCard(children),
        ],
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String? value, {bool hasArrow = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Row(
              children: [
                Text(
                  value ?? 'N/A',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                if (hasArrow) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 14),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String toTitleCase(String? text) {
  if (text == null || text.isEmpty) return 'N/A';
  
  return text.split(' ').map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}
