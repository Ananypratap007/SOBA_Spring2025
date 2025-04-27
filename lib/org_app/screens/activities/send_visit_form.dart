import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

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
  Map<String, String>? _selectedResponder;
  String? _selectedUrgency;
  List<Map<String, String>> _adminResponders = [];
  bool _isFetchingRisk = false;
  String? _locationRiskEstimate;

  List<String> _addressSuggestions = [];
  bool _isLoadingSuggestions = false;
  final String _apiKey =
      "AIzaSyCdj1DjsDO3VCVIoKJCmjZRsDlwrYNBsIY"; // <<== PUT YOUR KEY HERE

  @override
  void initState() {
    super.initState();
    _loadAdminResponders();
  }

  Future<void> _loadAdminResponders() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (userDoc.exists && userDoc.data() != null) {
      final userData = userDoc.data()!;
      final activeOrg = userData['orgId'] ?? userData['organizationId'];

      if (activeOrg != null) {
        final query = await FirebaseFirestore.instance
            .collection('users')
            .where('orgId', isEqualTo: activeOrg)
            .get();

        setState(() {
          _adminResponders = query.docs.map<Map<String, String>>((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'uid': doc.id,
              'name': data['name']?.toString() ?? '',
            };
          }).toList();
        });
      }
    }
  }

