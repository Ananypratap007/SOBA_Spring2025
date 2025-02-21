import 'package:flutter/material.dart';

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});

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
                "Checking in",
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
                // Replace the image with a large icon
                const Icon(
                  Icons.camera_front,
                  size: 240,
                  color: Colors.grey,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Take a selfie for identification",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {}, // Placeholder action
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt, 
                      color: Colors.white, 
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
