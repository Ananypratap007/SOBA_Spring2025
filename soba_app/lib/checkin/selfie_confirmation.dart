import 'package:flutter/material.dart';

class SelfieReviewScreen extends StatelessWidget {
  const SelfieReviewScreen({
    super.key,
    this.onSelfieConfirmed,
  });

  final VoidCallback? onSelfieConfirmed;

  @override
  Widget build(BuildContext context) {
   // _state = CheckinState.vehicle_review;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_circle,
                  size: 220,
                  color: Colors.grey,
                ),
                const SizedBox(height: 30),
                const Text("Describe what you are wearing today"),
                const SizedBox(height: 0),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'i.e. red shirt, blue jeans',
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () => onSelfieConfirmed?.call(),
                  child: const Text("Next"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