// Get Location Risk Estimate

  Future<String> getLocationRiskFromOSM(double lat, double lon) async {
    final String overpassUrl = "https://overpass-api.de/api/interpreter";

    final String query = """
  [out:json];
  (
    node["amenity"="bar"](around:500,$lat,$lon);
    node["amenity"="nightclub"](around:500,$lat,$lon);
    node["amenity"="pub"](around:500,$lat,$lon);
    node["amenity"="police"](around:500,$lat,$lon);
    node["amenity"="hospital"](around:500,$lat,$lon);
  );
  out;
  """;

    try {
      final response = await http.post(
        Uri.parse(overpassUrl),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"data": query},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List<dynamic>;

        int riskScore = 0;

        for (var element in elements) {
          final tags = element['tags'] ?? {};

          if (tags['amenity'] == 'bar' ||
              tags['amenity'] == 'nightclub' ||
              tags['amenity'] == 'pub') {
            riskScore += 1; // risky
          }
          if (tags['amenity'] == 'police' || tags['amenity'] == 'hospital') {
            riskScore -= 2; // safer
          }
        }

        if (riskScore >= 5) {
          return "Dangerous";
        } else if (riskScore >= 2) {
          return "Unstable";
        } else {
          return "Safe";
        }
      } else {
        print("Error from OSM API: ${response.body}");
        return "Unstable"; // Default if error
      }
    } catch (e) {
      print("OSM Error: $e");
      return "Unstable"; // Default if error
    }
  }

  Future<void> _fetchAddressSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() => _addressSuggestions = []);
      return;
    }

    setState(() => _isLoadingSuggestions = true);

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(input)}&types=address&key=$_apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List predictions = data['predictions'];
        setState(() {
          _addressSuggestions = predictions
              .map<String>((p) => p['description'] as String)
              .toList();
        });
      } else {
        setState(() => _addressSuggestions = []);
      }
    } catch (e) {
      setState(() => _addressSuggestions = []);
    }

    setState(() => _isLoadingSuggestions = false);
  }

  Future<void> _getAddressDetails(String address) async {
    debugPrint('Fetching details for address: $address');

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeQueryComponent(address)}&key=$_apiKey',
    );

    debugPrint('Geocoding URL: $url');

    try {
      final response = await http.get(url);
      debugPrint('Geocoding API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('API status: ${data['status']}');

        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          debugPrint('Found ${results.length} results');

          if (results.isNotEmpty) {
            final firstResult = results[0];
            final components = firstResult['address_components'] as List;
            debugPrint('Address components: ${components.length} found');

            String? city;
            String? state;

            for (var component in components) {
              final types = List<String>.from(component['types']);
              debugPrint('${component['long_name']} - ${types.join(', ')}');

              if (city == null &&
                  (types.contains('locality') ||
                      types.contains('postal_town') ||
                      types.contains('sublocality'))) {
                city = component['long_name'];
              }
              if (state == null &&
                  types.contains('administrative_area_level_1')) {
                state = component['short_name'];
              }
            }

            debugPrint('Parsed city: $city, state: $state');

            // Get Latitude/Longitude from Google response
            final lat = firstResult['geometry']['location']['lat'];
            final lon = firstResult['geometry']['location']['lng'];

            // Call OpenStreetMap Overpass API to determine location risk
            setState(() {
              _isFetchingRisk = true; // START fetching spinner
            });
            final locationRisk = await getLocationRiskFromOSM(lat, lon);

            // Update the UI
            if (mounted) {
              setState(() {
                _cityController.text = city ?? '';
                _stateController.text = state ?? '';
                _locationRiskEstimate =
                    locationRisk; // <-- store silently in background
              });
            }
          } else {
            debugPrint('No results in successful response');
          }
        } else {
          debugPrint('API error status: ${data['status']}');
          debugPrint('Error message: ${data['error_message'] ?? 'None'}');
        }
      } else {
        debugPrint('HTTP error: ${response.body}');
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003366),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 55),
            _buildHeader(),
            const SizedBox(height: 15),
            _buildFormFields(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Client Information Form",
          style: TextStyle(
              fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const Spacer(),
        SizedBox(
          width: 135,
          child: DropdownButtonFormField<Map<String, String>>(
            value: _adminResponders.contains(_selectedResponder)
                ? _selectedResponder
                : null,
            isExpanded: true,
            decoration: _dropdownDecoration("Select Responder"),
            hint: const Text("Select Responder"),
            items: _adminResponders.map((responder) {
              return DropdownMenuItem<Map<String, String>>(
                value: responder,
                child: Text(responder['name']!),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedResponder = value),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        CustomTextField(controller: _nameController, label: "Client Name"),
        const SizedBox(height: 16),
        Row(
          children: [
            Flexible(
              child: CustomTextField(
                controller: _genderController,
                label: 'Gender',
              ),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: CustomTextField(
                controller: _ageController,
                label: 'Age',
              ),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: DropdownButtonFormField<String>(
                value: _selectedRisk,
                isDense: true,
                decoration: _dropdownDecoration("Risk").copyWith(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                ),
                items: ["Safe", "Unstable", "Dangerous"].map((risk) {
                  return DropdownMenuItem(
                    value: risk,
                    child: Text(
                      risk,
                      style: const TextStyle(
                          fontSize: 14), // smaller text to prevent overflow
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedRisk = value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildUrgencyDropdown(),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 12,
          decoration: _inputDecoration("Client & Visit Description"),
        ),
        const SizedBox(height: 20),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildAddressAutocompleteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _addressController,
          onChanged: _fetchAddressSuggestions,
          style: const TextStyle(color: Colors.black),
          decoration: _inputDecoration('Address'),
        ),
        if (_isLoadingSuggestions)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          ),
        if (_addressSuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: _addressSuggestions.map((suggestion) {
                return ListTile(
                  title: Text(suggestion),
                  onTap: () async {
                    // Extract just the street address portion (before the first comma)
                    final streetAddress = suggestion.split(',').first.trim();

                    setState(() {
                      _addressController.text = streetAddress;
                      _addressSuggestions = [];
                    });

                    // Small delay to ensure UI updates
                    await Future.delayed(const Duration(milliseconds: 50));

                    // Fetch details using the full suggestion for accurate geocoding
                    await _getAddressDetails(suggestion);
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildUrgencyDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedUrgency,
      decoration: _dropdownDecoration("Urgency Level"),
      items: ["Low", "Medium", "High", "Critical"].map((urgency) {
        return DropdownMenuItem(value: urgency, child: Text(urgency));
      }).toList(),
      onChanged: (value) => setState(() => _selectedUrgency = value),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _clearForm();
              context.go('/');
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22)),
            ),
            child: const Text("Cancel",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22)),
            ),
            child: const Text("Send",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (_selectedResponder == null) {
      Fluttertoast.showToast(msg: "Please select a responder.");
      return;
    }

    final jobData = {
      'clientName': _nameController.text.trim(),
      'gender': _genderController.text.trim(),
      'age': _ageController.text.trim(),
      'risk': _selectedRisk,
      'address': _addressController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'urgency': _selectedUrgency,
      'description': _notesController.text.trim(),
      'responderId': _selectedResponder?['uid'],
      'responder': _selectedResponder?['name'],
      'createdAt': DateTime.now(),
      'status': 'inactive',
      'locationRiskEstimate': _locationRiskEstimate,
    };

    // 1. Save the visit first
    await FirebaseFirestore.instance.collection('visits').add(jobData);

    // 2. Then immediately update the responder's locationRisk!
    if (_selectedResponder?['uid'] != null && _selectedRisk != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_selectedResponder!['uid'])
          .update({
        'locationRisk': _selectedRisk!
            .toLowerCase(), // like "safe", "unstable", "dangerous"
      });
    }

    // 3. Show confirmation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Your request has been sent successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
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
      _selectedResponder = null;
      _addressSuggestions = [];
    });
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
