import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:soba_app/org_app/screens/authentication/signup_screen1.dart';
import 'package:soba_app/org_app/screens/authentication/join_sign_up.dart';

class ChooseSignUpPage extends StatefulWidget {
  const ChooseSignUpPage({super.key, this.onSignUpComplete});

  final VoidCallback? onSignUpComplete;

  @override
  State<ChooseSignUpPage> createState() => _ChooseSignUpPageState();
}

class _ChooseSignUpPageState extends State<ChooseSignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF003366),
      appBar: AppBar(
        title: const Text(
          'Create Your Account',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF003366),
        flexibleSpace: SafeArea(
          child: Container(
            color: const Color(0xFF003366),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const Text(
              'How would you like to get started?',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(
                FontAwesomeIcons.building,
                color: Color(0XFF4CAF93),
              ),
              label: const Text(
                'Join an Existing Organization',
                style: TextStyle(color: Color(0XFF4CAF93)),
              ),
              onPressed: () {
                // Navigate to the create new organization flow
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JoinOrganizationScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use an Organization ID or search in your region.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Divider(
              height: 1,
              thickness: 2,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(
                FontAwesomeIcons.plus,
                color: Color(0XFF4CAF93),
              ),
              label: const Text(
                'Create a New Organization',
                style: TextStyle(color: Color(0XFF4CAF93)),
              ),
              onPressed: () {
                // Navigate to the create new organization flow
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const OrganizationCreatorSignUpScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Register as root administrator and set up your organization.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            const Spacer(),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Back to Sign In',
                  style: TextStyle(color: Color(0XFF4CAF93)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
