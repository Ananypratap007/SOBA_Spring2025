import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEmergencyContactScreen extends StatefulWidget {
  final Map<String, dynamic>? contact;
  final int? index;

  const AddEmergencyContactScreen({Key? key, this.contact, this.index})
      : super(key: key);

  @override
  State<AddEmergencyContactScreen> createState() =>
      _AddEmergencyContactScreenState();
}

class _AddEmergencyContactScreenState extends State<AddEmergencyContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _relationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

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

  Future<void> _saveContact() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = _auth.currentUser;
        if (user == null) return;

        final contact = {
          'name': _nameController.text,
          'relation': _relationController.text,
          'phone': _phoneController.text,
        };

        final userRef = _firestore.collection('users').doc(user.uid);

        if (widget.index != null) {
          // ======== START OF MODIFIED CODE ========
          // Get fresh data to avoid stale indices
          final doc = await userRef.get();
          final contacts = List<Map<String, dynamic>>.from(
              doc.data()?['emergencyContacts'] ?? []);

          if (widget.index! < contacts.length) {
            // Create new list to trigger Firestore update
            final updatedContacts = List<Map<String, dynamic>>.from(contacts);
            updatedContacts[widget.index!] = contact;
            await userRef.update({'emergencyContacts': updatedContacts});
          }
          // ======== END OF MODIFIED CODE ========
        } else {
          // Add new contact
          await userRef.update({
            'emergencyContacts': FieldValue.arrayUnion([contact])
          });
        }

        if (mounted) context.pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving contact: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Emergency Contact")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            EmergencyContactForm(
              nameController: _nameController,
              relationController: _relationController,
              phoneController: _phoneController,
              formKey: _formKey,
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

// Add this widget class in the same file or import it from its location
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
    final borderStyle = OutlineInputBorder(
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
