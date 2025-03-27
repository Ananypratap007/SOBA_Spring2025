import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddEmergencyContactScreen extends StatefulWidget {
  const AddEmergencyContactScreen({Key? key}) : super(key: key);

  @override
  State<AddEmergencyContactScreen> createState() =>
      _AddEmergencyContactScreenState();
}

class _AddEmergencyContactScreenState extends State<AddEmergencyContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _relationController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _relationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveContact() {
    if (_formKey.currentState!.validate()) {
      final contact = {
        'name': _nameController.text,
        'relation': _relationController.text,
        'phone': _phoneController.text,
      };
      context.pop(contact); // 👈 return data to previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Emergency Contact")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  EmergencyContactForm(
                    nameController: _nameController,
                    relationController: _relationController,
                    phoneController: _phoneController,
                    formKey: _formKey,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveContact,
              child: const Text("Save Contact"),
            )
          ],
        ),
      ),
    );
  }
}

// Widget for adding the Emergency Contact
class EmergencyContactForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController relationController;
  final TextEditingController phoneController;
  final GlobalKey<FormState> formKey;

  const EmergencyContactForm({
    Key? key,
    required this.nameController,
    required this.relationController,
    required this.phoneController,
    required this.formKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.grey),
    );

    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Emergency Contact Name',
              border: borderStyle,
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: relationController,
            decoration: InputDecoration(
              labelText: 'Relation',
              border: borderStyle,
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Relation is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: borderStyle,
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Phone number is required';
              }
              final phoneRegex = RegExp(r'^\+?\d{7,15}$');
              if (!phoneRegex.hasMatch(value)) {
                return 'Enter a valid phone number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
