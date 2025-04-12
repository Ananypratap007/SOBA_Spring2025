// import 'package:flutter/material.dart';

// class VehicleReviewScreen extends StatelessWidget {
//   const VehicleReviewScreen({
//     super.key,
//     this.onFinished,
//   });

//   final VoidCallback? onFinished;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Column(
//           children: [
//             Expanded(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(
//                     Icons.directions_car,
//                     size: 120,
//                     color: Colors.grey,
//                   ),
//                   const SizedBox(height: 20),
//                   const Text("Review your vehicle photo"),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: () => onFinished?.call(),
//                     child: const Text("Finish"),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0XFF4CAF93),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      size: 100,
                      color: Colors.white70,
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
