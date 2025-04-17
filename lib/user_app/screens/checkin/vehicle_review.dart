import 'dart:io';
import 'package:flutter/material.dart';

class VehicleReviewScreen extends StatelessWidget {
  const VehicleReviewScreen({
    super.key,
    required this.imagePath,
    this.onFinished,
  });

  final String imagePath;
  final VoidCallback? onFinished;

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
                        File(imagePath),
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0XFF4CAF93).withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      "Your vehicle has been recorded for this visit. This helps maintain security during your visit.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => onFinished?.call(),
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
