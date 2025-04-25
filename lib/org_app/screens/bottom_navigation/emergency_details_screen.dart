import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyDetailsScreen extends StatelessWidget {
  final String responderId;
  final String visitId;
  
  const EmergencyDetailsScreen({
    super.key,
    required this.responderId,
    required this.visitId,
  });
  
  Future<Map<String, dynamic>> _loadData() async {
    // Fetch user profile.
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(responderId).get();
    print("User exists: ${userDoc.exists} Data: ${userDoc.data()}");

    if (visitId.isNotEmpty) {
      final visitDoc = await FirebaseFirestore.instance.collection('visits').doc(visitId).get();
      print("Visit exists: ${visitDoc.exists} Data: ${visitDoc.data()}");
    }

    return {
      'user': userDoc.data() ?? {},
      'visit': visitId.isNotEmpty ? (await FirebaseFirestore.instance.collection('visits').doc(visitId).get()).data() : {},
    };
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Details"),
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No data found"));
          }
          
          // Extract user data and visit data.
          final userData = snapshot.data!['user'] as Map<String, dynamic>;
          final visitData = snapshot.data!['visit'] as Map<String, dynamic>;
          
          // Extract vehicle info from user data if available.
          final vehicle1 = userData['vehicle1'] as Map<String, dynamic>?;
          final vehicle2 = userData['vehicle2'] as Map<String, dynamic>?;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Personal Information Section
                const Text("User Profile",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("Name: ${userData['name'] ?? 'N/A'}"),
                Text("Age: ${userData['age'] ?? 'N/A'}"),
                Text("Gender: ${userData['gender'] ?? 'N/A'}"),
                Text("Email: ${userData['email'] ?? 'N/A'}"),
                Text("Location: ${userData['location'] ?? 'N/A'}"),
                const SizedBox(height: 10),
                
                // Emergency Contact Section (using phone and email)
                const Text("Emergency Contact",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("Phone: ${userData['phone'] ?? 'N/A'}"),
                Text("Email: ${userData['email'] ?? 'N/A'}"),
                const SizedBox(height: 20),
                
                // Vehicle Information Section
                const Text("Vehicle Information",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                if (vehicle1 != null) ...[
                  const Text("Primary Vehicle:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("License Plate: ${vehicle1['licensePlate'] ?? 'N/A'}"),
                  Text("Make: ${vehicle1['make'] ?? 'N/A'}"),
                  Text("Model: ${vehicle1['model'] ?? 'N/A'}"),
                  Text("Color: ${vehicle1['color'] ?? 'N/A'}"),
                ] else
                  const Text("No primary vehicle information available"),
                const SizedBox(height: 10),
                if (vehicle2 != null) ...[
                  const Text("Secondary Vehicle:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("License Plate: ${vehicle2['licensePlate'] ?? 'N/A'}"),
                  Text("Make: ${vehicle2['make'] ?? 'N/A'}"),
                  Text("Model: ${vehicle2['model'] ?? 'N/A'}"),
                  Text("Color: ${vehicle2['color'] ?? 'N/A'}"),
                ] else
                  const Text("No secondary vehicle information available"),
                const SizedBox(height: 20),
                
                // Job Details Section (from visit document)
                const Text("Visit Information",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("Client: ${visitData['clientName'] ?? 'N/A'}"),
                Text("Address: ${visitData['address'] ?? 'N/A'}"),
                Text("Description: ${visitData['description'] ?? 'N/A'}"),
                Text("Urgency: ${visitData['urgency'] ?? 'N/A'}"),
                const SizedBox(height: 20),
                
                // Check-In Information Section (from visit)
                const Text("Check-In Info",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                // Selfie image (if available)
                visitData['selfieUrl'] != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Selfie:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Image.network(
                            visitData['selfieUrl'],
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ],
                      )
                    : const Text("No selfie available"),
                const SizedBox(height: 20),
                // Parked car photo (if available)
                visitData['vehiclePhotoUrl'] != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Parked Car Photo:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Image.network(
                            visitData['vehiclePhotoUrl'],
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ],
                      )
                    : const Text("No parked car photo available"),
                const SizedBox(height: 20),
                // Selfie Review Section: What they are wearing
                const Text("Selfie Review",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("Description of attire: ${visitData['selfieDescription'] ?? 'N/A'}"),
                const SizedBox(height: 20),
                // Selected Vehicle Info (if stored during check-in)
                visitData['selectedVehicle'] != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Selected Vehicle Info:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Vehicle: ${visitData['selectedVehicle']}"),
                        ],
                      )
                    : const Text("No vehicle review information available"),
              ],
            ),
          );
        },
      ),
    );
  }
}