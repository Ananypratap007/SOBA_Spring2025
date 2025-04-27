// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:go_router/go_router.dart';

// class ScheduleVisitScreen extends StatefulWidget {
//   const ScheduleVisitScreen({super.key});

//   @override
//   State<ScheduleVisitScreen> createState() => _ScheduleVisitScreenState();
// }

// class _ScheduleVisitScreenState extends State<ScheduleVisitScreen> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _genderController = TextEditingController();
//   final TextEditingController _ageController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _stateController = TextEditingController();
//   final TextEditingController _notesController = TextEditingController();

//   DateTime? _selectedDate;
//   TimeOfDay? _selectedTime;

//   String? _selectedRisk;
//   Map<String, String>? _selectedResponder;
//   String? _selectedUrgency;

//   List<Map<String, String>> _adminResponders = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadAdminResponders();
//   }

//   Future<void> _loadAdminResponders() async {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;

//     final userDoc = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(currentUser.uid)
//         .get();
//     final userData = userDoc.data();
//     final activeOrg = userData?['orgId'] ?? userData?['organizationId'];
//     if (activeOrg == null) return;

//     final query1 = await FirebaseFirestore.instance
//         .collection('users')
//         .where('orgId', isEqualTo: activeOrg)
//         .get();
//     final query2 = await FirebaseFirestore.instance
//         .collection('users')
//         .where('organizationId', isEqualTo: activeOrg)
//         .get();

//     final docs = {...query1.docs, ...query2.docs};

//     setState(() {
//       _adminResponders =
//           docs.where((doc) => doc.id != currentUser.uid).map((doc) {
//         final data = doc.data();
//         return {
//           'uid': doc.id,
//           'name': (data['name'] ?? 'Unnamed') as String,
//         };
//       }).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF003366),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 55),
//             _buildHeader(),
//             const SizedBox(height: 15),
//             CustomTextField(controller: _nameController, label: "Client Name"),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                     child: CustomTextField(
//                         controller: _genderController, label: 'Gender')),
//                 const SizedBox(width: 10),
//                 Expanded(
//                     child: CustomTextField(
//                         controller: _ageController, label: 'Age')),
//               ],
//             ),
//             const SizedBox(height: 16),
//             CustomTextField(controller: _addressController, label: 'Address'),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                     child: CustomTextField(
//                         controller: _cityController, label: 'City/Town')),
//                 const SizedBox(width: 10),
//                 Expanded(
//                     child: CustomTextField(
//                         controller: _stateController, label: 'State')),
//               ],
//             ),
//             const SizedBox(height: 16),
//             _buildDropdowns(),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _notesController,
//               maxLines: 8,
//               decoration: _inputDecoration("Additional Notes"),
//             ),
//             const SizedBox(height: 16),
//             _buildDateTimePickers(),
//             const SizedBox(height: 20),
//             _buildActionButtons(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text("Client Information Form",
//             style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white)),
//         const SizedBox(height: 10),
//         DropdownButtonFormField<Map<String, String>>(
//           value: _selectedResponder,
//           isExpanded: true,
//           decoration: _dropdownDecoration("Select Responder"),
//           items: _adminResponders.map((responder) {
//             return DropdownMenuItem<Map<String, String>>(
//               value: responder,
//               child: Text(responder['name']!),
//             );
//           }).toList(),
//           onChanged: (value) => setState(() => _selectedResponder = value),
//         ),
//       ],
//     );
//   }

