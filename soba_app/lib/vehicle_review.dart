import 'package:flutter/material.dart';

class VehicleReviewScreen extends StatelessWidget {
  const VehicleReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50),
            width: double.infinity,
            height: 120,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orangeAccent, Colors.orange],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Center(
              child: Text(
                "Vehicle Review",
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
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
                  onPressed: () {
                    // Handle finish action (maybe navigate to home)
                  },
                  child: const Text("Finish"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
