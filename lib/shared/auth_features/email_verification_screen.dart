// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:crypto/crypto.dart';
// import 'dart:convert';

// class EmailVerificationScreen extends StatefulWidget {
//   final String email;
//   final Map<String, dynamic> userData;
//   final VoidCallback? onSignUpComplete;

//   const EmailVerificationScreen({
//     super.key,
//     required this.email,
//     required this.userData,
//     this.onSignUpComplete,
//   });

//   @override
//   State<EmailVerificationScreen> createState() =>
//       _EmailVerificationScreenState();
// }

// class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
//   final TextEditingController _codeController = TextEditingController();
//   bool _isLoading = false;
//   String? _errorText;
//   late String _verificationId;

//   @override
//   void initState() {
//     super.initState();
//     _sendVerificationEmail();
//   }

//   Future<void> _sendVerificationEmail() async {
//     setState(() => _isLoading = true);

//     // Generate 6-digit code
//     final code = _generateVerificationCode();
//     final expiresAt = DateTime.now().add(Duration(minutes: 15));

//     // Store in Firestore
//     await FirebaseFirestore.instance
//         .collection('email_verifications')
//         .doc(widget.email)
//         .set({
//       'code': code,
//       'expiresAt': expiresAt,
//       'attempts': 0,
//     });

//     // Send email using Cloud Function
//     try {
//       await FirebaseFunctions.instance
//           .httpsCallable('sendVerificationEmail')
//           .call({
//         'email': widget.email,
//         'code': code,
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to send verification email: $e')),
//       );
//     }

//     setState(() => _isLoading = false);
//   }

//   String _generateVerificationCode() {
//     final random = DateTime.now().millisecondsSinceEpoch % 1000000;
//     return random.toString().padLeft(6, '0');
//   }

//   Future<void> _verifyCode() async {
//     final enteredCode = _codeController.text.trim();
//     if (enteredCode.length != 6) {
//       setState(() => _errorText = 'Please enter a 6-digit code');
//       return;
//     }

//     setState(() => _isLoading = true);

//     final doc = await FirebaseFirestore.instance
//         .collection('email_verifications')
//         .doc(widget.email)
//         .get();

//     if (!doc.exists || doc.data()?['code'] != enteredCode) {
//       setState(() {
//         _errorText = 'Invalid verification code';
//         _isLoading = false;
//       });
//       return;
//     }

//     if (DateTime.now()
//         .isAfter((doc.data()?['expiresAt'] as Timestamp).toDate())) {
//       setState(() {
//         _errorText = 'Code has expired';
//         _isLoading = false;
//       });
//       return;
//     }

//     // Code is valid - create user
//     try {
//       final credential =
//           await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: widget.userData['email'],
//         password: widget.userData['password'],
//       );

//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(credential.user!.uid)
//           .set({
//         ...widget.userData,
//         'emailVerified': true,
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       if (widget.onSignUpComplete != null) {
//         widget.onSignUpComplete!();
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Account creation failed: $e')),
//       );
//     }

//     setState(() => _isLoading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Verify Email')),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           children: [
//             Text(
//               'We sent a 6-digit code to ${widget.email}',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _codeController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 labelText: 'Verification Code',
//                 errorText: _errorText,
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _isLoading ? null : _verifyCode,
//               child: _isLoading
//                   ? const CircularProgressIndicator()
//                   : const Text('Verify Code'),
//             ),
//             TextButton(
//               onPressed: _isLoading ? null : _sendVerificationEmail,
//               child: const Text('Resend Code'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
