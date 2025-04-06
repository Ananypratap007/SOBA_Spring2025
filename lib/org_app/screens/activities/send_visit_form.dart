import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ClientFormScreen extends StatefulWidget {
  const ClientFormScreen({super.key});

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedRisk;
  String? _selectedUrgency;

  final List<Map<String, dynamic>> riskLevels = [
    {"label": "Safe", "color": Colors.green},
    {"label": "Unstable", "color": Colors.orange},
    {"label": "Dangerous", "color": Colors.red},
  ];

  final List<Map<String, dynamic>> urgencyLevels = [
    {"label": "Low", "color": Colors.green, "icon": Icons.check_circle},
    {"label": "Medium", "color": Colors.amber, "icon": Icons.warning},
    {"label": "High", "color": Colors.orange, "icon": Icons.error},
    {"label": "Critical", "color": Colors.red, "icon": Icons.priority_high},
  ];

  @override
  Widget build(BuildContext context) {
    final selectedUrgencyColor = urgencyLevels.firstWhere(
      (u) => u['label'] == _selectedUrgency,
      orElse: () => {'color': Colors.grey[300]},
    )['color'];

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 55,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Client Information Form",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 240, // To adjust the width of the Dropdown menu
                  child: DropdownButtonFormField<String>(
                    value: _selectedUrgency,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: "Selected Responder",
                      filled: true,
                      fillColor: selectedUrgencyColor.withOpacity(0.25),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    hint: const Text("Select Responder"),
                    items: urgencyLevels.map((urgency) {
                      return DropdownMenuItem<String>(
                        value: urgency["label"],
                        child: Row(
                          children: [
                            const SizedBox(width: 6),
                            Text(urgency["label"]),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedUrgency = value),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Client Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _genderController,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _selectedRisk,
                    decoration: const InputDecoration(
                      labelText: 'Risk',
                      border: OutlineInputBorder(),
                    ),
                    items: riskLevels.map((risk) {
                      return DropdownMenuItem<String>(
                        value: risk["label"],
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 6,
                              backgroundColor: risk["color"],
                            ),
                            const SizedBox(width: 8),
                            Text(risk["label"]),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedRisk = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      labelText: 'State',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Client & Visit Description",
                  style: TextStyle(fontSize: 16),
                ),
                const Spacer(),
                SizedBox(
                  width: 150, // Adjust the width of the Dropdown menu
                  child: DropdownButtonFormField<String>(
                    value: _selectedUrgency,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: "Urgency Level",
                      filled: true,
                      fillColor: selectedUrgencyColor.withOpacity(0.25),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    hint: const Text("Urgency Level"),
                    items: urgencyLevels.map((urgency) {
                      return DropdownMenuItem<String>(
                        value: urgency["label"],
                        child: Row(
                          children: [
                            Icon(urgency["icon"],
                                color: urgency["color"], size: 18),
                            const SizedBox(width: 6),
                            Text(urgency["label"]),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedUrgency = value),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            // Placeholder rich text field
            TextField(
              controller: _notesController,
              maxLines: 12,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: Color(0xFF003366),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, // makes the button stretch full width
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Clear all form fields
                        _nameController.clear();
                        _genderController.clear();
                        _ageController.clear();
                        _addressController.clear();
                        _cityController.clear();
                        _stateController.clear();
                        _notesController.clear();
                        setState(() {
                          _selectedRisk = null;
                          _selectedUrgency = null;
                        });

                        // Navigate back to home
                        context.go('/');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16), // space between the buttons
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // handle send
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF003366),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: const Text(
                        "Send",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
