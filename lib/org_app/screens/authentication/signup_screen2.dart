import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soba_app/core/common/terms.dart';
import 'package:soba_app/org_app/screens/bottom_navigation/profile.dart';
import 'package:uuid/uuid.dart';
import 'package:soba_app/shared/widgets/custom_form_fields.dart';

class OrganizationRegistrationScreen extends StatefulWidget {
  final Map<String, String> userData;

  const OrganizationRegistrationScreen({super.key, required this.userData});

  @override
  State<OrganizationRegistrationScreen> createState() =>
      _OrganizationRegistrationScreenState();
}

class _OrganizationRegistrationScreenState
    extends State<OrganizationRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;
  bool _isLoading = false;
  bool _isTermsAccepted = false;

  // Controllers

  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _adminRoleController = TextEditingController();
  final TextEditingController _orgEmailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
  }

  Future<String> _generateOrgId(String orgName) async {
    final random = Uuid();
    String generatedId;
    bool exists;

    do {
      final randomDigits = random
          .v4()
          .substring(0, 6)
          .replaceAll(RegExp(r'[^0-9]'), '0')
          .padLeft(6, '0');
      generatedId =
          '${orgName.isNotEmpty ? orgName[0].toUpperCase() : "O"}$randomDigits';

      final query = await _firestore
          .collection('organizations')
          .where('orgId', isEqualTo: generatedId)
          .get();

      exists = query.docs.isNotEmpty;
    } while (exists);

    return generatedId;
  }

  Future<void> _completeRegistration() async {
    if (!_isTermsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept terms and conditions')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. First create the user account
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.userData['email']!,
        password: widget.userData['password']!,
      );

      // 2. Create organization
      final orgId = await _generateOrgId(_orgNameController.text);
      final orgRef = await _firestore.collection("organizations").add({
        'orgId': orgId,
        'name': _orgNameController.text,
        'email': _orgEmailController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'zip': _zipController.text,
        'createdAt': FieldValue.serverTimestamp(),
        'members': [userCredential.user!.uid],
        'adminId': userCredential.user!.uid,
      });

      // 3. Create user document with org reference
      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name':
            "${widget.userData['firstName']} ${widget.userData['lastName']}",
        'phone': widget.userData['phone'],
        'username': widget.userData['username'],
        'email': widget.userData['email'],
        'title': _adminRoleController.text,
        'role': 'admin',
        'organizationId': orgId,
        'createdAt': FieldValue.serverTimestamp(),
        'isAdmin': true,
        'profileCompleted': true,
        'fcmToken': '',
      });

      // 4. Show success dialog with orgID
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue, // Set your desired blue color
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Registration Successful',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your account has been successfully created.',
                      style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Organization ID: $orgId',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please save this ID as it will be needed for organization management.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfileScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue.shade700,
                        ),
                        child: const Text('Continue to Profile'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      // If anything fails, delete the user account if it was created
      try {
        await FirebaseAuth.instance.currentUser?.delete();
      } catch (_) {}

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration failed: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF003366),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Text(
                  'Register Your Organization',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width < 400 ? 30 : 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SmartTextField(
                label: "Your Role in The Organization",
                controller: _adminRoleController,
                hintText: "e.g. Administrator",
              ),
              SmartTextField(
                label: "Organization Name",
                controller: _orgNameController,
                hintText: "e.g. Red Cross USA",
              ),
              SmartTextField(
                label: "Organization Email",
                controller: _orgEmailController,
                hintText: 'red.crossusa@gmail.com',
              ),
              SmartTextField(
                label: "Organization Address",
                controller: _addressController,
                hintText: '123 Heavens St.',
              ),
              TripleInputField(
                  firstController: _cityController,
                  stateController: _stateController,
                  thirdController: _zipController,
                  firstHint: 'e.g. Norman',
                  secondHint: "OK",
                  thirdHint: "e.g. 73072",
                  firstLabel: "City/Town",
                  secondLabel: 'State',
                  thirdLabel: "ZIP Code"),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    side: WidgetStateBorderSide.resolveWith((states) {
                      return BorderSide(
                        color: Colors.white, // Border color
                        width: 2.0, // Border width
                      );
                    }),
                    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.white; // Fill color when checked
                      }
                      return Colors.transparent; // Fill color when unchecked
                    }),
                    checkColor: Color(0xFF4CAF93),
                    value: _isTermsAccepted,
                    onChanged: (value) {
                      setState(() {
                        _isTermsAccepted = value!;
                      });
                    },
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: 'I accept the ',
                        style: TextStyle(color: Colors.white),
                        children: [
                          TextSpan(
                            text: 'Terms and Conditions',
                            style: const TextStyle(
                              color: Colors.green,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const TermsAndConditionsPage(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _completeRegistration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0XFF4CAF93),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Complete Registration',
                        style: TextStyle(fontSize: 21, color: Colors.white),
                      ),
              ),
              // _buildSignInLink(),
            ],
          ),
        ),
      ),
    );
  }
}
