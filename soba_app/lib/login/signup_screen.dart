import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:soba_app/firebase_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soba_app/login/complete_signup_screen.dart';
import 'package:soba_app/login/terms.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, this.onSignUpComplete});

  final VoidCallback? onSignUpComplete;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  bool _isTermsAccepted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_isTermsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the terms and conditions')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password must be at least 6 characters long')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user with email and password
      final userCredential =
          await FirebaseConfig.auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Store additional user data in Firestore
      await FirebaseConfig.firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': _nameController.text.trim().toLowerCase(),
        'phone': _phoneController.text.trim().toLowerCase(),
        'username': _usernameController.text.trim().toLowerCase(),
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'profileCompleted': false,
      });

      if (mounted) {
        // Call the completion callback
        // widget.onSignUpComplete?.call();
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return const CompleteSignupScreen();
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              // Slide from right to left
              const begin = Offset(1.0, 0.0); // 1.0 = all the way to the right
              const end = Offset.zero; // 0.0 = current position
              final tween = Tween(begin: begin, end: end);
              final offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred during sign up';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is invalid.';
      } else if (e.code == 'operation-not-allowed') {
        message =
            'Email/password accounts are not enabled. Please contact support.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final screenSize = MediaQuery.of(context).size;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      // Use resizeToAvoidBottomInset to handle keyboard properly
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          // Close keyboard when tapping outside text fields
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            height: screenSize.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0XFF4CAF93), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                // Hide this when keyboard is showing to give more space
                if (!keyboardVisible) ...[
                  SizedBox(height: 20),
                  Text(
                    'Welcome to Universal Safety',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: keyboardVisible ? 24 : 32,
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
                  SizedBox(height: 10),
                ],
                
                // Using Expanded to take available space
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFF003366),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(keyboardVisible ? 30 : 65)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(keyboardVisible ? 30 : 65)),
                      child: ListView(
                        padding: const EdgeInsets.all(14),
                        children: [
                          // Adjust spacing based on keyboard visibility
                          SizedBox(height: keyboardVisible ? 5 : 10),
                          
                          Text(
                            'Create Your Account',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: keyboardVisible ? 20 : 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Name TextField
                          SmartTextField(
                            label: 'Full Name',
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                          ),
                          // Phone Number TextField
                          SmartTextField(
                            label: 'Phone Number',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                          ),

                          // Username TextField
                          SmartTextField(
                            label: 'Username',
                            controller: _usernameController,
                            textInputAction: TextInputAction.next,
                          ),

                          // Email TextField
                          SmartTextField(
                            label: 'Email address',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),
                          // Password TextField
                          SmartTextField(
                            label: 'Password',
                            controller: _passwordController,
                            obscureText: true,
                            textInputAction: TextInputAction.next,
                          ),

                          // Confirm Password TextField
                          SmartTextField(
                            label: 'Confirm Password',
                            controller: _confirmPasswordController,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                          ),

                          // Terms and Conditions Checkbox with compact layout
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Transform.scale(
                                scale: 0.9,
                                child: Checkbox(
                                  activeColor: Colors.white,
                                  value: _isTermsAccepted,
                                  onChanged: (value) {
                                    setState(() {
                                      _isTermsAccepted = value!;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    text: 'I accept the ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: keyboardVisible ? 12 : 14,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Terms and Conditions',
                                        style: TextStyle(
                                          color: Colors.green,
                                          decoration: TextDecoration.underline,
                                          fontSize: keyboardVisible ? 12 : 14,
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
                          SizedBox(height: keyboardVisible ? 5 : 10),

                          // Sign Up Button
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleSignUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0XFF4CAF93),
                              padding: EdgeInsets.symmetric(
                                vertical: keyboardVisible ? 6 : 8,
                              ),
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
                                : Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      fontSize: keyboardVisible ? 18 : 24,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),

                          // Only show these when keyboard is hidden to save space
                          if (!keyboardVisible) ...[
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
                                      color: Colors.red, size: 28),
                                ),
                                const SizedBox(width: 20),
                                IconButton(
                                  onPressed: () {
                                    print('Apple Sign Up');
                                  },
                                  icon: const FaIcon(FontAwesomeIcons.apple,
                                      color: Colors.white, size: 32),
                                ),
                              ],
                            ),
                          ],

                          // Login Link - always show this
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Already have an account? Login here",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: keyboardVisible ? 13 : 14,
                              ),
                            ),
                          ),
                          
                          // Add extra padding at the bottom to ensure fields aren't hidden by keyboard
                          SizedBox(height: keyboardVisible ? MediaQuery.of(context).viewInsets.bottom * 0.1 : 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SmartTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final int? maxLines;
  final int? maxLength;

  const SmartTextField({
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  _SmartTextFieldState createState() => _SmartTextFieldState();
}

class _SmartTextFieldState extends State<SmartTextField> {
  late FocusNode _focusNode;
  bool _showLabel = true;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        // Hide label when focused, show when unfocused AND empty
        _showLabel = !_focusNode.hasFocus && widget.controller.text.isEmpty;
      });
    });

    // Add listener for text changes
    widget.controller.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    setState(() {
      // Update label visibility when text changes
      _showLabel = !_focusNode.hasFocus && widget.controller.text.isEmpty;
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    
    return Padding(
      padding: EdgeInsets.only(bottom: isKeyboardVisible ? 6 : 10),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        style: TextStyle(fontSize: isKeyboardVisible ? 14 : 16),
        decoration: InputDecoration(
          labelText: _showLabel ? widget.label : null,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            vertical: isKeyboardVisible ? 10 : 12, 
            horizontal: 16
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.blue.shade300),
          ),
          counterText: '',
          errorMaxLines: 2,
        ),
      ),
    );
  }
}