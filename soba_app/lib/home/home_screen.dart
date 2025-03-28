import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool connected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Page background
      backgroundColor: Colors.white,

      // Gradient AppBar
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white, 
            fontSize: 20, 
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 1, 40, 65), Color.fromARGB(255, 10, 74, 139)], // Gradient colors
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ===================
            // UPCOMING JOB CARD
            // ===================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 10, 74, 139), // Updated container color
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.9), // Shadow color
                    blurRadius: 6, // Blur radius
                    offset: const Offset(0, 4), // Offset for shadow
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: "Upcoming Job" on left, "Status: URGENT" + icon on right
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Upcoming Job",
                        style: TextStyle(
                          fontSize: 18, 
                          color: Colors.white, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: const [
                          Text(
                            "Status: URGENT",
                            style: TextStyle(
                              fontSize: 16, 
                              color: Colors.white, 
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.warning, 
                            color: Colors.red, 
                            size: 18,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Recipient Info
                  const Text(
                    "Recipient: Brad Miller",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Age: 47",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Address: 5639 Kings Row, 73808",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 12),

                  // Description label + box
                  const Text(
                    "Description:",
                    style: TextStyle(
                      fontSize: 16, 
                      color: Colors.white, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF5DAEFF), // Slightly lighter shade for text box
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "Experiencing a mental health crisis. May be in distress, "
                      "exhibiting signs of emotional instability, struggling with "
                      "suicidal thoughts. A compassionate and calming approach is "
                      "advised to ensure their safety.",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===================
            // START VISIT CARD
            // ===================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 10, 74, 139), // Updated container color
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // Shadow color
                    blurRadius: 6, // Blur radius
                    offset: const Offset(0, 4), // Offset for shadow
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Start Visit",
                    style: TextStyle(
                      fontSize: 18, 
                      color: Colors.white, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Tap to check in and start your visit",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Start Button
                  ElevatedButton(
                    onPressed: () {
                      context.go('/checkin'); // Navigate to Check-in page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30, 
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "Start",
                      style: TextStyle(
                        fontSize: 16, 
                        color: Colors.white, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ===================
            // Device status
            // ===================
            const SizedBox(height: 20), // Adjust the height as needed

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 10, 74, 139), // Updated container color
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // Shadow color
                    blurRadius: 6, // Blur radius
                    offset: const Offset(0, 4), // Offset for shadow
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Device Status",
                    style: TextStyle(
                      fontSize: 18, 
                      color: Colors.white, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
        const SizedBox(height: 16),

        ElevatedButton(
          onPressed: () {
            setState(() {
              // Toggle the connected state when button is pressed
              connected = !connected;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: connected ? Colors.green : Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 12,
            ),
          ),
          child: Text(
            connected ? "Connected" : "Disconnected",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
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
