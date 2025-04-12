import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Default center coordinates (e.g., Norman, OK)
  static const LatLng _defaultLocation = LatLng(35.2043, -97.4453);

  // Map controller
  final MapController _mapController = MapController();

  @override
  void dispose() {
    // No need to dispose _mapController — it doesn't implement Disposable
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Page background
      backgroundColor: const Color(0XFF4CAF93),
      
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Location Map',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Color(0XFF4CAF93),
          ),
        ),
        backgroundColor: const Color(0XFF4CAF93),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Search action
            },
          ),
        ],
      ),
      
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0XFF4CAF93),
        ),
        child: Column(
          children: [
            // Main content area with no curves
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF003366),
                ),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _defaultLocation,
                    initialZoom: 13.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.soba.app',
                      errorImage:
                          const NetworkImage('https://tile.openstreetmap.org/0/0/0.png'),
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _defaultLocation,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_pin,
                            color: Color(0XFF4CAF93),
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Reset the map to the default location
          _mapController.move(_defaultLocation, 13.0);
        },
        backgroundColor: const Color(0XFF4CAF93),
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}
