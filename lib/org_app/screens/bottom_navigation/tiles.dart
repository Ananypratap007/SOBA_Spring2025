import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'EmergencyDetailsScreen.dart'; // Ensure this file exists

const double dfInsets = 20;
const double dfRadius = 20;
const Color blue = Color(0xff003366);
const Color teal = Color(0xff03DAA2);

class TilesScreen extends StatefulWidget {
  const TilesScreen({super.key});

  @override
  State<TilesScreen> createState() => _TilesScreenState();
}

class _TilesScreenState extends State<TilesScreen> {
  final MapController _mapController = MapController();
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  static const LatLng _dfLocation = LatLng(35.2043, -97.4453);
  static const double _dfZoom = 9.0;

  List<Responder> responders = [];

  @override
  void initState() {
    super.initState();
    _loadResponders();
  }

  Future<void> _loadResponders() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    // Get current user's document
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
    if (userDoc.exists && userDoc.data() != null) {
      final userData = userDoc.data()!;
      // Get active organization id from either field
      final activeOrg = userData['orgId'] ?? userData['organizationId'];
      if (activeOrg != null) {
        // Query for users with 'orgId' equal to activeOrg
        final query1 = await FirebaseFirestore.instance
            .collection('users')
            .where('orgId', isEqualTo: activeOrg)
            .get();
        // Also query for users with 'organizationId' equal to activeOrg
        final query2 = await FirebaseFirestore.instance
            .collection('users')
            .where('organizationId', isEqualTo: activeOrg)
            .get();
        // Merge results (avoid duplicates)
        final docs = [...query1.docs, ...query2.docs];
        // Remove duplicates by document ID and filter out the current user's document
        final uniqueDocs = {
          for (var doc in docs) if (doc.id != currentUser.uid) doc.id: doc
        }.values.toList();
        setState(() {
          responders = uniqueDocs.map((doc) {
            final data = doc.data();
            GeoPoint geoPoint = data['coordinates'];
            return Responder(
              id: doc.id,
              visitId: data['visitId'] ?? '',
              name: data['name'] ?? 'Unknown',
              lat: geoPoint.latitude,
              lng: geoPoint.longitude,
              loc: data['location'] ?? 'Unknown location',
              status: data['status'] ?? 'UNACTIVE',
              image: data['profileImage'] ?? 'https://via.placeholder.com/150',
            );
          }).toList();
        });
      }
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.place), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.fromLTRB(dfInsets, 2.5 * dfInsets, dfInsets, dfInsets),
                color: blue,
                child: Row(
                  children: [
                    FloatingActionButton(
                      onPressed: () {
                        _mapController.move(_dfLocation, _dfZoom);
                      },
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.my_location, color: blue),
                    ),
                    const Spacer(),
                    const _SearchBar(blue),
                  ],
                ),
              ),
              Expanded(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _dfLocation,
                    initialZoom: _dfZoom,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.soba.app',
                    ),
                    MarkerLayer(
                      markers: responders.map<Marker>((responder) {
                        return Marker(
                          point: LatLng(responder.lat, responder.lng),
                          width: 50,
                          height: 50,
                          child: GestureDetector(
                            onTap: () {
                              _mapController.move(LatLng(responder.lat, responder.lng), _dfZoom + 5);
                              // Optionally, show details in a dialog
                            },
                            child: CircleAvatar(
                              radius: dfRadius / 1.15,
                              backgroundImage: NetworkImage(responder.image),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.2,
            minChildSize: 0.2,
            maxChildSize: 0.7,
            snap: true,
            snapSizes: const [0.2, 0.4, 0.7],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: responders.length,
                  itemBuilder: (context, index) => _ResponderTile(
                    responder: responders[index],
                    onTap: () {
                      _mapController.move(LatLng(responders[index].lat, responders[index].lng), _dfZoom + 5);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class Responder {
  final String id;
  final String visitId;
  final String name;
  final double lat;
  final double lng;
  final String loc;
  final String status;
  final String image;

  Responder({
    required this.id,
    this.visitId = '',
    required this.name,
    required this.lat,
    required this.lng,
    required this.loc,
    required this.status,
    required this.image,
  });
}

class _ResponderTile extends StatefulWidget {
  final Responder responder;
  final VoidCallback? onTap;

  const _ResponderTile({super.key, required this.responder, this.onTap});

  @override
  State<_ResponderTile> createState() => _ResponderTileState();
}

class _ResponderTileState extends State<_ResponderTile> {
  String locationName = "Fetching location...";

  @override
  void initState() {
    super.initState();
    _fetchLocationName();
  }

  Future<void> _fetchLocationName() async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(widget.responder.lat, widget.responder.lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          locationName = "${place.locality}, ${place.administrativeArea}";
        });
      }
    } catch (e) {
      setState(() {
        locationName = widget.responder.loc;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // If emergency, navigate to EmergencyDetailsScreen; otherwise, call the provided onTap.
        if (widget.responder.status.toUpperCase() == "EMERGENCY") {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => EmergencyDetailsScreen(
              responderId: widget.responder.id,
              visitId: widget.responder.visitId,
            ),
          ));
        } else {
          if (widget.onTap != null) {
            widget.onTap!();
          }
        }
      },
      borderRadius: BorderRadius.circular(dfRadius),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dfRadius),
        ),
        color: (widget.responder.status.toUpperCase() == "EMERGENCY") ? Colors.red : blue,
        child: Padding(
          padding: const EdgeInsets.all(dfInsets),
          child: Row(
            children: [
              CircleAvatar(
                radius: 2 * dfRadius,
                backgroundImage: NetworkImage(widget.responder.image),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Responder's name.
                    Text(
                      widget.responder.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    // Responder's status.
                    Text(
                      "Status: ${widget.responder.status.toUpperCase()}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: (widget.responder.status.toUpperCase() == "ON SCENE")
                            ? Colors.green
                            : Colors.white,
                      ),
                    ),
                    // Location.
                    Text(
                      "Location: $locationName",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final Color color;
  const _SearchBar(this.color);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 0.7 * MediaQuery.of(context).size.width,
      child: TextFormField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          focusColor: color,
          border: _border(const Color(0xFFF2F2F7)),
          enabledBorder: _border(const Color(0xFFF2F2F7)),
          hintText: 'Search here...',
          contentPadding: const EdgeInsets.symmetric(vertical: dfInsets / 2),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
        ),
        onFieldSubmitted: (value) {},
      ),
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderSide: BorderSide(width: 0.5, color: color),
        borderRadius: BorderRadius.circular(dfRadius),
      );
}
