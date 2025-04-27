// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:go_router/go_router.dart';

// class RescheduleVisitScreen extends StatefulWidget {
//   const RescheduleVisitScreen({super.key});

//   @override
//   State<RescheduleVisitScreen> createState() => _RescheduleVisitScreenState();
// }

// class _RescheduleVisitScreenState extends State<RescheduleVisitScreen> {
//   List<DocumentSnapshot> _visits = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadScheduledVisits();
//   }

//   Future<void> _loadScheduledVisits() async {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;

//     final userDoc = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(currentUser.uid)
//         .get();
//     final userData = userDoc.data();
//     final String? orgId = userData?['orgId'] ?? userData?['organizationId'];

//     if (orgId == null) return;

//     final querySnapshot = await FirebaseFirestore.instance
//         .collection('visits')
//         .where('orgId', isEqualTo: orgId)
//         .get();

//     setState(() {
//       _visits = querySnapshot.docs;
//     });
//   }

//   void _editVisit(DocumentSnapshot visitDoc) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (_) => EditVisitScreen(visitDoc: visitDoc),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Reschedule Visits"),
//         backgroundColor: const Color(0xFF003366),
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(12),
//         itemCount: _visits.length,
//         itemBuilder: (context, index) {
//           final visit = _visits[index].data() as Map<String, dynamic>;
//           return Card(
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             elevation: 4,
//             margin: const EdgeInsets.symmetric(vertical: 8),
//             child: ListTile(
//               title: Text(visit['clientName'] ?? 'Unnamed Client'),
//               subtitle:
//                   Text("Responder: ${visit['responder'] ?? 'Unassigned'}"),
//               trailing: const Icon(Icons.edit, color: Colors.blue),
//               onTap: () => _editVisit(_visits[index]),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class EditVisitScreen extends StatefulWidget {
//   final DocumentSnapshot visitDoc;

//   const EditVisitScreen({super.key, required this.visitDoc});

//   @override
//   State<EditVisitScreen> createState() => _EditVisitScreenState();
// }

// class _EditVisitScreenState extends State<EditVisitScreen> {
//   DateTime? _selectedDate;
//   TimeOfDay? _selectedTime;
//   final TextEditingController _responderController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     final data = widget.visitDoc.data() as Map<String, dynamic>;
//     _responderController.text = data['responder'] ?? '';
//     Timestamp? timestamp = data['scheduledDateTime'];
//     if (timestamp != null) {
//       final dt = timestamp.toDate();
//       _selectedDate = DateTime(dt.year, dt.month, dt.day);
//       _selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
//     }
//   }

//   Future<void> _pickDate() async {
//     final date = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
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
//       initialTime: _selectedTime ?? TimeOfDay.now(),
//     );
//     if (time != null) {
//       setState(() => _selectedTime = time);
//     }
//   }

//   Future<void> _saveChanges() async {
//     if (_selectedDate == null || _selectedTime == null) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text('Select date and time')));
//       return;
//     }

//     final newDateTime = DateTime(
//       _selectedDate!.year,
//       _selectedDate!.month,
//       _selectedDate!.day,
//       _selectedTime!.hour,
//       _selectedTime!.minute,
//     );

//     await FirebaseFirestore.instance
//         .collection('visits')
//         .doc(widget.visitDoc.id)
//         .update({
//       'responder': _responderController.text.trim(),
//       'scheduledDateTime': Timestamp.fromDate(newDateTime),
//     });

//     Navigator.of(context).pop();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Edit Visit"),
//         backgroundColor: const Color(0xFF003366),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: _responderController,
//               decoration: const InputDecoration(
//                 labelText: "Responder",
//                 filled: true,
//                 fillColor: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _pickDate,
//               child: Text(_selectedDate == null
//                   ? "Select Date"
//                   : "${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}"),
//             ),
//             const SizedBox(height: 8),
//             ElevatedButton(
//               onPressed: _pickTime,
//               child: Text(_selectedTime == null
//                   ? "Select Time"
//                   : _selectedTime!.format(context)),
//             ),
//             const Spacer(),
//             ElevatedButton(
//               onPressed: _saveChanges,
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//               child: const Text("Save Changes"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class RescheduleVisitScreen extends StatefulWidget {
  const RescheduleVisitScreen({super.key});

  @override
  State<RescheduleVisitScreen> createState() => _RescheduleVisitScreenState();
}

