import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'vehicles_page.dart';

class ProfileInfoPage extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final Map<String, String> personalDetails;
  final Map<String, String> additionalDetails;
  final VoidCallback onEditProfile;
  final VoidCallback onEditPersonal;
  final VoidCallback onEditAdditional;

  const ProfileInfoPage({super.key, 
    required this.name,
    required this.email,
    required this.phone,
    required this.personalDetails,
    required this.additionalDetails,
    required this.onEditProfile,
    required this.onEditPersonal,
    required this.onEditAdditional,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          ProfileCard(
            name: name,
            email: email,
            phone: phone,
            onEdit: onEditProfile,
          ),
          const SizedBox(height: 20),
          // Personal Information Section
          InfoCard(
            icon: Icons.person,
            title: "Personal Details",
            details: personalDetails,
            onEdit: onEditPersonal,
            onMorePressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      personalDetails: {
                        "Name": "John Doe",
                        "Age": "28",
                        "Gender": "Male",
                        "Email": "johndoe@email.com",
                      },
                      details: {
                        "Sex": "Male",
                        "Race/Ethnicity": "Asian (Indian)",
                        "Height": "5'9\"",
                        "Weight": "150 lbs",
                        "Hair Color": "Black",
                        "Eye Color": "Brown",
                        "Skin Tone": "Medium",
                        "Distinguishing Marks": "Small scar on left cheek",
                      },
                    ),
                  ));
            },
          ),
          const SizedBox(height: 20),

          // Vehicle Information Section
          InfoCard(
            
              icon: Icons.directions_car,
              title: "Vehicle Information",
              details: additionalDetails,
              onEdit: onEditAdditional,
              onMorePressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => VehiclePage()));
              }),
        ],
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final VoidCallback onEdit;

  const ProfileCard({super.key, 
    required this.name,
    required this.email,
    required this.phone,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
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
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.black,
                        child: Icon(Icons.person, size: 30),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        name,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        email,
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        phone,
                        style: TextStyle(color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: onEdit,
                icon: Icon(Icons.edit, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Map<String, String> details; // Key-Value pairs for labels and values
  final VoidCallback onEdit;
  final VoidCallback onMorePressed; // New parameter

  const InfoCard({super.key, 
    required this.icon,
    required this.title,
    required this.details,
    required this.onEdit,
    required this.onMorePressed, // Accepts a function for "More" button
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: MediaQuery.of(context).size.width - 50,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              spreadRadius: 2,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Row with Icon
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      child: Icon(icon, size: 25),
                    ),
                    const SizedBox(width: 30),
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Divider(thickness: 1, color: Colors.grey),
                const SizedBox(height: 5),

                // Displaying all details dynamically
                ...details.entries
                    .map((entry) => buildLabeledText(entry.key, entry.value)),
              ],
            ),

            // Edit Button (Top Right)
            Positioned(
              top: -5,
              right: 0,
              child: IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, size: 20),
              ),
            ),

            // "More" Button (Bottom Right)
            Positioned(
              bottom: 0,
              right: 0,
              child: OutlinedButton(
                onPressed: onMorePressed, // Calls the function you provide
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(width: 2.0, color: Colors.orange),
                  fixedSize: const Size(80, 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "More",
                  style: TextStyle(fontSize: 13, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildLabeledText(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 7.0),
    child: RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    ),
  );
}
