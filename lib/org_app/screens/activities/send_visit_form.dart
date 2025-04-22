import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:go_router/go_router.dart';

class ClientFormScreen extends StatefulWidget {
  const ClientFormScreen({super.key});

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedRisk;
  Map<String, String>? _selectedResponder;
  String? _selectedUrgency;

  final List<Map<String, dynamic>> riskLevels = [
    {"label": "Safe", "color": Colors.green},
    {"label": "Unstable", "color": Colors.orange},
    {"label": "Dangerous", "color": Colors.red},
  ];

  final List<Map<String, dynamic>> urgencyLevels = [
    {"label": "Low", "color": Colors.green, "icon": Icons.check_circle},
    {"label": "Medium", "color": Colors.amber, "icon": Icons.warning},
    {"label": "High", "color": Colors.orange, "icon": Icons.error},
    {"label": "Critical", "color": Colors.red, "icon": Icons.priority_high},
  ];

  final List<Map<String, dynamic>> responders = [
    {"name": "Margaret LaRosa"},
    {"name": "Kiki Nates"},
    {"name": "Jackie Chan-Lee"},
    {"name": "Abraham Monroe"},
  ];

  List<Map<String, String>> _adminResponders = [];

  @override
  void initState() {
    super.initState();
    _loadAdminResponders();
  }

  Future<void> _loadAdminResponders() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
    if (userDoc.exists && userDoc.data() != null) {
      final userData = userDoc.data()!;
      final activeOrg = userData['orgId'] ?? userData['organizationId'];
      if (activeOrg != null) {
        final query1 = await FirebaseFirestore.instance
            .collection('users')
            .where('orgId', isEqualTo: activeOrg)
            .get();
        final query2 = await FirebaseFirestore.instance
            .collection('users')
            .where('organizationId', isEqualTo: activeOrg)
            .get();
        final docs = [...query1.docs, ...query2.docs];
        final uniqueDocs = {
          for (var doc in docs)
            if (doc.id != currentUser.uid) doc.id: doc
        }.values.toList();
        setState(() {
          _adminResponders = uniqueDocs.map<Map<String, String>>((doc) {
            final data = doc.data();
            return {
              'uid': doc.id,
              'name': data['name'] as String,
            };
          }).toList();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedUrgencyColor = urgencyLevels.firstWhere(
      (u) => u['label'] == _selectedUrgency,
      orElse: () => {'color': Colors.grey[300]},
    )['color'];

    return Scaffold(
      backgroundColor: const Color(0xFF003366),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 55),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Client Information Form",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const Spacer(),
                SizedBox(
                  width: 240,
                  child: DropdownButtonFormField<Map<String, String>>(
                    value: _adminResponders.contains(_selectedResponder) ? _selectedResponder : null,
                    isExpanded: true,
                    decoration: _dropdownDecoration("Select Responder"),
                    hint: const Text("Select Responder"),
                    items: _adminResponders.map((responder) {
                      return DropdownMenuItem<Map<String, String>>(
                        value: responder,
                        child: Row(
                          children: [
                            const SizedBox(width: 6),
                            Text(responder['name']!),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedResponder = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            CustomTextField(
              controller: _nameController,
              label: "Client Name",
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _genderController,
                    label: 'Gender',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomTextField(
                    controller: _ageController,
                    label: 'Age',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: riskLevels.any((r) => r["label"] == _selectedRisk)
                        ? _selectedRisk
                        : null,
                    decoration: _dropdownDecoration("Risk"),
                    items: riskLevels.map((risk) {
                      return DropdownMenuItem<String>(
                        value: risk["label"],
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 6,
                              backgroundColor: risk["color"],
                            ),
                            const SizedBox(width: 8),
                            Text(risk["label"]),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedRisk = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _addressController,
              label: 'Address',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _cityController,
                    label: 'City/Town',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomTextField(
                    controller: _stateController,
                    label: 'State',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Client & Visit Description",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                const Spacer(),
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField<String>(
                    value:
                        urgencyLevels.any((u) => u["label"] == _selectedUrgency)
                            ? _selectedUrgency
                            : null,
                    isExpanded: true,
                    decoration: _dropdownDecoration("Urgency Level"),
                    hint: const Text("Urgency Level"),
                    items: urgencyLevels.map((urgency) {
                      return DropdownMenuItem<String>(
                        value: urgency["label"],
                        child: Row(
                          children: [
                            Icon(urgency["icon"],
                                color: urgency["color"], size: 18),
                            const SizedBox(width: 6),
                            Text(urgency["label"]),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedUrgency = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 12,
              decoration: _inputDecoration(""),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _nameController.clear();
                      _genderController.clear();
                      _ageController.clear();
                      _addressController.clear();
                      _cityController.clear();
                      _stateController.clear();
                      _notesController.clear();
                      setState(() {
                        _selectedRisk = null;
                        _selectedUrgency = null;
                        _selectedResponder = null;
                      });
                      context.go('/');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Build a job/visit map from the form fields:
                      final jobData = {
                        'clientName': _nameController.text.trim(),
                        'gender': _genderController.text.trim(),
                        'age': _ageController.text.trim(),
                        'risk': _selectedRisk,
                        'address': _addressController.text.trim(),
                        'city': _cityController.text.trim(),
                        'state': _stateController.text.trim(),
                        'urgency': _selectedUrgency,
                        'description': _notesController.text.trim(),
                        // Use responderId and responderName (if _selectedResponder is not null)
                        'responderId': _selectedResponder?['uid'],
                        'responder': _selectedResponder?['name'],
                        'createdAt': DateTime.now(),
                        'status': 'pending',
                      };

                      // Save the document in Firestore (in a "visits" or "jobs" collection)
                      await FirebaseFirestore.instance.collection('visits').add(jobData);

                      // Optionally show a confirmation dialog.
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text('Success'),
                          content: const Text('Your request has been sent successfully!'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close dialog
                                context.go('/'); // Navigate to home page
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: const Text(
                      "Send",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white, width: 2),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white, width: 2),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}