class _RescheduleVisitScreenState extends State<RescheduleVisitScreen> {
  List<DocumentSnapshot> _visits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScheduledVisits();
  }

  Future<void> _loadScheduledVisits() async {
    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final userData = userDoc.data();
      final String? orgId = userData?['orgId'] ?? userData?['organizationId'];
      if (orgId == null) return;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('visits')
          .where('orgId', isEqualTo: orgId)
          .get();

      // Sort locally by scheduledDateTime
      final sortedDocs = querySnapshot.docs
        ..sort((a, b) {
          final aTime = (a.data() as Map<String, dynamic>)['scheduledDateTime']
              as Timestamp?;
          final bTime = (b.data() as Map<String, dynamic>)['scheduledDateTime']
              as Timestamp?;
          return (aTime ?? Timestamp.now()).compareTo(bTime ?? Timestamp.now());
        });

      setState(() {
        _visits = sortedDocs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading visits: ${e.toString()}')),
      );
    }
  }

  Future<void> _decrementPendingCount(String orgId) async {
    final today = DateTime.now();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final docRef = FirebaseFirestore.instance
        .collection('daily_status_counts')
        .doc(orgId)
        .collection('dates')
        .doc(todayString);

    final snapshot = await docRef.get();
    if (snapshot.exists) {
      final data = snapshot.data();
      int currentPending = (data?['pending'] ?? 0) as int;
      await docRef.update({
        'pending': currentPending > 0 ? currentPending - 1 : 0,
      });
    }
  }

  Future<void> _deleteVisit(DocumentSnapshot visitDoc) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this visit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) return;

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        final userData = userDoc.data();
        final String? orgId = userData?['orgId'] ?? userData?['organizationId'];
        if (orgId == null) return;

        await FirebaseFirestore.instance
            .collection('visits')
            .doc(visitDoc.id)
            .delete();

        await _decrementPendingCount(orgId); // <-- Update pending count!

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Visit deleted successfully')),
        );
        _loadScheduledVisits(); // Refresh the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting visit: ${e.toString()}')),
        );
      }
    }
  }

  void _editVisit(DocumentSnapshot visitDoc) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: EditVisitDialog(
          visitDoc: visitDoc,
          onVisitUpdated: _loadScheduledVisits,
        ),
      ),
    );
  }

  String _formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return 'Not scheduled';
    return DateFormat('MMM d, y • h:mm a').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Reschedule Visits",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF003366),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.refresh),
            onPressed: _loadScheduledVisits,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _visits.isEmpty
              ? const Center(child: Text('No visits found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _visits.length,
                  itemBuilder: (context, index) {
                    final visit = _visits[index].data() as Map<String, dynamic>;
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(visit['clientName'] ?? 'Unnamed Client'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Responder: ${visit['responder'] ?? 'Unassigned'}"),
                            Text(
                                "Scheduled: ${_formatDateTime(visit['scheduledDateTime'])}"),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editVisit(_visits[index]),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteVisit(_visits[index]),
                            ),
                          ],
                        ),
                        onTap: () => _editVisit(_visits[index]),
                      ),
                    );
                  },
                ),
    );
  }
}

class EditVisitDialog extends StatefulWidget {
  final DocumentSnapshot visitDoc;
  final VoidCallback onVisitUpdated;

  const EditVisitDialog({
    super.key,
    required this.visitDoc,
    required this.onVisitUpdated,
  });

  @override
  State<EditVisitDialog> createState() => _EditVisitDialogState();
}

class _EditVisitDialogState extends State<EditVisitDialog> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Map<String, String>? _selectedResponder;
  List<Map<String, String>> _adminResponders = [];

  @override
  void initState() {
    super.initState();
    final data = widget.visitDoc.data() as Map<String, dynamic>;
    _loadAdminResponders(data['responderId']);
    _loadInitialDateTime(data['scheduledDateTime']);
  }

  void _loadInitialDateTime(Timestamp? timestamp) {
    if (timestamp != null) {
      final dt = timestamp.toDate();
      _selectedDate = DateTime(dt.year, dt.month, dt.day);
      _selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
    }
  }

  Future<void> _loadAdminResponders(String? currentResponderId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

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

          if (currentResponderId != null) {
            final currentResponder = _adminResponders.firstWhere(
              (r) => r['uid'] == currentResponderId,
              orElse: () => {'uid': '', 'name': ''},
            );
            if (currentResponder['uid']!.isNotEmpty) {
              _selectedResponder = currentResponder;
            }
          }
        });
      }
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _saveChanges() async {
    if (_selectedDate == null ||
        _selectedTime == null ||
        _selectedResponder == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select date, time, and responder')));
      return;
    }

    final newDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    try {
      final visitId = widget.visitDoc.id;
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final userData = userDoc.data();
      final orgId = userData?['orgId'] ?? userData?['organizationId'];

      await FirebaseFirestore.instance
          .collection('visits')
          .doc(visitId)
          .update({
        'responderId': _selectedResponder?['uid'],
        'responder': _selectedResponder?['name'],
        'scheduledDateTime': Timestamp.fromDate(newDateTime),
      });

      // 🚀 Log this update to the activity_logs
      await FirebaseFirestore.instance.collection('activity_logs').add({
        'timestamp': FieldValue.serverTimestamp(),
        'visitId': visitId,
        'orgId': orgId,
        'userId': _selectedResponder?['uid'],
        'userName': _selectedResponder?['name'],
        'type': 'Visit Rescheduled',
        'details':
            '${_selectedResponder?['name']} rescheduled to ${DateFormat('MMM d, y • h:mm a').format(newDateTime)}',
        'status': 'pending',
      });

      widget.onVisitUpdated();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Visit updated successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating visit: ${e.toString()}')));
    }
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

  @override
  Widget build(BuildContext context) {
    final visitData = widget.visitDoc.data() as Map<String, dynamic>;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF003366),
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Reschedule Visit for ${visitData['clientName'] ?? 'Client'}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<Map<String, String>>(
                value: _selectedResponder,
                isExpanded: true,
                decoration: _dropdownDecoration("Select Responder"),
                hint: const Text("Select Responder",
                    style: TextStyle(color: Colors.black)),
                items: _adminResponders.map((responder) {
                  return DropdownMenuItem<Map<String, String>>(
                    value: responder,
                    child: Text(responder['name']!),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedResponder = value),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white),
                        ),
                        child: Text(
                          _selectedDate == null
                              ? "Select Date"
                              : "${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}",
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white),
                        ),
                        child: Text(
                          _selectedTime == null
                              ? "Select Time"
                              : _selectedTime!.format(context),
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
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
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: const Text(
                        "Save Changes",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
