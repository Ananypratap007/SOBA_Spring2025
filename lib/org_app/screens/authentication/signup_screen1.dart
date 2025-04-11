import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:soba_app/org_app/screens/authentication/signup_screen2.dart';
import 'package:soba_app/org_app/screens/authentication/login_screen.dart';
import 'package:soba_app/shared/widgets/custom_form_fields.dart';

class OrganizationCreatorSignUpScreen extends StatefulWidget {
  const OrganizationCreatorSignUpScreen({super.key, this.onSignUpComplete});

  final VoidCallback? onSignUpComplete;

  @override
  State<OrganizationCreatorSignUpScreen> createState() =>
      _OrganizationCreatorSignUpState();
}

class _OrganizationCreatorSignUpState
    extends State<OrganizationCreatorSignUpScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    // Just navigate to organization registration with the collected data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrganizationRegistrationScreen(
          userData: {
            'firstName': _firstNameController.text.trim(),
            'lastName': _lastNameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'username': _usernameController.text.trim(),
            'email': _emailController.text.trim(),
            'password': _passwordController.text,
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF003366),
        body: Column(
          children: [
            SizedBox(
              height: 45,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome Text
                  SizedBox(
                    height: 60,
                  ),
                  Text(
                    'Create Your Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Name TextField
                  DualInputField(
                    firstController: _firstNameController,
                    secondController: _lastNameController,
                    firstLabel: 'First Name',
                    secondLabel: 'Last Name',
                    firstHint: 'e.g. John',
                    secondHint: 'e.g. Doe',
                    fillColor: Colors.grey.shade50,
                  ),
                  // Phone Number TextField
                  SmartTextField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    hintText: 'e.g. 5554446666',
                  ),

                  // Username TextField
                  SmartTextField(
                    label: 'Username',
                    controller: _usernameController,
                    hintText: 'e.g. john03',
                  ),

                  // Email TextField
                  SmartTextField(
                    label: 'Email address',
                    controller: _emailController,
                    hintText: 'e.g. john.doe@gmail.com',
                  ),
                  // Password TextField
                  SmartTextField(
                    label: 'Password',
                    controller: _passwordController,
                    hintText: "Must exceed 6 characters and be alphanumeric",
                  ),

                  // Confirm Password TextField
                  SmartTextField(
                    label: 'Confirm Password',
                    controller: _confirmPasswordController,
                    hintText: "Must match password above",
                  ),

                  // Terms and Conditions Checkbox
                  const SizedBox(height: 5),

                  // Sign Up Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0XFF4CAF93),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Next',
                            style: TextStyle(fontSize: 24, color: Colors.white),
                          ),
                  ),
                  const SizedBox(height: 8),

                  // Social Sign Up Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          print('Google Sign Up');
                        },
                        icon: const FaIcon(FontAwesomeIcons.google,
                            color: Colors.red, size: 32),
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        onPressed: () {
                          print('Apple Sign Up');
                        },
                        icon: const FaIcon(FontAwesomeIcons.apple,
                            color: Colors.white, size: 37),
                      ),
                    ],
                  ),

                  // Login Link
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: const Text(
                      "Already have an account? Login here",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),

                  // Help Text
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ));
  }
}
