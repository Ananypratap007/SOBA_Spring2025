import 'package:flutter/material.dart';

import 'main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isRememberMeOn = false;
  bool _isPasswordObscured = false;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      padding: const EdgeInsets.all(64),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome to a 988 Service!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              color: Color(0xFFFF6F61),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              labelText: 'Username',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  obscureText: _isPasswordObscured,
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isPasswordObscured = !_isPasswordObscured;
                  });
                },
                icon: Icon(_isPasswordObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _isRememberMeOn,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _isRememberMeOn = value;
                    });
                  }
                },
              ),
              const Text('Remember Me'),
            ],
          ),
          const SizedBox(height: 16),
          MaterialButton(
            onPressed: () {
              print('do login');
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => MainPage()));
            },
            color: const Color(0xFFFF6F61),
            textColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
