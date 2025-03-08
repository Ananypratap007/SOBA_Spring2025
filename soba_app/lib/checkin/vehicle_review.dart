import 'package:flutter/material.dart';

class VehicleReviewScreen extends StatelessWidget {
  const VehicleReviewScreen({
    super.key,
    this.onFinished,
  });

  final VoidCallback? onFinished;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.directions_car,
                    size: 120,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  const Text("Review your vehicle photo"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => onFinished?.call(),
                    child: const Text("Finish"),
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
