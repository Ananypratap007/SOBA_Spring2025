import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyDetailsScreen extends StatefulWidget {
  final String responderId;
  final String visitId;

  const EmergencyDetailsScreen({
    super.key,
    required this.responderId,
    required this.visitId,
  });

  @override
  State<EmergencyDetailsScreen> createState() => _EmergencyDetailsScreenState();
}

class _EmergencyDetailsScreenState extends State<EmergencyDetailsScreen> {
  late Future<Map<String, dynamic>> _dataFuture;
  String _currentStatus = '';

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<Map<String, dynamic>> _loadData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.responderId)
          .get();
      final userData = userDoc.data() ?? {};

      Map<String, dynamic> visitData = {};
      if (widget.visitId.isNotEmpty) {
        final visitDoc = await FirebaseFirestore.instance
            .collection('visits')
            .doc(widget.visitId)
            .get();
        visitData = visitDoc.data() ?? {};
      }

      _currentStatus = (userData['status'] ?? '').toString().toLowerCase();

      return {
        'user': userData,
        'visit': visitData,
      };
    } catch (e) {
      return {
        'user': {},
        'visit': {},
      };
    }
  }

  Future<void> _acknowledgeEmergency() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.responderId)
        .update({'status': 'emergency-responded'});

    if (widget.visitId.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('visits')
          .doc(widget.visitId)
          .update({'status': 'emergency-responded'});
    }

    setState(() {
      _currentStatus = 'emergency-responded';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Emergency acknowledged!')),
    );
  }

  Future<void> _resolveEmergency(Map<String, dynamic> userData) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.responderId)
        .update({'status': 'idle'});

    if (widget.visitId.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('visits')
          .doc(widget.visitId)
          .update({'status': 'resolved'});
    }

    await FirebaseFirestore.instance.collection('emergency_reports').add({
      'responderId': widget.responderId,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'resolved',
      'userData': userData,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Emergency resolved and logged!')),
    );

    Navigator.pop(context);
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      );

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text("$label: $value"),
      );

  Widget _imageColumn(Map<String, dynamic> visitData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (visitData['selfieUrl'] != null) ...[
          const Text("Selfie:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Image.network(
            visitData['selfieUrl'],
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 20),
        ] else
          const Text("No selfie available"),
        if (visitData['vehiclePhotoUrl'] != null) ...[
          const Text("Parked Car Photo:",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Image.network(
            visitData['vehiclePhotoUrl'],
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ] else
          const Text("No parked car photo available"),
      ],
    );
  }

  Widget _actionButton(Map<String, dynamic> userData) {
    if (_currentStatus == 'emergency') {
      return ElevatedButton(
        onPressed: _acknowledgeEmergency,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        ),
        child: const Text(
          'Acknowledge Emergency',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    } else if (_currentStatus == 'emergency-responded') {
      return ElevatedButton(
        onPressed: () => _resolveEmergency(userData),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        ),
        child: const Text(
          'Resolve Emergency',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return const SizedBox.shrink(); // No button
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Details"),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No data found"));
          }

          final userData = snapshot.data!['user'] ?? {};
          final visitData = snapshot.data!['visit'] ?? {};
          final vehicle1 = userData['vehicle1'] as Map<String, dynamic>?;
          final vehicle2 = userData['vehicle2'] as Map<String, dynamic>?;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader("User Profile"),
                            _infoRow("Name", userData['name'] ?? 'N/A'),
                            _infoRow(
                                "Age", userData['age']?.toString() ?? 'N/A'),
                            _infoRow("Gender", userData['gender'] ?? 'N/A'),
                            _infoRow("Email", userData['email'] ?? 'N/A'),
                            _infoRow("Location", userData['location'] ?? 'N/A'),
                            _sectionHeader("Emergency Contact"),
                            _infoRow("Phone", userData['phone'] ?? 'N/A'),
                            _infoRow("Email", userData['email'] ?? 'N/A'),
                            _sectionHeader("Vehicle Information"),
                            if (vehicle1 != null) ...[
                              const Text("Primary Vehicle:",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              _infoRow("License Plate",
                                  vehicle1['licensePlate'] ?? 'N/A'),
                              _infoRow("Make", vehicle1['make'] ?? 'N/A'),
                              _infoRow("Model", vehicle1['model'] ?? 'N/A'),
                              _infoRow("Color", vehicle1['color'] ?? 'N/A'),
                              const SizedBox(height: 10),
                            ] else
                              const Text(
                                  "No primary vehicle information available"),
                            if (vehicle2 != null) ...[
                              const Text("Secondary Vehicle:",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              _infoRow("License Plate",
                                  vehicle2['licensePlate'] ?? 'N/A'),
                              _infoRow("Make", vehicle2['make'] ?? 'N/A'),
                              _infoRow("Model", vehicle2['model'] ?? 'N/A'),
                              _infoRow("Color", vehicle2['color'] ?? 'N/A'),
                            ] else
                              const Text(
                                  "No secondary vehicle information available"),
                            _sectionHeader("Visit Information"),
                            _infoRow(
                                "Client", visitData['clientName'] ?? 'N/A'),
                            _infoRow("Address", visitData['address'] ?? 'N/A'),
                            _infoRow("Description",
                                visitData['description'] ?? 'N/A'),
                            _infoRow("Urgency", visitData['urgency'] ?? 'N/A'),
                            _sectionHeader("Selfie Review"),
                            _infoRow("Description of attire",
                                visitData['selfieDescription'] ?? 'N/A'),
                            const SizedBox(height: 20),
                            if (visitData['selectedVehicle'] != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Selected Vehicle Info:",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  _infoRow(
                                      "Vehicle", visitData['selectedVehicle']),
                                ],
                              )
                            else
                              const Text("No selected vehicle info available"),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 1,
                        child: _imageColumn(visitData),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _actionButton(userData),
              ),
            ],
          );
        },
      ),
    );
  }
}