//   Widget _buildDropdowns() {
//     return Row(
//       children: [
//         Expanded(
//           child: DropdownButtonFormField<String>(
//             value: _selectedRisk,
//             isExpanded: true,
//             decoration: _dropdownDecoration("Risk Level"),
//             items: ['Safe', 'Unstable', 'Dangerous'].map((risk) {
//               return DropdownMenuItem(value: risk, child: Text(risk));
//             }).toList(),
//             onChanged: (value) => setState(() => _selectedRisk = value),
//           ),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: DropdownButtonFormField<String>(
//             value: _selectedUrgency,
//             isExpanded: true,
//             decoration: _dropdownDecoration("Urgency"),
//             items: ['Low', 'Medium', 'High', 'Critical'].map((urgency) {
//               return DropdownMenuItem(value: urgency, child: Text(urgency));
//             }).toList(),
//             onChanged: (value) => setState(() => _selectedUrgency = value),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDateTimePickers() {
//     return Row(
//       children: [
//         Expanded(
//           child: GestureDetector(
//             onTap: _pickDate,
//             child: AbsorbPointer(
//               child: TextField(
//                 decoration: _inputDecoration(_selectedDate == null
//                     ? "Select Date"
//                     : "${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}"),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: GestureDetector(
//             onTap: _pickTime,
//             child: AbsorbPointer(
//               child: TextField(
//                 decoration: _inputDecoration(_selectedTime == null
//                     ? "Select Time"
//                     : _selectedTime!.format(context)),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildActionButtons() {
//     return Row(
//       children: [
//         Expanded(
//           child: ElevatedButton(
//             onPressed: _clearForm,
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text("Cancel"),
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: ElevatedButton(
//             onPressed: _submitForm,
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//             child: const Text("Schedule Visit"),
//           ),
//         ),
//       ],
//     );
//   }

//   Future<void> _pickDate() async {
//     final date = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2100),
//     );
//     if (date != null) {
//       setState(() => _selectedDate = date);
//     }
//   }

//   Future<void> _pickTime() async {
//     final time = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (time != null) {
//       setState(() => _selectedTime = time);
//     }
//   }

// // In ScheduleVisitScreen's _submitForm method:

//   Future<void> _submitForm() async {
//     if (_selectedDate == null || _selectedTime == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please select both date and time.')));
//       return;
//     }

//     final scheduledDateTime = DateTime(
//       _selectedDate!.year,
//       _selectedDate!.month,
//       _selectedDate!.day,
//       _selectedTime!.hour,
//       _selectedTime!.minute,
//     );

//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;

//     final userDoc = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(currentUser.uid)
//         .get();
//     final userData = userDoc.data();
//     final String? orgId = userData?['orgId'] ?? userData?['organizationId'];

//     final visitData = {
//       'clientName': _nameController.text.trim(),
//       'gender': _genderController.text.trim(),
//       'age': _ageController.text.trim(),
//       'risk': _selectedRisk,
//       'address': _addressController.text.trim(),
//       'city': _cityController.text.trim(),
//       'state': _stateController.text.trim(),
//       'urgency': _selectedUrgency,
//       'description': _notesController.text.trim(),
//       'responderId': _selectedResponder?['uid'],
//       'responder': _selectedResponder?['name'],
//       'scheduledDateTime': Timestamp.fromDate(scheduledDateTime),
//       'createdAt': FieldValue.serverTimestamp(),
//       'status': 'pending', // Changed from 'inactive' to match ClientFormScreen
//       'orgId': orgId,
//     };

//     try {
//       final visitRef =
//           await FirebaseFirestore.instance.collection('visits').add(visitData);

//       // Add to activity logs
//       await FirebaseFirestore.instance.collection('activity_logs').add({
//         'timestamp': FieldValue.serverTimestamp(),
//         'visitId': visitRef.id,
//         'orgId': orgId,
//         'userId': _selectedResponder?['uid'],
//         'userName': _selectedResponder?['name'],
//         'type': 'Visit Scheduled',
//         'details':
//             '${_selectedResponder?['name']} scheduled for ${_formatDateTime(scheduledDateTime)}',
//         'status': 'pending',
//       });

//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => AlertDialog(
//           title: const Text('Success'),
//           content: const Text('Visit scheduled successfully!'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close dialog
//                 context.go('/'); // Navigate to home
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error scheduling visit: ${e.toString()}')),
//       );
//     }
//   }

//   String _formatDateTime(DateTime dateTime) {
//     final time = TimeOfDay.fromDateTime(dateTime).format(context);
//     return "${dateTime.month}/${dateTime.day}/${dateTime.year} at $time";
//   }

//   void _clearForm() {
//     _nameController.clear();
//     _genderController.clear();
//     _ageController.clear();
//     _addressController.clear();
//     _cityController.clear();
//     _stateController.clear();
//     _notesController.clear();
//     context.go("/");
//     setState(() {
//       _selectedRisk = null;
//       _selectedUrgency = null;
//       _selectedResponder = null;
//       _selectedDate = null;
//       _selectedTime = null;
//     });
//   }

//   InputDecoration _inputDecoration(String label) => InputDecoration(
//         labelText: label,
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//       );

//   InputDecoration _dropdownDecoration(String label) => InputDecoration(
//         labelText: label,
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//       );
// }

// class CustomTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;

//   const CustomTextField(
//       {super.key, required this.controller, required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       style: const TextStyle(color: Colors.black),
//       decoration: InputDecoration(
//         labelText: label,
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScheduleVisitScreen extends StatefulWidget {
  const ScheduleVisitScreen({super.key});

  @override
  State<ScheduleVisitScreen> createState() => _ScheduleVisitScreenState();
}

class _ScheduleVisitScreenState extends State<ScheduleVisitScreen> {
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Form fields
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedRisk;
  Map<String, String>? _selectedResponder;
  String? _selectedUrgency;

  // Data
  List<Map<String, String>> _adminResponders = [];

  // Address autocomplete
  List<String> _addressSuggestions = [];
  bool _isLoadingSuggestions = false;
  final String _apiKey = "AIzaSyCdj1DjsDO3VCVIoKJCmjZRsDlwrYNBsIY";

  @override
  void initState() {
    super.initState();
    _loadAdminResponders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003366),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 55),
            _buildHeader(),
            const SizedBox(height: 15),
            CustomTextField(controller: _nameController, label: "Client Name"),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: CustomTextField(
                        controller: _genderController, label: 'Gender')),
                const SizedBox(width: 10),
                Expanded(
                    child: CustomTextField(
                        controller: _ageController, label: 'Age')),
              ],
            ),
            const SizedBox(height: 16),
            _buildAddressAutocompleteField(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: CustomTextField(
                        controller: _cityController, label: 'City/Town')),
                const SizedBox(width: 10),
                Expanded(
                    child: CustomTextField(
                        controller: _stateController, label: 'State')),
              ],
            ),
            const SizedBox(height: 16),
            _buildDropdowns(),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 8,
              decoration: _inputDecoration("Additional Notes"),
            ),
            const SizedBox(height: 16),
            _buildDateTimePickers(),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Future<void> _loadAdminResponders() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final userData = userDoc.data();
    final activeOrg = userData?['orgId'] ?? userData?['organizationId'];
    if (activeOrg == null) return;

    final query1 = await FirebaseFirestore.instance
        .collection('users')
        .where('orgId', isEqualTo: activeOrg)
        .get();
    final query2 = await FirebaseFirestore.instance
        .collection('users')
        .where('organizationId', isEqualTo: activeOrg)
        .get();

    final docs = {...query1.docs, ...query2.docs};

    setState(() {
      _adminResponders =
          docs.where((doc) => doc.id != currentUser.uid).map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          'name': (data['name'] ?? 'Unnamed') as String,
        };
      }).toList();
    });
  }

  Future<void> _fetchAddressSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() => _addressSuggestions = []);
      return;
    }

    setState(() => _isLoadingSuggestions = true);

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(input)}&types=address&key=$_apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List predictions = data['predictions'];
        setState(() {
          _addressSuggestions = predictions
              .map<String>((p) => p['description'] as String)
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching address suggestions: $e');
    } finally {
      setState(() => _isLoadingSuggestions = false);
    }
  }

  Future<void> _getAddressDetails(String address) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$_apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        if (results.isNotEmpty) {
          final components = results[0]['address_components'] as List;

          String? city;
          String? state;

          for (var component in components) {
            final types = List<String>.from(component['types']);
            if (types.contains('locality') || types.contains('postal_town')) {
              city = component['long_name'];
            }
            if (types.contains('administrative_area_level_1')) {
              state = component['short_name'];
            }
          }

          setState(() {
            _cityController.text = city ?? '';
            _stateController.text = state ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint('Error getting address details: $e');
    }
  }

  Widget _buildAddressAutocompleteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _addressController,
          onChanged: _fetchAddressSuggestions,
          decoration: _inputDecoration('Address'),
          style: const TextStyle(color: Colors.black),
        ),
        if (_isLoadingSuggestions)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: LinearProgressIndicator(),
          ),
        if (_addressSuggestions.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _addressSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _addressSuggestions[index];
                return ListTile(
                  title: Text(suggestion),
                  onTap: () async {
                    final streetAddress = suggestion.split(',').first.trim();
                    setState(() {
                      _addressController.text = streetAddress;
                      _addressSuggestions = [];
                    });
                    await _getAddressDetails(suggestion);
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Schedule Visit",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<Map<String, String>>(
          value: _selectedResponder,
          decoration: _dropdownDecoration("Select Responder"),
          items: _adminResponders.map((responder) {
            return DropdownMenuItem(
              value: responder,
              child: Text(responder['name']!),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedResponder = value),
        ),
      ],
    );
  }

  Widget _buildDropdowns() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedRisk,
            decoration: _dropdownDecoration("Risk Level"),
            items: ['Safe', 'Unstable', 'Dangerous'].map((risk) {
              return DropdownMenuItem(
                value: risk,
                child: Text(risk),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedRisk = value),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedUrgency,
            decoration: _dropdownDecoration("Urgency"),
            items: ['Low', 'Medium', 'High', 'Critical'].map((urgency) {
              return DropdownMenuItem(
                value: urgency,
                child: Text(urgency),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedUrgency = value),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePickers() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _pickDate,
            child: AbsorbPointer(
              child: TextField(
                decoration: _inputDecoration(
                  _selectedDate == null
                      ? "Select Date"
                      : "${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}",
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: _pickTime,
            child: AbsorbPointer(
              child: TextField(
                decoration: _inputDecoration(
                  _selectedTime == null
                      ? "Select Time"
                      : _selectedTime!.format(context),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _clearForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            child: const Text(
              "Schedule Visit",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _submitForm() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both date and time')),
      );
      return;
    }

    final scheduledDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final userData = userDoc.data();
    final String? orgId = userData?['orgId'] ?? userData?['organizationId'];

    final visitData = {
      'clientName': _nameController.text.trim(),
      'gender': _genderController.text.trim(),
      'age': _ageController.text.trim(),
      'risk': _selectedRisk,
      'address': _addressController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'urgency': _selectedUrgency,
      'description': _notesController.text.trim(),
      'responderId': _selectedResponder?['uid'],
      'responder': _selectedResponder?['name'],
      'scheduledDateTime': scheduledDateTime,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
      'orgId': orgId,
    };

    try {
      final visitRef =
          await FirebaseFirestore.instance.collection('visits').add(visitData);

      await FirebaseFirestore.instance.collection('activity_logs').add({
        'timestamp': FieldValue.serverTimestamp(),
        'visitId': visitRef.id,
        'orgId': orgId,
        'userId': _selectedResponder?['uid'],
        'userName': _selectedResponder?['name'],
        'type': 'Visit Scheduled',
        'details':
            '${_selectedResponder?['name']} scheduled for ${_formatDateTime(scheduledDateTime)}',
        'status': 'pending',
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Visit scheduled successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/');
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scheduling visit: ${e.toString()}')),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final time = TimeOfDay.fromDateTime(dateTime).format(context);
    return "${dateTime.month}/${dateTime.day}/${dateTime.year} at $time";
  }

  void _clearForm() {
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
      _selectedDate = null;
      _selectedTime = null;
    });
    context.go("/");
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
