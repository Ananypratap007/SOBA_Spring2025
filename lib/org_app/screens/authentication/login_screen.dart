import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:soba_app/config/firebase_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soba_app/org_app/screens/authentication/choose-signup.dart';
import 'package:soba_app/org_app/screens/bottom_navigation/home.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key, this.onLoggedIn});

//   final VoidCallback? onLoggedIn;
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   late final TextEditingController _emailController;
//   late final TextEditingController _passwordController;
//   bool _isPasswordObscured = true;
//   bool _isRememberMeOn = false;
//   bool _isLoading = false;
//   bool _biometricSupported = false;
//   bool _biometricEnabled = false;
//   final LocalAuthentication _localAuth = LocalAuthentication();
//   final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
//   late SharedPreferences _prefs;

//   @override
//   void initState() {
//     super.initState();
//     _emailController = TextEditingController();
//     _passwordController = TextEditingController();
//     _initializeAuth();
//   }

//   Future<void> _initializeAuth() async {
//     _prefs = await SharedPreferences.getInstance();
//     await _checkRememberMeStatus();
//     await _checkBiometricSupport();

//     if (_biometricEnabled) {
//       await _authenticateWithBiometrics();
//     }
//   }

//   Future<void> _checkBiometricSupport() async {
//     try {
//       final bool canAuthenticate = await _localAuth.canCheckBiometrics ||
//           await _localAuth.isDeviceSupported();
//       final List<BiometricType> availableBiometrics =
//           await _localAuth.getAvailableBiometrics();

//       setState(() {
//         _biometricSupported = canAuthenticate && availableBiometrics.isNotEmpty;
//         _biometricEnabled = _prefs.getBool('biometric_enabled') ?? false;
//       });
//     } catch (e) {
//       print('Error checking biometrics: $e');
//     }
//   }

//   Future<void> _authenticateWithBiometrics() async {
//     try {
//       final bool didAuthenticate = await _localAuth.authenticate(
//         localizedReason: 'Authenticate to login to your account',
//         options: const AuthenticationOptions(
//           biometricOnly: true,
//           useErrorDialogs: true,
//           stickyAuth: true,
//         ),
//       );

//       if (didAuthenticate) {
//         final email = await _secureStorage.read(key: 'biometric_email');
//         final password = await _secureStorage.read(key: 'biometric_password');

//         if (email != null && password != null) {
//           _emailController.text = email;
//           _passwordController.text = password;
//           await _handleLogin();
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Biometric authentication failed: $e')),
//         );
//       }
//     }
//   }

//   Future<void> _checkRememberMeStatus() async {
//     setState(() {
//       _isRememberMeOn = _prefs.getBool('remember_me') ?? false;
//     });

//     if (_isRememberMeOn) {
//       final email = await _secureStorage.read(key: 'remembered_email');
//       if (email != null && mounted) {
//         _emailController.text = email;
//       }
//     }
//   }

//   Future<void> _handleLogin() async {
//     if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please fill in all fields')),
//         );
//       }
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       await FirebaseConfig.auth.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text,
//       );

//       final user = FirebaseConfig.auth.currentUser;
//       if (user != null) {
//         await FirebaseConfig.firestore
//             .collection('users')
//             .doc(user.uid)
//             .update({
//           'lastLogin': FieldValue.serverTimestamp(),
//         });

//         await _prefs.setBool('remember_me', _isRememberMeOn);

//         if (_isRememberMeOn) {
//           await _secureStorage.write(
//             key: 'remembered_email',
//             value: _emailController.text.trim(),
//           );
//         } else {
//           await _secureStorage.delete(key: 'remembered_email');
//         }

