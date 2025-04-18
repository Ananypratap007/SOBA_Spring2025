import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  // Default center coordinates (e.g., Norman, OK)
  static const LatLng _defaultLocation = LatLng(35.2043, -97.4453);

  // Example additional markers with location info
  final List<Map<String, dynamic>> _markers = [
    {
      'position': const LatLng(35.2043, -97.4453),
      'title': 'Main Office',
      'description': '1234 Main Street, Norman, OK',
      'status': 'Active'
    },
    {
      'position': const LatLng(35.2173, -97.4365),
      'title': 'Campus Location',
      'description': '789 University Blvd, Norman, OK',
      'status': 'Standby'
    },
    {
      'position': const LatLng(35.1983, -97.4503),
      'title': 'South Center',
      'description': '456 Oak Avenue, Norman, OK',
      'status': 'Active'
    },
  ];

  // Map controller with animation capabilities
  late final AnimatedMapController _animatedMapController;
  bool _isZoomedIn = false;
  int _selectedMarkerIndex = -1;

  @override
  void initState() {
    super.initState();
    _animatedMapController = AnimatedMapController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animatedMapController.dispose();
    super.dispose();
  }

  // Animate to a specific marker
  void _animateToMarker(int index) {
    final targetZoom = _isZoomedIn && _selectedMarkerIndex == index ? 13.0 : 16.5;
    final isDeselecting = _selectedMarkerIndex == index && _isZoomedIn;
    
    setState(() {
      _selectedMarkerIndex = isDeselecting ? -1 : index;
      _isZoomedIn = !isDeselecting;
    });
    
    _animatedMapController.animateTo(
      dest: _markers[index]['position'],
      zoom: targetZoom,
    );
  }

  // Reset map to show all markers
  void _resetMapView() {
    setState(() {
      _isZoomedIn = false;
      _selectedMarkerIndex = -1;
    });
    
    _animatedMapController.animateTo(
      dest: _defaultLocation,
      zoom: 13.0,
    );
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
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _animatedMapController.mapController,
                  options: MapOptions(
                    initialCenter: _defaultLocation,
                    initialZoom: 13.0,
                    maxZoom: 18.0,
                        onTap: (tapPosition, point) {
                          // Close any zoom when tapping elsewhere on the map
                          if (_isZoomedIn || _selectedMarkerIndex != -1) {
                            setState(() {
                              _selectedMarkerIndex = -1;
                              _isZoomedIn = false;
                            });
                            _resetMapView();
                          }
                        },
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
                          markers: List.generate(
                            _markers.length,
                            (index) => Marker(
                              point: _markers[index]['position'],
                              width: 60,
                              height: 60,
                              alignment: Alignment.center,
                              child: GestureDetector(
                                onTap: () => _animateToMarker(index),
                                child: _buildMarkerIcon(index),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Map control buttons positioned on the right side
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Column(
                        children: [
                          // Zoom in button
                          _buildMapButton(
                            icon: Icons.zoom_in_rounded,
                            onPressed: () {
                              final currentZoom = _animatedMapController.mapController.camera.zoom;
                              _animatedMapController.animatedZoomIn();
                            },
                          ),
                          const SizedBox(height: 8),
                          // Zoom out button
                          _buildMapButton(
                            icon: Icons.zoom_out_rounded,
                            onPressed: () {
                              _animatedMapController.animatedZoomOut();
                            },
                          ),
                          const SizedBox(height: 8),
                          // Reset view button
                          _buildMapButton(
                            icon: Icons.gps_fixed_rounded,
                            onPressed: _resetMapView,
                          ),
                        ],
                      ),
                    ),
                    
                    // Info box that appears when a marker is selected (positioned at bottom)
                    if (_selectedMarkerIndex != -1)
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: _buildMarkerInfoBox(_selectedMarkerIndex),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to build map control buttons
  Widget _buildMapButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          splashColor: const Color(0XFF4CAF93).withOpacity(0.3),
          highlightColor: const Color(0XFF4CAF93).withOpacity(0.1),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: Icon(
              icon, 
              color: const Color(0xFF003366),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
  
  // Custom marker widget with animation effects
  Widget _buildMarkerIcon(int index) {
    final bool isSelected = _selectedMarkerIndex == index;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      transform: Matrix4.translationValues(0, isSelected ? -8 : 0, 0), // Move up when selected
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Shadow effect
          if (isSelected)
            Container(
              width: 10,
              height: 3,
              margin: const EdgeInsets.only(top: 40),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          
          // Pin icon
          Icon(
            Icons.location_on_rounded,
            color: isSelected 
                ? const Color(0xFF003366) 
                : const Color(0XFF4CAF93),
            size: isSelected ? 40 : 32,
            shadows: isSelected 
                ? [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ] 
                : null,
          ),
          
          // Status indicator dot
          if (_markers[index]['status'] == 'Active')
            Positioned(
              top: 2,
              right: isSelected ? 6 : 4,
              child: Container(
                width: isSelected ? 10 : 8,
                height: isSelected ? 10 : 8,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
            
          // Standby indicator dot  
          if (_markers[index]['status'] == 'Standby')
            Positioned(
              top: 2,
              right: isSelected ? 6 : 4,
              child: Container(
                width: isSelected ? 10 : 8,
                height: isSelected ? 10 : 8,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  // Animated info box that appears when a marker is selected
  Widget _buildMarkerInfoBox(int index) {
    final marker = _markers[index];
    
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    marker['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003366),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: marker['status'] == 'Active' 
                        ? const Color(0XFF4CAF93) 
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    marker['status'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                // Close button
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  onPressed: () {
                    setState(() => _selectedMarkerIndex = -1);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              marker['description'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate option
                  },
                  icon: const Icon(Icons.directions, size: 16),
                  label: const Text('Directions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                ),
                TextButton.icon(
        onPressed: () {
                    // Details option
                  },
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('Details'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF003366),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
