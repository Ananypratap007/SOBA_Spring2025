// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:soba_app/org_app/screens/authentication/login_screen.dart';
// import 'package:soba_app/org_app/screens/bottom_navigation/profile.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:soba_app/shared/widgets/custom_form_fields.dart';

// class JoinOrganizationScreen extends StatefulWidget {
//   const JoinOrganizationScreen({super.key, this.onSignUpComplete});

//   final VoidCallback? onSignUpComplete;

//   @override
//   State<JoinOrganizationScreen> createState() => _JoinOrganizationScreenState();
// }

// class _JoinOrganizationScreenState extends State<JoinOrganizationScreen> {
//   late final TextEditingController _firstNameController;
//   late final TextEditingController _lastNameController;
//   late final TextEditingController _phoneController;
//   late final TextEditingController _usernameController;
//   late final TextEditingController _emailController;
//   late final TextEditingController _passwordController;
//   late final TextEditingController _confirmPasswordController;
//   late final TextEditingController _orgIdController;
//   late final TextEditingController _roleController;
//   bool _isLoading = false;
//   bool _isTermsAccepted = false;

//   @override
//   void initState() {
//     super.initState();
//     _firstNameController = TextEditingController();
//     _lastNameController = TextEditingController();
//     _phoneController = TextEditingController();
//     _usernameController = TextEditingController();
//     _roleController = TextEditingController();
//     _emailController = TextEditingController();
//     _passwordController = TextEditingController();
//     _confirmPasswordController = TextEditingController();
//     _orgIdController = TextEditingController();
//   }

//   @override
//   void dispose() {
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _phoneController.dispose();
//     _usernameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _orgIdController.dispose();
//     _roleController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleSignUp() async {
//     if (!_isTermsAccepted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please accept terms and conditions')),
//       );
//       return;
//     }

//     if (_passwordController.text != _confirmPasswordController.text) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Passwords do not match')),
//       );
//       return;
//     }

//     if (_passwordController.text.length < 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Password must be at least 6 characters')),
//       );
//       return;
//     }

//     if (_orgIdController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter an Organization ID')),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       // 1. Create user account
//       final userCredential =
//           await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text,
//       );

//       // 2. Verify organization exists
//       final orgQuery = await FirebaseFirestore.instance
//           .collection('organizations')
//           .where('orgId', isEqualTo: _orgIdController.text.trim())
//           .limit(1)
//           .get();

//       if (orgQuery.docs.isEmpty) {
//         throw Exception('Organization not found with this ID');
//       }

//       final orgId = orgQuery.docs.first.id;
//       final orgData = orgQuery.docs.first.data();

//       // 3. Add user to organization's members
//       await FirebaseFirestore.instance
//           .collection('organizations')
//           .doc(orgId)
//           .update({
//         'members': FieldValue.arrayUnion([userCredential.user!.uid])
//       });

//       // 4. Create user document
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userCredential.user!.uid)
//           .set({
//         'uid': userCredential.user!.uid,
//         'firstName': _firstNameController.text.trim().toLowerCase(),
//         'lastName': _lastNameController.text.trim().toLowerCase(),
//         'name':
//             '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
//         'phone': _phoneController.text.trim(),
//         'username': _usernameController.text.trim(),
//         'email': _emailController.text.trim(),
//         'organizationId': orgId.toUpperCase(),
//         'orgName': orgData['name'].toString().toLowerCase(),
//         'role': _roleController.text.trim().toLowerCase(),
//         'createdAt': FieldValue.serverTimestamp(),
//         'profileCompleted': true,
//       });

//       // 5. Navigate to profile screen
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ProfileScreen(),
//           ),
//         );
//       }
//     } on FirebaseAuthException catch (e) {
//       String message = 'Sign up failed';
//       if (e.code == 'email-already-in-use') {
//         message = 'Email already in use';
//       } else if (e.code == 'weak-password') {
//         message = 'Password is too weak';
//       }
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text(message)));
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}')),
//       );
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF003366),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const SizedBox(height: 45),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   const SizedBox(height: 60),
//                   const Text(
//                     'Join an Organization',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 30,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 15),

