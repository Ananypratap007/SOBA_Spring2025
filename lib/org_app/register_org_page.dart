import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class OrganizationRegistration extends StatefulWidget {
  const OrganizationRegistration({super.key});

  @override
  State<OrganizationRegistration> createState() =>
      _OrganizationRegistrationState();
}

class _OrganizationRegistrationState extends State<OrganizationRegistration> {
  final _formKey = GlobalKey<FormState>();
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;

  // Controllers
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _orgEmailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
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
          'members': [],
          'adminId': ''
        });

        final userCredential = await _auth.createUserWithEmailAndPassword(
            email: _emailController.text, password: _passwordController.text);

        await _firestore
            .collection("org_users")
            .doc(userCredential.user!.uid)
            .set({
          'uid': userCredential.user!.uid,
          'name': _nameController.text,
          'email': _emailController.text,
          'title': _titleController.text,
          'phone': _phoneController.text,
          'role': 'admin',
          'organizationId': orgId,
          'createdAt': FieldValue.serverTimestamp(),
          'fcmToken': '',
        });

        await orgRef.update({
          'adminId': userCredential.user!.uid,
          'members': FieldValue.arrayUnion([userCredential.user!.uid])
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful!")),
        );

        // Navigate to the dashboard or home page
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Your Organization'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Administrator Information'),
              _buildTextField('Name',
                  controller: _nameController, validator: _validateRequired),
              _buildTextField('Email',
                  controller: _emailController, validator: _validateEmail),
              _buildPasswordField('Password', controller: _passwordController),
              _buildPasswordField('Confirm Password',
                  controller: _confirmPasswordController, isConfirm: true),
              _buildTextField('Title', controller: _titleController),
              _buildTextField('Phone Number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 5),
              _buildSectionHeader('Organization Information'),
              _buildTextField('Organization Name',
                  controller: _orgNameController),
              _buildTextField('Organization Email',
                  controller: _orgEmailController, validator: _validateEmail),
              _buildTextField('Address', controller: _addressController),
              _buildTextField('City', controller: _cityController),
              _buildTextField('State', controller: _stateController),
              _buildTextField('ZIP',
                  controller: _zipController,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Register'),
                ),
              ),
              _buildSignInLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        ),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordField(
    String label, {
    bool isConfirm = false,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        ),
        validator: (value) => isConfirm
            ? _validatePasswordMatch(value)
            : _validatePassword(value),
      ),
    );
  }

  Widget _buildSignInLink() {
    return Center(
      child: TextButton(
        onPressed: () {
          // Add navigation to sign in screen
        },
        child: const Text.rich(
          TextSpan(
            text: 'Already have an account? ',
            children: [
              TextSpan(
                text: 'Sign in',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  String? _validatePasswordMatch(String? value) {
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }
}
