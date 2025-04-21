import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'vehicle_picture.dart'; // Import the vehicle picture screen

class VehicleReviewScreen extends StatefulWidget {
  const VehicleReviewScreen({
    super.key,
    required this.imagePath,
    this.onFinished,
  });

  final String imagePath;
  final VoidCallback? onFinished;

  @override
  State<VehicleReviewScreen> createState() => _VehicleReviewScreenState();
}

class _VehicleReviewScreenState extends State<VehicleReviewScreen> {
  String? _selectedVehicleKey;

  Future<List<MapEntry<String, dynamic>>> _fetchVehicles() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = userDoc.data();
    if (data == null) return [];
    // Filter out entries that start with "vehicle" and are maps
    final vehicles = data.entries
        .where((entry) =>
            entry.key.startsWith('vehicle') &&
            entry.value is Map<String, dynamic>)
        .toList();
    vehicles.sort((a, b) {
      int aNum = int.tryParse(a.key.replaceAll('vehicle', '')) ?? 0;
      int bNum = int.tryParse(b.key.replaceAll('vehicle', '')) ?? 0;
      return aNum.compareTo(bNum);
    });
    return vehicles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003366),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0XFF4CAF93),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(widget.imagePath),
                        fit: BoxFit.cover,
                        width: 200,
                        height: 150,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.directions_car,
                            size: 100,
                            color: Colors.white70,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Review your vehicle photo",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Dropdown container for selecting a vehicle.
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0XFF4CAF93).withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: FutureBuilder<List<MapEntry<String, dynamic>>>(
                      future: _fetchVehicles(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text(
                            "No vehicles found in your profile.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          );
                        }
                        final vehicles = snapshot.data!;
                        // Set default selected if not yet set.
                        _selectedVehicleKey ??= vehicles.first.key;
                        return DropdownButtonFormField<String>(
                          value: _selectedVehicleKey,
                          dropdownColor: const Color(0xFF003366),
                          iconEnabledColor: Colors.white,
                          decoration: const InputDecoration(
                            labelText: "Select Vehicle",
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(color: Colors.white),
                          items: vehicles.map((entry) {
                            // Format: "Vehicle 1: Make Model"
                            int number = int.tryParse(entry.key.replaceAll('vehicle', '')) ?? 0;
                            final data = entry.value as Map<String, dynamic>;
                            final make = data['make'] ?? '';
                            final model = data['model'] ?? '';
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text("Vehicle $number: $make $model"),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedVehicleKey = value;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => widget.onFinished?.call(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0XFF4CAF93),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        "Complete Check-in",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