//                   // Organization ID Field
//                   SmartTextField(
//                     label: "Organization ID",
//                     controller: _orgIdController,
//                     hintText: "Enter the provided Organization ID",
//                   ),

//                   // Personal Information Fields
//                   DualInputField(
//                     firstController: _firstNameController,
//                     secondController: _lastNameController,
//                     firstLabel: 'First Name',
//                     secondLabel: 'Last Name',
//                     firstHint: 'e.g. John',
//                     secondHint: 'e.g. Doe',
//                     fillColor: Colors.grey.shade50,
//                   ),
//                   SmartTextField(
//                     label: 'Role/Title/Postion',
//                     controller: _roleController,
//                     hintText: 'e.g. Regional Administrator',
//                     keyboardType: TextInputType.phone,
//                   ),
//                   SmartTextField(
//                     label: 'Phone Number',
//                     controller: _phoneController,
//                     hintText: 'e.g. 5554446666',
//                     keyboardType: TextInputType.phone,
//                   ),

//                   SmartTextField(
//                     label: 'Username',
//                     controller: _usernameController,
//                     hintText: 'e.g. john03',
//                   ),

//                   SmartTextField(
//                     label: 'Email address',
//                     controller: _emailController,
//                     hintText: 'e.g. john.doe@gmail.com',
//                     keyboardType: TextInputType.emailAddress,
//                   ),

//                   SmartTextField(
//                     label: 'Password',
//                     controller: _passwordController,
//                     hintText: "Must be at least 6 characters",
//                     obscureText: true,
//                   ),

//                   SmartTextField(
//                     label: 'Confirm Password',
//                     controller: _confirmPasswordController,
//                     hintText: "Re-enter your password",
//                     obscureText: true,
//                   ),

//                   // Terms Checkbox
//                   Row(
//                     children: [
//                       Checkbox(
//                         value: _isTermsAccepted,
//                         onChanged: (value) =>
//                             setState(() => _isTermsAccepted = value ?? false),
//                         fillColor: WidgetStateProperty.all(Colors.white),
//                       ),
//                       Expanded(
//                         child: RichText(
//                           text: const TextSpan(
//                             text: 'I accept the ',
//                             style: TextStyle(color: Colors.white),
//                             children: [
//                               TextSpan(
//                                 text: 'Terms and Conditions',
//                                 style: TextStyle(
//                                   color: Colors.green,
//                                   decoration: TextDecoration.underline,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 5),

//                   // Sign Up Button
//                   ElevatedButton(
//                     onPressed: _isLoading ? null : _handleSignUp,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0XFF4CAF93),
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                     ),
//                     child: _isLoading
//                         ? const SizedBox(
//                             height: 24,
//                             width: 24,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: Colors.white,
//                             ),
//                           )
//                         : const Text(
//                             'Create Account',
//                             style: TextStyle(fontSize: 18, color: Colors.white),
//                           ),
//                   ),

//                   const SizedBox(height: 16),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => LoginScreen()),
//                       );
//                     },
//                     child: const Text(
//                       "Already have an account? Login here",
//                       style: TextStyle(color: Colors.blue),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soba_app/shared/widgets/custom_form_fields.dart';
import 'package:soba_app/org_app/screens/authentication/login_screen.dart';
import 'package:soba_app/org_app/screens/bottom_navigation/profile.dart';

class JoinOrganizationScreen extends StatefulWidget {
  const JoinOrganizationScreen({super.key, this.onSignUpComplete});

  final VoidCallback? onSignUpComplete;

  @override
  State<JoinOrganizationScreen> createState() => _JoinOrganizationScreenState();
}

