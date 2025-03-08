import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:soba_app/checkin.dart';
import 'package:soba_app/home/home_screen.dart';
//import 'package:soba_app/main_page.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});


  @override
  State<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  bool _isPasswordObscured = true;
  bool _isRememberMeOn = false;


  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }


  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade200, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome Text
                  Text(
                    'Welcome to a 988 Service!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade300,
                    ),
                  ),
                  const SizedBox(height: 20),


                  // Username TextField
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),


                  // Password TextField
                  TextField(
                    controller: _passwordController,
                    obscureText: _isPasswordObscured,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordObscured
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _isPasswordObscured = !_isPasswordObscured;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),


                  // Remember Me Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _isRememberMeOn,
                        onChanged: (value) {
                          setState(() {
                            _isRememberMeOn = value!;
                          });
                        },
                      ),
                      const Text('Remember Me'),
                    ],
                  ),
                  const SizedBox(height: 10),


                  // Login Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 16),


                  // Social Login Buttons
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
                          print('Facebook Login');
                        },
                        icon: const FaIcon(FontAwesomeIcons.facebook,
                            color: Colors.blue, size: 30),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),


                  // Signup and Forgot Password Links
                  TextButton(
                    onPressed: () {
                      print('Navigate to Sign Up');
                    },
                    child: const Text(
                      "Don't have an account? Sign up here",
                      style: TextStyle(color: Colors.red),
                  ),
                  ),
                  TextButton(
                    onPressed: () {
                      print('Navigate to Reset Password');
                    },
                    child: const Text(
                      "Forgot your password? Reset it here",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),


                  // Help Text
                  const SizedBox(height: 10),
                  const Text(
                    "Need help? Call the 988 Hotline anytime.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