//         if (_biometricEnabled) {
//           await _secureStorage.write(
//             key: 'biometric_email',
//             value: _emailController.text.trim(),
//           );
//           await _secureStorage.write(
//             key: 'biometric_password',
//             value: _passwordController.text,
//           );
//         }
//       }

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Login successful!')),
//         );
//         widget.onLoggedIn?.call();
//       }
//     } on FirebaseAuthException catch (e) {
//       String message = 'An error occurred during login';
//       if (e.code == 'user-not-found') {
//         message = 'No user found with this email.';
//       } else if (e.code == 'wrong-password') {
//         message = 'Wrong password provided.';
//       } else if (e.code == 'invalid-email') {
//         message = 'The email address is invalid.';
//       }
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(message)),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: ${e.toString()}')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _toggleBiometricAuth(bool value) async {
//     try {
//       if (value) {
//         final bool didAuthenticate = await _localAuth.authenticate(
//           localizedReason: 'Authenticate to enable biometric login',
//           options: const AuthenticationOptions(
//             biometricOnly: true,
//             useErrorDialogs: true,
//             stickyAuth: true,
//           ),
//         );

//         if (didAuthenticate && mounted) {
//           await _prefs.setBool('biometric_enabled', true);
//           await _secureStorage.write(
//             key: 'biometric_email',
//             value: _emailController.text.trim(),
//           );
//           await _secureStorage.write(
//             key: 'biometric_password',
//             value: _passwordController.text,
//           );
//           setState(() {
//             _biometricEnabled = true;
//           });
//         }
//       } else {
//         await _prefs.setBool('biometric_enabled', false);
//         await _secureStorage.delete(key: 'biometric_email');
//         await _secureStorage.delete(key: 'biometric_password');
//         setState(() {
//           _biometricEnabled = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Biometric error: ${e.toString()}')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(color: Color(0XFF4CAF93)),
//         child: Column(children: [
//           Expanded(
//             child: Center(
//               child: Text(
//                 'Welcome to Back',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 35,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   shadows: [
//                     Shadow(
//                       blurRadius: 4,
//                       color: Colors.black54,
//                       offset: Offset(1, 1),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Container(
//             width: double.infinity,
//             constraints: BoxConstraints(
//               maxHeight: MediaQuery.of(context).size.height * 0.8,
//             ),
//             padding: const EdgeInsets.all(32),
//             decoration: BoxDecoration(
//               color: Color(0xFF003366),
//               borderRadius: BorderRadius.vertical(top: Radius.circular(65)),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black26,
//                   blurRadius: 10,
//                   spreadRadius: 2,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Text(
//                     'Sign In',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   TextField(
//                     controller: _emailController,
//                     keyboardType: TextInputType.emailAddress,
//                     decoration: InputDecoration(
//                       labelText: 'Email',
//                       filled: true,
//                       fillColor: Colors.white,
//                       isDense: true,
//                       contentPadding:
//                           EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16),
//                         borderSide: BorderSide(color: Colors.blue.shade300),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 12),
//                   TextField(
//                     controller: _passwordController,
//                     obscureText: _isPasswordObscured,
//                     decoration: InputDecoration(
//                       labelText: 'Password',
//                       filled: true,
//                       fillColor: Colors.white,
//                       isDense: true,
//                       contentPadding:
//                           EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16),
//                         borderSide: BorderSide(color: Colors.grey.shade300),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16),
//                         borderSide:
//                             BorderSide(color: Colors.blue.shade300, width: 2),
//                       ),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _isPasswordObscured
//                               ? Icons.visibility_off
//                               : Icons.visibility,
//                           color: Colors.grey.shade600,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             _isPasswordObscured = !_isPasswordObscured;
//                           });
//                         },
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Checkbox(
//                         value: _isRememberMeOn,
//                         onChanged: (value) {
//                           setState(() {
//                             _isRememberMeOn = value ?? false;
//                           });
//                         },
//                       ),
//                       Text('Remember me',
//                           style: TextStyle(color: Colors.white)),
//                     ],
//                   ),
//                   if (_biometricSupported) ...[
//                     Row(
//                       children: [
//                         Checkbox(
//                           value: _biometricEnabled,
//                           onChanged: _biometricEnabled
//                               ? null
//                               : (value) => _toggleBiometricAuth(value ?? false),
//                         ),
//                         Text('Enable Biometric Login',
//                             style: TextStyle(color: Colors.white)),
//                         if (_biometricEnabled) ...[
//                           const Spacer(),
//                           Switch(
//                             value: _biometricEnabled,
//                             onChanged: _toggleBiometricAuth,
//                           ),
//                         ],
//                       ],
//                     ),
//                   ],
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: _isLoading ? null : _handleLogin,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0XFF4CAF93),
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                     ),
//                     child: _isLoading
//                         ? const SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor:
//                                   AlwaysStoppedAnimation<Color>(Colors.white),
//                             ),
//                           )
//                         : const Text(
//                             'Login',
//                             style: TextStyle(fontSize: 22, color: Colors.white),
//                           ),
//                   ),
//                   if (_biometricEnabled) ...[
//                     const SizedBox(height: 16),
//                     ElevatedButton.icon(
//                       onPressed: _authenticateWithBiometrics,
//                       icon: Icon(Icons.fingerprint),
//                       label: Text('Sign in with Biometrics'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blueGrey,
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                       ),
//                     ),
//                   ],
//                   const SizedBox(height: 16),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       IconButton(
//                         onPressed: () {
//                           print('Google Login');
//                         },
//                         icon: const FaIcon(FontAwesomeIcons.google,
//                             color: Colors.red, size: 30),
//                       ),
//                       const SizedBox(width: 20),
//                       IconButton(
//                         onPressed: () {
//                           print('Apple Login');
//                         },
//                         icon: const FaIcon(FontAwesomeIcons.apple,
//                             color: Colors.black, size: 30),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => ChooseSignUpPage()),
//                       );
//                     },
//                     child: const Text(
//                       "Don't have an account? Sign up here",
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       print('Navigate to Reset Password');
//                     },
//                     child: const Text(
//                       "Forgot your password? Reset it here",
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   const Text(
//                     "Need help? Call the 988 Hotline anytime.",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(color: Color(0XFF4CAF93)),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ]),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:soba_app/config/firebase_config.dart';
// import 'package:soba_app/firebase_config.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.onLoggedIn});

  final VoidCallback? onLoggedIn;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _isPasswordObscured = true;
  bool _isRememberMeOn = false;
  bool _isLoading = false;
  bool _biometricSupported = false;
  bool _biometricEnabled = false;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _prefs = await SharedPreferences.getInstance();
    await _checkRememberMeStatus();
    await _checkBiometricSupport();
    if (_biometricEnabled) {
      _authenticateWithBiometrics();
    }
  }

  Future<void> _checkBiometricSupport() async {
    try {
      final bool canAuthenticate = await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();

      setState(() {
        _biometricSupported = canAuthenticate && availableBiometrics.isNotEmpty;
        _biometricEnabled = _prefs.getBool('biometric_enabled') ?? false;
      });
    } catch (e) {
      print('Error checking biometrics: $e');
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate to login to your account',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        final email = await _secureStorage.read(key: 'biometric_email');
        final password = await _secureStorage.read(key: 'biometric_password');

        if (email != null && password != null) {
          _emailController.text = email;
          _passwordController.text = password;
          await _handleLogin();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Biometric authentication failed: $e')),
        );
      }
    }
  }

  Future<void> _checkRememberMeStatus() async {
    setState(() {
      _isRememberMeOn = _prefs.getBool('remember_me') ?? false;
    });

    if (_isRememberMeOn) {
      final email = await _secureStorage.read(key: 'remembered_email');
      if (email != null && mounted) {
        _emailController.text = email;
      }
    }
  }

  Future<void> _toggleBiometricAuth(bool value) async {
    try {
      if (value) {
        final bool didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Authenticate to enable biometric login',
          options: const AuthenticationOptions(
            biometricOnly: true,
            useErrorDialogs: true,
            stickyAuth: true,
          ),
        );

        if (didAuthenticate && mounted) {
          await _prefs.setBool('biometric_enabled', true);
          await _secureStorage.write(
            key: 'biometric_email',
            value: _emailController.text.trim(),
          );
          await _secureStorage.write(
            key: 'biometric_password',
            value: _passwordController.text,
          );
          setState(() {
            _biometricEnabled = true;
          });
        }
      } else {
        await _prefs.setBool('biometric_enabled', false);
        await _secureStorage.delete(key: 'biometric_email');
        await _secureStorage.delete(key: 'biometric_password');
        setState(() {
          _biometricEnabled = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Biometric error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseConfig.auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = FirebaseConfig.auth.currentUser;
      if (user != null) {
        await FirebaseConfig.firestore
            .collection('users')
            .doc(user.uid)
            .update({
          'lastLogin': FieldValue.serverTimestamp(),
        });

        await _prefs.setBool('remember_me', _isRememberMeOn);

        if (_isRememberMeOn) {
          await _secureStorage.write(
            key: 'remembered_email',
            value: _emailController.text.trim(),
          );
        } else {
          await _secureStorage.delete(key: 'remembered_email');
        }

        if (_biometricEnabled) {
          await _secureStorage.write(
            key: 'biometric_email',
            value: _emailController.text.trim(),
          );
          await _secureStorage.write(
            key: 'biometric_password',
            value: _passwordController.text,
          );
        }
      }

      if (mounted) {
        // 1) Show the SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );

        // 2) Navigate (or do whatever else you want) right after
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );

        // 3) If you have a callback to notify, call it too
        widget.onLoggedIn?.call();
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred during login';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is invalid.';
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
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Color(0XFF4CAF93)),
        child: Column(children: [
          Expanded(
            child: Center(
              child: Text(
                'Welcome to Back',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 35,
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
            ),
          ),
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Color(0xFF003366),
              borderRadius: BorderRadius.vertical(top: Radius.circular(65)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Sign In',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            BorderSide(color: Colors.grey), // Default border
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            BorderSide(color: Colors.blue.shade300, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: _isPasswordObscured,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                              color: Colors.blue.shade300, width: 2)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordObscured
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordObscured = !_isPasswordObscured;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: _isRememberMeOn,
                        onChanged: (value) {
                          setState(() {
                            _isRememberMeOn = value ?? false;
                          });
                        },
                      ),
                      Text('Remember me',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  if (_biometricSupported) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.fingerprint, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text('Biometric Login',
                            style: TextStyle(color: Colors.white)),
                        const Spacer(),
                        Switch(
                          value: _biometricEnabled,
                          onChanged: (value) async {
                            if (value) {
                              if (_emailController.text.isEmpty ||
                                  _passwordController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Please login first to enable biometric'),
                                  ),
                                );
                                return;
                              }
                            }
                            await _toggleBiometricAuth(value);
                          },
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0XFF4CAF93),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
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
                            'Login',
                            style: TextStyle(fontSize: 22, color: Colors.white),
                          ),
                  ),
                  if (_biometricEnabled) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _authenticateWithBiometrics,
                      icon: Icon(Icons.fingerprint),
                      label: Text('Sign in with Biometrics'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          print('Google Login');
                        },
                        icon: const FaIcon(FontAwesomeIcons.google,
                            color: Colors.red, size: 30),
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        onPressed: () {
                          print('Apple Login');
                        },
                        icon: const FaIcon(FontAwesomeIcons.apple,
                            color: Colors.black, size: 30),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChooseSignUpPage()),
                      );
                    },
                    child: const Text(
                      "Don't have an account? Sign up here",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      print('Navigate to Reset Password');
                    },
                    child: const Text(
                      "Forgot your password? Reset it here",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Need help? Call the 988 Hotline anytime.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0XFF4CAF93)),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
