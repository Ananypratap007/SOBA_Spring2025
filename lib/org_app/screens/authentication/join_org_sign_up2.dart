import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:soba_app/config/firebase_config.dart';
import 'package:soba_app/config/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soba_app/core/common/terms.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class JoinOrganizationScreen2 extends StatefulWidget {
  const JoinOrganizationScreen2({super.key});

  @override
  State<JoinOrganizationScreen2> createState() => _JoinOrganizationScreen2State();
}

class _JoinOrganizationScreen2State extends State<JoinOrganizationScreen2> {
  Uint8List? _profileImage;
  final _formKey = GlobalKey<FormState>();
  final _orgNameController = TextEditingController();
  final _raceController = TextEditingController();
  final _genderController = TextEditingController();
  final _eyeColorController = TextEditingController();
  final _hairColorController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  final _dobController = TextEditingController();
  final _roleController = TextEditingController();

  bool _isLoading = false;
  final bool _isTermsAccepted = false;

  Future<String?> uploadImageToImgBB(Uint8List imageBytes) async {
    // Compress image first

    final compressedImage = await _compressImage(imageBytes);

    final uri = Uri.parse('https://api.imgbb.com/1/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['key'] = "c8b90fb020f7e14357bcebfc30d9b376"
      ..files.add(http.MultipartFile.fromBytes(
          'image', compressedImage ?? imageBytes,
          filename: 'profile_${DateTime.now().microsecondsSinceEpoch}.jpg'));

    try {
      final response = await request.send();
      final json = await response.stream.bytesToString();
      final parsed = jsonDecode(json);
      return parsed['data']['url'];
    } catch (e) {
      print("Failed to upload to imgBB");
      return null;
    }
  }

  Future<Uint8List?> _compressImage(Uint8List bytes) async {
    try {
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      // Resize to max 800px with/height and compress
      final resized = img.copyResize(image, width: 800, height: 800);
      return Uint8List.fromList(img.encodeJpg(resized, quality: 70));
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

// Function to pick image from gallery

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _profileImage = bytes;
      });
    }
  }

  // Function to take photo with camera
  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      final bytes = await photo.readAsBytes();
      setState(() {
        _profileImage = bytes;
      });
    }
  }

  Future<void> _handleCompleteSignup() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("No user logged in");

      String? profileImageUrl;
      if (_profileImage != null) {
        profileImageUrl = await uploadImageToImgBB(_profileImage!);
        if (profileImageUrl == null) {
          throw Exception("Failed to upload profile picture");
        }
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'orgName': _orgNameController.text.trim(),
        'role': _roleController.text.trim(),
        'race': _raceController.text.trim(),
        'gender': _genderController.text.trim(),
        'eyeColor': _eyeColorController.text.trim(),
        'hairColor': _hairColorController.text.trim(),
        'height': _heightController.text.trim(),
        'weight': _weightController.text.trim(),
        'age': _ageController.text.trim(),
        'profileImage': profileImageUrl, // Store imgBB URL
        'profileCompleted': true,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile completed successfully!')),
        );
        context.go('/');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;

    // If today's month/day is before the birthDate month/day, subtract one year
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  void dispose() {
    _raceController.dispose();
    _orgNameController.dispose();
    _genderController.dispose();
    _eyeColorController.dispose();
    _hairColorController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _dobController.dispose();
    _ageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003366),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 5),

              // Title
              Center(
                child: Text(
                  "Complete Your Profile",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Profile Image Section
              Column(
                children: [
                  GestureDetector(
                    onTap: _showImagePickerOptions,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Color(0XFF4CAF93),
                      child: CircleAvatar(
                        radius: 66,
                        backgroundColor: Colors.white,
                        child: _profileImage != null
                            ? ClipOval(
                                child: Image.memory(
                                  _profileImage!,
                                  width: 134,
                                  height: 134,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.person_add,
                                size: 50,
                                color: Color(0xFF003366),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextButton(
                    onPressed: _showImagePickerOptions,
                    child: const Text(
                      'Add Profile Picture',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Affiliated Organization TextField
              TextField(
                controller: _orgNameController,
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  labelText: 'Affiliated Organization',
                  hintText: 'e.g. Red Cross America',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF4CAF93), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Race and Gender TextFields
              DualInputField(
                firstController: _raceController,
                secondController: _genderController,
                firstLabel: 'Race',
                secondLabel: 'Gender',
                firstHint: "e.g. Asian",
                secondHint: "e.g. Male",
                fillColor: Colors.grey.shade50,
              ),

              // Weight and Height TextFields
              DualInputField(
                firstController: _weightController,
                secondController: _heightController,
                firstLabel: 'Weight',
                secondLabel: 'Height',
                firstHint: "e.g. 110 lb",
                secondHint: "e.g. 5'11",
                fillColor: Colors.grey.shade50,
              ),

              // Eye Color and Hair Color TextFields
              DualInputField(
                firstController: _eyeColorController,
                secondController: _hairColorController,
                firstLabel: 'Eye Color',
                secondLabel: 'Hair Color',
                firstHint: 'e.g. Blue',
                secondHint: 'e.g. Brown',
                fillColor: Colors.grey.shade50,
              ),

              SizedBox(
                height: 5,
              ),
              // Date of Birth TextField
              TextField(
                controller: _dobController,
                readOnly: true, // so keyboard won’t pop up
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  hintText: 'Tap to select date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF4CAF93), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),

                // Trigger the date picker on tap
                onTap: () async {
                  // First, unfocus so the keyboard doesn't appear
                  FocusScope.of(context).requestFocus(FocusNode());

                  // Show the date picker
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000), // default
                    firstDate: DateTime(1900), // earliest allowed dob
                    lastDate: DateTime.now(), // latest allowed dob (today)
                  );

                  // If user picked a date, calculate age
                  if (selectedDate != null) {
                    // Format the selected date in a nice string, e.g., 2025-03-15
                    _dobController.text =
                        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

                    // Calculate age and set it to the ageController
                    final age = _calculateAge(selectedDate);
                    _ageController.text = age.toString();
                  }
                },
              ),

              const SizedBox(height: 15),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleCompleteSignup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0XFF4CAF93),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Complete Signup',
                        style: TextStyle(fontSize: 21, color: Colors.white),
                      ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class DualInputField extends StatelessWidget {
  final TextEditingController firstController;
  final TextEditingController secondController;
  final String firstLabel;
  final String secondLabel;
  final String? firstHint;
  final String? secondHint;
  final TextInputType? firstInputType;
  final TextInputType? secondInputType;
  final String? Function(String?)? firstValidator;
  final String? Function(String?)? secondValidator;
  final double spacing;
  final double borderRadius; // New parameter for border radius
  final Color fillColor; // New parameter for fill color

  const DualInputField({
    super.key,
    required this.firstController,
    required this.secondController,
    required this.firstLabel,
    required this.secondLabel,
    this.firstHint,
    this.secondHint,
    this.firstInputType,
    this.secondInputType,
    this.firstValidator,
    this.secondValidator,
    this.spacing = 16.0,
    this.borderRadius = 12.0, // Default radius value
    this.fillColor = Colors.white, // Default fill color
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: firstController,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelText: firstLabel,
                hintText: firstHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(color: Color(0xFF4CAF93), width: 2),
                ),
                filled: true,
                fillColor: fillColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              keyboardType: firstInputType,
              validator: firstValidator,
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: TextFormField(
              controller: secondController,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelText: secondLabel,
                hintText: secondHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(color: Colors.blue.shade300, width: 2),
                ),
                filled: true,
                fillColor: fillColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              keyboardType: secondInputType,
              validator: secondValidator,
            ),
          ),
        ],
      ),
    );
  }
}