class _JoinOrganizationScreenState extends State<JoinOrganizationScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _orgIdController;
  late final TextEditingController _roleController;

  bool _isLoading = false;
  bool _isTermsAccepted = false;

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
    _orgIdController = TextEditingController();
    _roleController = TextEditingController();
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
    _orgIdController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchOrganizations() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('organizations')
        .limit(50)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'name': data['name'] ?? 'Unknown',
        'orgId': data['orgId'] ?? '',
      };
    }).toList();
  }

  Future<void> _handleSignUp() async {
    if (!_isTermsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept terms and conditions')),
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
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    if (_orgIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an Organization')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create user
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Verify organization
      final orgQuery = await FirebaseFirestore.instance
          .collection('organizations')
          .where('orgId', isEqualTo: _orgIdController.text.trim())
          .limit(1)
          .get();

      if (orgQuery.docs.isEmpty) {
        throw Exception('Organization not found');
      }

      final orgDoc = orgQuery.docs.first;
      final orgId = orgDoc.id;
      final orgData = orgDoc.data();

      // Add user to organization
      await FirebaseFirestore.instance
          .collection('organizations')
          .doc(orgId)
          .update({
        'members': FieldValue.arrayUnion([userCredential.user!.uid]),
      });

      // Create user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'uid': userCredential.user!.uid,
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'name':
            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
        'phone': _phoneController.text.trim(),
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'organizationId': orgId.toUpperCase(),
        'orgName': orgData['name']?.toString().toLowerCase(),
        'role': _roleController.text.trim().toLowerCase(),
        'createdAt': FieldValue.serverTimestamp(),
        'profileCompleted': true,
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Sign up failed';
      if (e.code == 'email-already-in-use') {
        message = 'Email already in use';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak';
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003366),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 45),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    'Join an Organization',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Organization Autocomplete
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchOrganizations(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final organizations = snapshot.data!;

                      return Autocomplete<Map<String, dynamic>>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return organizations;
                          }
                          return organizations.where((org) {
                            final name = (org['name'] ?? '').toLowerCase();
                            final id = (org['orgId'] ?? '').toLowerCase();
                            final input = textEditingValue.text.toLowerCase();
                            return name.contains(input) || id.contains(input);
                          });
                        },
                        displayStringForOption: (org) =>
                            "${org['name']} (${org['orgId']})",
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Organization',
                              hintText: 'Search organization by name or ID',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          );
                        },
                        onSelected: (org) {
                          setState(() {
                            _orgIdController.text = org['orgId'];
                          });
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4,
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxHeight: 200),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final option = options.elementAt(index);
                                    return ListTile(
                                      title: Text(option['name']),
                                      subtitle: Text('ID: ${option['orgId']}'),
                                      onTap: () => onSelected(option),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Personal Info Fields
                  DualInputField(
                    firstController: _firstNameController,
                    secondController: _lastNameController,
                    firstLabel: 'First Name',
                    secondLabel: 'Last Name',
                    firstHint: 'e.g. John',
                    secondHint: 'e.g. Doe',
                    fillColor: Colors.grey.shade50,
                  ),
                  SmartTextField(
                    label: 'Role/Title/Position',
                    controller: _roleController,
                    hintText: 'e.g. Regional Administrator',
                  ),
                  SmartTextField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    hintText: 'e.g. 5554446666',
                    keyboardType: TextInputType.phone,
                  ),
                  SmartTextField(
                    label: 'Username',
                    controller: _usernameController,
                    hintText: 'e.g. john03',
                  ),
                  SmartTextField(
                    label: 'Email address',
                    controller: _emailController,
                    hintText: 'e.g. john.doe@gmail.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SmartTextField(
                    label: 'Password',
                    controller: _passwordController,
                    hintText: 'Must be at least 6 characters',
                    obscureText: true,
                  ),
                  SmartTextField(
                    label: 'Confirm Password',
                    controller: _confirmPasswordController,
                    hintText: 'Re-enter your password',
                    obscureText: true,
                  ),

                  const SizedBox(height: 10),

                  // Terms and Conditions Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _isTermsAccepted,
                        onChanged: (value) =>
                            setState(() => _isTermsAccepted = value ?? false),
                        fillColor: WidgetStateProperty.all(Colors.white),
                      ),
                      Expanded(
                        child: RichText(
                          text: const TextSpan(
                            text: 'I accept the ',
                            style: TextStyle(color: Colors.white),
                            children: [
                              TextSpan(
                                text: 'Terms and Conditions',
                                style: TextStyle(
                                  color: Colors.green,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  // Sign Up Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0XFF4CAF93),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),

                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      "Already have an account? Login here",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
