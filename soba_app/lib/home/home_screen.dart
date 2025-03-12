import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soba_app/domain/colors.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Dashboard'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF003366), const Color(0xFF0066CC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 28, color: Colors.black),
            onPressed: () {
              context.go('/profile'); // Navigate to Profile
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Upcoming Job Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF0066CC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            NetworkImage('https://randomuser.me/api/portraits/men/45.jpg'), // Placeholder image
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Upcoming Job",
                              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              "Status: URGENT 🔥",
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Recipient: Brad Miller",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const Text(
                    "Age: 47",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const Text(
                    "Address: 5639 Kings Row, 73808",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  // Description Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "Experiencing a mental health crisis. May be in distress, exhibiting signs "
                      "of emotional instability, struggling with suicidal thoughts. A "
                      "compassionate and calming approach is advised to ensure their safety.",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Check-in Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    "Start your visit",
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Tap to check in and start your visit",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  // Start Button
                  ElevatedButton(
                    onPressed: () {
                      context.go('/checkin'); // Navigate to Check-in page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                    child: const Text(
                      "Start",
                      style: TextStyle(fontSize: 16, color: Colors.white),
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
