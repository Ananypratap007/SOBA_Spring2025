import 'package:flutter/material.dart';
import 'profile_info_page.dart';

class ProfilePage extends StatelessWidget {
  final Map<String, String> personalDetails;
  final Map<String, String> details;

  const ProfilePage({
    super.key,
    required this.personalDetails,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFB076),
      appBar: AppBar(
        title: const Text("Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          ProfileCard(
              name: 'John',
              email: "john.doe@gmail.com",
              phone: "+123456879",
              onEdit: () {}),
          SizedBox(height: 20),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width - 50,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildSectionHeader(Icons.person, "Personal Information"),
                      const Divider(thickness: 1, color: Colors.grey),
                      ...personalDetails.entries
                          .map((entry) =>
                              buildLabeledText(entry.key, entry.value))
                          ,
                      const SizedBox(height: 15),
                      buildSectionHeader(Icons.fingerprint, "Biological Info"),
                      const Divider(thickness: 1, color: Colors.grey),
                      ...details.entries
                          .map((entry) =>
                              buildLabeledText(entry.key, entry.value))
                          ,
                    ],
                  ),

                  // Edit Button (Top Right)
                  Positioned(
                    top: -15,
                    right: 0,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.edit, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 25),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget buildLabeledText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 15, color: Colors.black),
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
