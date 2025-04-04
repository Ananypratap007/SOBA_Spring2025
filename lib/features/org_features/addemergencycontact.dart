import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

class AddEmergencyContactScreen extends StatefulWidget {
  final Map<String, String>? contact;
  final int? index;

  const AddEmergencyContactScreen({super.key, this.contact, this.index});

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

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      _nameController.text = widget.contact!['name'] ?? '';
      _relationController.text = widget.contact!['relation'] ?? '';
      _phoneController.text = widget.contact!['phone'] ?? '';
    }
  }

  void _saveContact() {
    if (_formKey.currentState!.validate()) {
      final contact = {
        'name': _nameController.text,
        'relation': _relationController.text,
        'phone': _phoneController.text,
      };

      final box = Hive.box('emergencyContacts');
      if (widget.index != null) {
        box.putAt(widget.index!, contact);
      } else {
        box.add(contact);
      }
      context.pop();
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
    super.key,
    required this.nameController,
    required this.relationController,
    required this.phoneController,
    required this.formKey,
  });

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
