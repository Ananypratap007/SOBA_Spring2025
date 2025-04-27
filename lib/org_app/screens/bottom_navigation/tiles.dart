// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import 'package:firebase_auth/firebase_auth.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_map/flutter_map.dart';
// // // import 'package:latlong2/latlong.dart';
// // // import 'package:geocoding/geocoding.dart';
// // // import 'package:soba_app/org_app/screens/activities/emergency_details_screen.dart';

// // // const double dfInsets = 20;
// // // const double dfRadius = 20;
// // // const Color blue = Color(0xff003366);
// // // const Color teal = Color(0xff03DAA2);

// // // class TilesScreen extends StatefulWidget {
// // //   const TilesScreen({super.key});

// // //   @override
// // //   State<TilesScreen> createState() => _TilesScreenState();
// // // }

// // // class _TilesScreenState extends State<TilesScreen> {
// // //   final MapController _mapController = MapController();
// // //   final DraggableScrollableController _sheetController =
// // //       DraggableScrollableController();

// // //   static const LatLng _dfLocation = LatLng(35.2043, -97.4453);
// // //   static const double _dfZoom = 9.0;

// // //   List<Responder> responders = [];

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _loadResponders();
// // //   }

// // //   Future<void> _loadResponders() async {
// // //     final currentUser = FirebaseAuth.instance.currentUser;
// // //     if (currentUser == null) return;
// // //     // Get current user's document
// // //     final userDoc = await FirebaseFirestore.instance
// // //         .collection('users')
// // //         .doc(currentUser.uid)
// // //         .get();
// // //     if (userDoc.exists && userDoc.data() != null) {
// // //       final userData = userDoc.data()!;
// // //       // Get active organization id from either field
// // //       final activeOrg = userData['orgId'] ?? userData['organizationId'];
// // //       if (activeOrg != null) {
// // //         // Query for users with 'orgId' equal to activeOrg
// // //         final query1 = await FirebaseFirestore.instance
// // //             .collection('users')
// // //             .where('orgId', isEqualTo: activeOrg)
// // //             .get();
// // //         // Also query for users with 'organizationId' equal to activeOrg
// // //         final query2 = await FirebaseFirestore.instance
// // //             .collection('users')
// // //             .where('organizationId', isEqualTo: activeOrg)
// // //             .get();
// // //         // Merge results (avoid duplicates)
// // //         final docs = [...query1.docs, ...query2.docs];
// // //         // Remove duplicates by document ID and filter out the current user's document
// // //         final uniqueDocs = {
// // //           for (var doc in docs)
// // //             if (doc.id != currentUser.uid) doc.id: doc
// // //         }.values.toList();
// // //         setState(() {
// // //           responders = uniqueDocs.map((doc) {
// // //             final data = doc.data();
// // //             GeoPoint geoPoint = data['coordinates'];
// // //             return Responder(
// // //               id: doc.id,
// // //               visitId: data['visitId'] ?? '',
// // //               name: data['name'] ?? 'Unknown',
// // //               lat: geoPoint.latitude,
// // //               lng: geoPoint.longitude,
// // //               loc: data['location'] ?? 'Unknown location',
// // //               status: data['status'] ?? 'UNACTIVE',
// // //               image: data['profileImage'] ?? 'https://via.placeholder.com/150',
// // //             );
// // //           }).toList();
// // //         });
// // //       }
// // //     }
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _mapController.dispose();
// // //     _sheetController.dispose();
// // //     super.dispose();
// // //   }

// // // // Function to show the Responder Information:
// // //   void _showResponderDetails(BuildContext context, Responder responder) {
// // //     showModalBottomSheet(
// // //       context: context,
// // //       isScrollControlled: true,
// // //       backgroundColor: Colors.transparent,
// // //       builder: (context) => Container(
// // //         height: MediaQuery.of(context).size.height * 0.9,
// // //         decoration: const BoxDecoration(
// // //           color: Colors.white,
// // //           borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
// // //         ),
// // //         child: Column(
// // //           children: [
// // //             // Header with close button
// // //             Container(
// // //               padding: const EdgeInsets.all(16),
// // //               decoration: BoxDecoration(
// // //                 color: responder.status.toUpperCase() == "EMERGENCY"
// // //                     ? Colors.red
// // //                     : blue, // Make sure `blue` is defined in your scope
// // //                 borderRadius: const BorderRadius.vertical(
// // //                   top: Radius.circular(30),
// // //                 ),
// // //               ),
// // //               child: Row(
// // //                 children: [
// // //                   IconButton(
// // //                     icon: const Icon(Icons.close, color: Colors.white),
// // //                     onPressed: () => Navigator.pop(context),
// // //                   ),
// // //                   Expanded(
// // //                     child: Text(
// // //                       responder.name,
// // //                       style: const TextStyle(
// // //                         color: Colors.white,
// // //                         fontSize: 20,
// // //                         fontWeight: FontWeight.bold,
// // //                       ),
// // //                       textAlign: TextAlign.center,
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //             // Emergency details content
// // //             Expanded(
// // //               child: EmergencyDetailsScreen(
// // //                 responderId: responder.id,
// // //                 visitId: responder.visitId,
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       body: Stack(
// // //         children: [
// // //           Column(
// // //             children: [
// // //               Container(
// // //                 width: MediaQuery.of(context).size.width,
// // //                 padding: const EdgeInsets.fromLTRB(
// // //                     dfInsets, 2.5 * dfInsets, dfInsets, dfInsets),
// // //                 color: blue,
// // //                 child: Row(
// // //                   children: [
// // //                     FloatingActionButton(
// // //                       onPressed: () {
// // //                         _mapController.move(_dfLocation, _dfZoom);
// // //                       },
// // //                       backgroundColor: Colors.white,
// // //                       child: const Icon(Icons.my_location, color: blue),
// // //                     ),
// // //                     const Spacer(),
// // //                     const _SearchBar(blue),
// // //                   ],
// // //                 ),
// // //               ),
// // //               Expanded(
// // //                 child: FlutterMap(
// // //                   mapController: _mapController,
// // //                   options: MapOptions(
// // //                     initialCenter: _dfLocation,
// // //                     initialZoom: _dfZoom,
// // //                     maxZoom: 18.0,
// // //                   ),
// // //                   children: [
// // //                     TileLayer(
// // //                       urlTemplate:
// // //                           'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
// // //                       subdomains: const ['a', 'b', 'c'],
// // //                       userAgentPackageName: 'com.soba.app',
// // //                     ),
// // //                     MarkerLayer(
// // //                       markers: responders.map<Marker>((responder) {
// // //                         return Marker(
// // //                           point: LatLng(responder.lat, responder.lng),
// // //                           width: 50,
// // //                           height: 50,
// // //                           child: GestureDetector(
// // //                             onTap: () {
// // //                               _mapController.move(
// // //                                   LatLng(responder.lat, responder.lng),
// // //                                   _dfZoom + 5);
// // //                               // Optionally, show details in a dialog
// // //                             },
// // //                             child: CircleAvatar(
// // //                               radius: dfRadius / 1.15,
// // //                               backgroundImage: NetworkImage(responder.image),
// // //                             ),
// // //                           ),
// // //                         );
// // //                       }).toList(),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //           DraggableScrollableSheet(
// // //             controller: _sheetController,
// // //             initialChildSize: 0.2,
// // //             minChildSize: 0.2,
// // //             maxChildSize: 0.7,
// // //             snap: true,
// // //             snapSizes: const [0.2, 0.4, 0.7],
// // //             builder: (context, scrollController) {
// // //               return Container(
// // //                 decoration: const BoxDecoration(
// // //                   color: Colors.white,
// // //                   borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
// // //                 ),
// // //                 child: ListView.builder(
// // //                   controller: scrollController,
// // //                   padding: const EdgeInsets.all(8.0),
// // //                   itemCount: responders.length,
// // //                   itemBuilder: (context, index) => _ResponderTile(
// // //                     responder: responders[index],
// // //                     onTap: () {
// // //                       // Move the map to the responder's location
// // //                       _mapController.move(
// // //                         LatLng(responders[index].lat, responders[index].lng),
// // //                         _dfZoom + 5,
// // //                       );

// // //                       // Show the responder's details in a modal bottom sheet
// // //                       _showResponderDetails(context, responders[index]);
// // //                     },
// // //                   ),
// // //                 ),
// // //               );
// // //             },
// // //           ),
// // //           // DraggableScrollableSheet(
// // //           //   controller: _sheetController,
// // //           //   initialChildSize: 0.2,
// // //           //   minChildSize: 0.2,
// // //           //   maxChildSize: 0.7,
// // //           //   snap: true,
// // //           //   snapSizes: const [0.2, 0.4, 0.7],
// // //           //   builder: (context, scrollController) {
// // //           //     return Container(
// // //           //       decoration: const BoxDecoration(
// // //           //         color: Colors.white,
// // //           //         borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
// // //           //       ),
// // //           //       child: ListView.builder(
// // //           //         controller: scrollController,
// // //           //         padding: const EdgeInsets.all(8.0),
// // //           //         itemCount: responders.length,
// // //           //         itemBuilder: (context, index) => _ResponderTile(
// // //           //           responder: responders[index],
// // //           //           onTap: () {
// // //           //             _mapController.move(
// // //           //                 LatLng(responders[index].lat, responders[index].lng),
// // //           //                 _dfZoom + 5);
// // //           //           },
// // //           //         ),
// // //           //       ),
// // //           //     );
// // //           //   },
// // //           // ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }

// // // class Responder {
// // //   final String id;
// // //   final String visitId;
// // //   final String name;
// // //   final double lat;
// // //   final double lng;
// // //   final String loc;
// // //   final String status;
// // //   final String image;

// // //   Responder({
// // //     required this.id,
// // //     this.visitId = '',
// // //     required this.name,
// // //     required this.lat,
// // //     required this.lng,
// // //     required this.loc,
// // //     required this.status,
// // //     required this.image,
// // //   });
// // // }

// // // class _ResponderTile extends StatefulWidget {
// // //   final Responder responder;
// // //   final VoidCallback? onTap;

// // //   const _ResponderTile({super.key, required this.responder, this.onTap});

// // //   @override
// // //   State<_ResponderTile> createState() => _ResponderTileState();
// // // }

// // // class _ResponderTileState extends State<_ResponderTile> {
// // //   String locationName = "Fetching location...";

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _fetchLocationName();
// // //   }

// // //   Future<void> _fetchLocationName() async {
// // //     try {
// // //       List<Placemark> placemarks = await placemarkFromCoordinates(
// // //           widget.responder.lat, widget.responder.lng);
// // //       if (placemarks.isNotEmpty) {
// // //         Placemark place = placemarks.first;
// // //         setState(() {
// // //           locationName = "${place.locality}, ${place.administrativeArea}";
// // //         });
// // //       }
// // //     } catch (e) {
// // //       setState(() {
// // //         locationName = widget.responder.loc;
// // //       });
// // //     }
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return InkWell(
// // //       onTap: () {
// // //         // If emergency, navigate to EmergencyDetailsScreen; otherwise, call the provided onTap.
// // //         if (widget.responder.status.toUpperCase() == "EMERGENCY") {
// // //           Navigator.of(context).push(MaterialPageRoute(
// // //             builder: (_) => EmergencyDetailsScreen(
// // //               responderId: widget.responder.id,
// // //               visitId: widget.responder.visitId,
// // //             ),
// // //           ));
// // //         } else {
// // //           if (widget.onTap != null) {
// // //             widget.onTap!();
// // //           }
// // //         }
// // //       },
// // //       borderRadius: BorderRadius.circular(dfRadius),
// // //       child: Card(
// // //         shape: RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.circular(dfRadius),
// // //         ),
// // //         color: (widget.responder.status.toUpperCase() == "EMERGENCY")
// // //             ? Colors.red
// // //             : blue,
// // //         child: Padding(
// // //           padding: const EdgeInsets.all(dfInsets),
// // //           child: Row(
// // //             children: [
// // //               CircleAvatar(
// // //                 radius: 2 * dfRadius,
// // //                 backgroundImage: NetworkImage(widget.responder.image),
// // //               ),
// // //               const SizedBox(width: 10),
// // //               Expanded(
// // //                 child: Column(
// // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // //                   children: [
// // //                     // Responder's name.
// // //                     Text(
// // //                       widget.responder.name,
// // //                       style: const TextStyle(
// // //                         fontSize: 18,
// // //                         fontWeight: FontWeight.bold,
// // //                         color: Colors.white,
// // //                       ),
// // //                     ),
// // //                     // Responder's status.
// // //                     Text(
// // //                       "Status: ${widget.responder.status.toUpperCase()}",
// // //                       style: TextStyle(
// // //                         fontSize: 14,
// // //                         fontWeight: FontWeight.bold,
// // //                         color: (widget.responder.status.toUpperCase() ==
// // //                                 "ON SCENE")
// // //                             ? Colors.green
// // //                             : Colors.white,
// // //                       ),
// // //                     ),
// // //                     // Location.
// // //                     Text(
// // //                       "Location: $locationName",
// // //                       style: const TextStyle(
// // //                         fontSize: 12,
// // //                         color: Colors.white70,
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }

// // // class _SearchBar extends StatelessWidget {
// // //   final Color color;
// // //   const _SearchBar(this.color);

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return SizedBox(
// // //       width: 0.7 * MediaQuery.of(context).size.width,
// // //       child: TextFormField(
// // //         decoration: InputDecoration(
// // //           filled: true,
// // //           fillColor: Colors.white,
// // //           focusColor: color,
// // //           border: _border(const Color(0xFFF2F2F7)),
// // //           enabledBorder: _border(const Color(0xFFF2F2F7)),
// // //           hintText: 'Search here...',
// // //           contentPadding: const EdgeInsets.symmetric(vertical: dfInsets / 2),
// // //           prefixIcon: const Icon(Icons.search, color: Colors.grey),
// // //         ),
// // //         onFieldSubmitted: (value) {},
// // //       ),
// // //     );
// // //   }

// // //   OutlineInputBorder _border(Color color) => OutlineInputBorder(
// // //         borderSide: BorderSide(width: 0.5, color: color),
// // //         borderRadius: BorderRadius.circular(dfRadius),
// // //       );
// // // }

// // // tiles_screen.dart (UPDATED with ResponderTile)
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_map/flutter_map.dart';
// // import 'package:latlong2/latlong.dart';
// // import 'package:geocoding/geocoding.dart';
// // import 'package:soba_app/org_app/screens/activities/emergency_details_screen.dart';

// // const double dfInsets = 20;
// // const double dfRadius = 20;
// // const Color blue = Color(0xff003366);
// // const Color teal = Color(0xff03DAA2);

// // class TilesScreen extends StatefulWidget {
// //   const TilesScreen({super.key});

// //   @override
// //   State<TilesScreen> createState() => _TilesScreenState();
// // }

// // class _TilesScreenState extends State<TilesScreen> {
// //   final MapController _mapController = MapController();
// //   final DraggableScrollableController _sheetController =
// //       DraggableScrollableController();

// //   static const LatLng _dfLocation = LatLng(35.2043, -97.4453);
// //   static const double _dfZoom = 9.0;

// //   List<Responder> responders = [];

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadResponders();
// //   }

// //   Future<void> _loadResponders() async {
// //     final currentUser = FirebaseAuth.instance.currentUser;
// //     if (currentUser == null) return;

// //     final userDoc = await FirebaseFirestore.instance
// //         .collection('users')
// //         .doc(currentUser.uid)
// //         .get();
// //     if (userDoc.exists && userDoc.data() != null) {
// //       final userData = Map<String, dynamic>.from(userDoc.data()!);
// //       final activeOrg = userData['orgId'] ?? userData['organizationId'];

// //       if (activeOrg != null) {
// //         final query1 = await FirebaseFirestore.instance
// //             .collection('users')
// //             .where('orgId', isEqualTo: activeOrg)
// //             .get();

// //         final query2 = await FirebaseFirestore.instance
// //             .collection('users')
// //             .where('organizationId', isEqualTo: activeOrg)
// //             .get();

// //         final docs = [...query1.docs, ...query2.docs];
// //         final uniqueDocs = {
// //           for (var doc in docs)
// //             if (doc.id != currentUser.uid) doc.id: doc
// //         }.values.toList();

// //         setState(() {
// //           responders = uniqueDocs.map((doc) {
// //             final data = Map<String, dynamic>.from(doc.data());
// //             GeoPoint geoPoint = data['coordinates'];
// //             return Responder(
// //               id: doc.id,
// //               visitId: data['visitId'] ?? '',
// //               name: data['name'] ?? 'Unknown',
// //               lat: geoPoint.latitude,
// //               lng: geoPoint.longitude,
// //               loc: data['location'] ?? 'Unknown location',
// //               status: data['status'] ?? 'UNACTIVE',
// //               image: data['profileImage'] ?? 'https://via.placeholder.com/150',
// //             );
// //           }).toList();
// //         });
// //       }
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _mapController.dispose();
// //     _sheetController.dispose();
// //     super.dispose();
// //   }

// //   void _showResponderDetails(BuildContext context, Responder responder) {
// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: Colors.transparent,
// //       builder: (context) => Container(
// //         height: MediaQuery.of(context).size.height * 0.9,
// //         decoration: const BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
// //         ),
// //         child: Column(
// //           children: [
// //             Container(
// //               padding: const EdgeInsets.all(16),
// //               decoration: BoxDecoration(
// //                 color: responder.status.toUpperCase() == "EMERGENCY"
// //                     ? Colors.red
// //                     : blue,
// //                 borderRadius:
// //                     const BorderRadius.vertical(top: Radius.circular(30)),
// //               ),
// //               child: Row(
// //                 children: [
// //                   IconButton(
// //                     icon: const Icon(Icons.close, color: Colors.white),
// //                     onPressed: () => Navigator.pop(context),
// //                   ),
// //                   Expanded(
// //                     child: Text(
// //                       responder.name,
// //                       style: const TextStyle(
// //                         color: Colors.white,
// //                         fontSize: 20,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                       textAlign: TextAlign.center,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             Expanded(
// //               child: EmergencyDetailsScreen(
// //                 responderId: responder.id,
// //                 visitId: responder.visitId,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Stack(
// //         children: [
// //           Column(
// //             children: [
// //               Container(
// //                 width: MediaQuery.of(context).size.width,
// //                 padding: const EdgeInsets.fromLTRB(
// //                     dfInsets, 2.5 * dfInsets, dfInsets, dfInsets),
// //                 color: blue,
// //                 child: Row(
// //                   children: [
// //                     FloatingActionButton(
// //                       onPressed: () =>
// //                           _mapController.move(_dfLocation, _dfZoom),
// //                       backgroundColor: Colors.white,
// //                       child: const Icon(Icons.my_location, color: blue),
// //                     ),
// //                     const Spacer(),
// //                     const _SearchBar(blue),
// //                   ],
// //                 ),
// //               ),
// //               Expanded(
// //                 child: FlutterMap(
// //                   mapController: _mapController,
// //                   options: MapOptions(
// //                     initialCenter: _dfLocation,
// //                     initialZoom: _dfZoom,
// //                     maxZoom: 18.0,
// //                   ),
// //                   children: [
// //                     TileLayer(
// //                       urlTemplate:
// //                           'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
// //                       subdomains: const ['a', 'b', 'c'],
// //                       userAgentPackageName: 'com.soba.app',
// //                     ),
// //                     MarkerLayer(
// //                       markers: responders.map((responder) {
// //                         return Marker(
// //                           point: LatLng(responder.lat, responder.lng),
// //                           width: 50,
// //                           height: 50,
// //                           child: GestureDetector(
// //                             onTap: () => _mapController.move(
// //                                 LatLng(responder.lat, responder.lng),
// //                                 _dfZoom + 5),
// //                             child: CircleAvatar(
// //                               radius: dfRadius / 1.15,
// //                               backgroundImage: NetworkImage(responder.image),
// //                             ),
// //                           ),
// //                         );
// //                       }).toList(),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //           DraggableScrollableSheet(
// //             controller: _sheetController,
// //             initialChildSize: 0.2,
// //             minChildSize: 0.2,
// //             maxChildSize: 0.7,
// //             snap: true,
// //             snapSizes: const [0.2, 0.4, 0.7],
// //             builder: (context, scrollController) {
// //               return Container(
// //                 decoration: const BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
// //                 ),
// //                 child: ListView.builder(
// //                   controller: scrollController,
// //                   padding: const EdgeInsets.all(8.0),
// //                   itemCount: responders.length,
// //                   itemBuilder: (context, index) => _ResponderTile(
// //                     responder: responders[index],
// //                     onTap: () {
// //                       _mapController.move(
// //                           LatLng(responders[index].lat, responders[index].lng),
// //                           _dfZoom + 5);
// //                       _showResponderDetails(context, responders[index]);
// //                     },
// //                   ),
// //                 ),
// //               );
// //             },
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class Responder {
// //   final String id;
// //   final String visitId;
// //   final String name;
// //   final double lat;
// //   final double lng;
// //   final String loc;
// //   final String status;
// //   final String image;

// //   Responder({
// //     required this.id,
// //     this.visitId = '',
// //     required this.name,
// //     required this.lat,
// //     required this.lng,
// //     required this.loc,
// //     required this.status,
// //     required this.image,
// //   });
// // }

// // class _ResponderTile extends StatefulWidget {
// //   final Responder responder;
// //   final VoidCallback? onTap;

// //   const _ResponderTile({super.key, required this.responder, this.onTap});

// //   @override
// //   State<_ResponderTile> createState() => _ResponderTileState();
// // }

// // class _ResponderTileState extends State<_ResponderTile>
// //     with SingleTickerProviderStateMixin {
// //   String locationName = "Fetching location...";
// //   late AnimationController _animationController;
// //   late Animation<Color?> _colorAnimation;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchLocationName();

// //     if (widget.responder.status.toLowerCase() == "emergency-responded") {
// //       _animationController = AnimationController(
// //         duration: const Duration(milliseconds: 800),
// //         vsync: this,
// //       )..repeat(reverse: true);

// //       _colorAnimation = ColorTween(
// //         begin: Colors.orange.shade700,
// //         end: Colors.orange.shade300,
// //       ).animate(_animationController);
// //     } else {
// //       _animationController = AnimationController(
// //         vsync: this,
// //         duration: const Duration(milliseconds: 0),
// //       );
// //       _colorAnimation = AlwaysStoppedAnimation<Color?>(Colors.red);
// //     }
// //   }

// //   Future<void> _fetchLocationName() async {
// //     try {
// //       List<Placemark> placemarks = await placemarkFromCoordinates(
// //           widget.responder.lat, widget.responder.lng);
// //       if (placemarks.isNotEmpty) {
// //         Placemark place = placemarks.first;
// //         setState(() {
// //           locationName = "${place.locality}, ${place.administrativeArea}";
// //         });
// //       }
// //     } catch (_) {
// //       setState(() {
// //         locationName = widget.responder.loc;
// //       });
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _animationController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return InkWell(
// //       onTap: () {
// //         if (widget.onTap != null) {
// //           widget.onTap!();
// //         }
// //       },
// //       borderRadius: BorderRadius.circular(dfRadius),
// //       child: AnimatedBuilder(
// //         animation: _animationController,
// //         builder: (context, child) {
// //           Color cardColor;
// //           if (widget.responder.status.toUpperCase() == "EMERGENCY") {
// //             cardColor = Colors.red;
// //           } else if (widget.responder.status.toUpperCase() ==
// //               "EMERGENCY-RESPONDED") {
// //             cardColor = _colorAnimation.value ?? Colors.orange;
// //           } else {
// //             cardColor = blue;
// //           }

// //           return Card(
// //             shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(dfRadius),
// //             ),
// //             color: cardColor,
// //             child: Padding(
// //               padding: const EdgeInsets.all(dfInsets),
// //               child: Row(
// //                 children: [
// //                   CircleAvatar(
// //                     radius: 2 * dfRadius,
// //                     backgroundImage: NetworkImage(widget.responder.image),
// //                   ),
// //                   const SizedBox(width: 10),
// //                   Expanded(
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text(
// //                           widget.responder.name,
// //                           style: const TextStyle(
// //                             fontSize: 18,
// //                             fontWeight: FontWeight.bold,
// //                             color: Colors.white,
// //                           ),
// //                         ),
// //                         Text(
// //                           "Status: ${widget.responder.status.toUpperCase()}",
// //                           style: const TextStyle(
// //                             fontSize: 14,
// //                             fontWeight: FontWeight.bold,
// //                             color: Colors.white,
// //                           ),
// //                         ),
// //                         Text(
// //                           "Location: $locationName",
// //                           style: const TextStyle(
// //                             fontSize: 12,
// //                             color: Colors.white70,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }

// // class _SearchBar extends StatelessWidget {
// //   final Color color;
// //   const _SearchBar(this.color);

// //   @override
// //   Widget build(BuildContext context) {
// //     return SizedBox(
// //       width: 0.7 * MediaQuery.of(context).size.width,
// //       child: TextFormField(
// //         decoration: InputDecoration(
// //           filled: true,
// //           fillColor: Colors.white,
// //           focusColor: color,
// //           border: _border(const Color(0xFFF2F2F7)),
// //           enabledBorder: _border(const Color(0xFFF2F2F7)),
// //           hintText: 'Search here...',
// //           contentPadding: const EdgeInsets.symmetric(vertical: dfInsets / 2),
// //           prefixIcon: const Icon(Icons.search, color: Colors.grey),
// //         ),
// //         onFieldSubmitted: (value) {},
// //       ),
// //     );
// //   }

// //   OutlineInputBorder _border(Color color) => OutlineInputBorder(
// //         borderSide: BorderSide(width: 0.5, color: color),
// //         borderRadius: BorderRadius.circular(dfRadius),
// //       );
// // }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:soba_app/org_app/screens/activities/emergency_details_screen.dart';

// const double dfInsets = 20;
// const double dfRadius = 20;
// const Color blue = Color(0xff003366);
// const Color teal = Color(0xff03DAA2);

// class TilesScreen extends StatefulWidget {
//   const TilesScreen({super.key});

//   @override
//   State<TilesScreen> createState() => _TilesScreenState();
// }

// class _TilesScreenState extends State<TilesScreen> {
//   GoogleMapController? _mapController;
//   final DraggableScrollableController _sheetController =
//       DraggableScrollableController();

//   static const LatLng _dfLocation = LatLng(35.2043, -97.4453);
//   static const double _dfZoom = 12.0;

//   List<Responder> responders = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadResponders();
//   }

//   Future<void> _loadResponders() async {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;

//     final userDoc = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(currentUser.uid)
//         .get();
//     if (userDoc.exists && userDoc.data() != null) {
//       final userData = Map<String, dynamic>.from(userDoc.data()!);
//       final activeOrg = userData['orgId'] ?? userData['organizationId'];

//       if (activeOrg != null) {
//         final query1 = await FirebaseFirestore.instance
//             .collection('users')
//             .where('orgId', isEqualTo: activeOrg)
//             .get();

//         final query2 = await FirebaseFirestore.instance
//             .collection('users')
//             .where('organizationId', isEqualTo: activeOrg)
//             .get();

//         final docs = [...query1.docs, ...query2.docs];
//         final uniqueDocs = {
//           for (var doc in docs)
//             if (doc.id != currentUser.uid) doc.id: doc
//         }.values.toList();

//         setState(() {
//           responders = uniqueDocs.map((doc) {
//             final data = Map<String, dynamic>.from(doc.data());
//             GeoPoint geoPoint = data['coordinates'];
//             return Responder(
//               id: doc.id,
//               visitId: data['visitId'] ?? '',
//               name: data['name'] ?? 'Unknown',
//               lat: geoPoint.latitude,
//               lng: geoPoint.longitude,
//               loc: data['location'] ?? 'Unknown location',
//               status: data['status'] ?? 'UNACTIVE',
//               image: data['profileImage'] ?? 'https://via.placeholder.com/150',
//             );
//           }).toList();
//         });
//       }
//     }
//   }

//   void _showResponderDetails(BuildContext context, Responder responder) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         height: MediaQuery.of(context).size.height * 0.9,
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//         ),
//         child: Column(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: responder.status.toUpperCase() == "EMERGENCY"
//                     ? Colors.red
//                     : blue,
//                 borderRadius:
//                     const BorderRadius.vertical(top: Radius.circular(30)),
//               ),
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.close, color: Colors.white),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                   Expanded(
//                     child: Text(
//                       responder.name,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: EmergencyDetailsScreen(
//                 responderId: responder.id,
//                 visitId: responder.visitId,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Set<Marker> _buildMarkers() {
//     return responders.map((responder) {
//       return Marker(
//         markerId: MarkerId(responder.id),
//         position: LatLng(responder.lat, responder.lng),
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
//         onTap: () {
//           _mapController?.animateCamera(CameraUpdate.newLatLngZoom(
//               LatLng(responder.lat, responder.lng), _dfZoom + 3));
//           _showResponderDetails(context, responder);
//         },
//       );
//     }).toSet();
//   }

//   @override
//   void dispose() {
//     _sheetController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Container(
//                 width: MediaQuery.of(context).size.width,
//                 padding: const EdgeInsets.fromLTRB(
//                     dfInsets, 2.5 * dfInsets, dfInsets, dfInsets),
//                 color: blue,
//                 child: Row(
//                   children: [
//                     FloatingActionButton(
//                       onPressed: () {
//                         _mapController?.animateCamera(
//                           CameraUpdate.newLatLngZoom(_dfLocation, _dfZoom),
//                         );
//                       },
//                       backgroundColor: Colors.white,
//                       child: const Icon(Icons.my_location, color: blue),
//                     ),
//                     const Spacer(),
//                     const _SearchBar(blue),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: GoogleMap(
//                   initialCameraPosition: const CameraPosition(
//                     target: _dfLocation,
//                     zoom: _dfZoom,
//                   ),
//                   markers: _buildMarkers(),
//                   onMapCreated: (controller) => _mapController = controller,
//                   myLocationEnabled: true,
//                   myLocationButtonEnabled: true,
//                   mapType: MapType.normal,
//                   zoomControlsEnabled: false,
//                 ),
//               ),
//             ],
//           ),
//           DraggableScrollableSheet(
//             controller: _sheetController,
//             initialChildSize: 0.2,
//             minChildSize: 0.2,
//             maxChildSize: 0.7,
//             snap: true,
//             snapSizes: const [0.2, 0.4, 0.7],
//             builder: (context, scrollController) {
//               return Container(
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//                 ),
//                 child: ListView.builder(
//                   controller: scrollController,
//                   padding: const EdgeInsets.all(8.0),
//                   itemCount: responders.length,
//                   itemBuilder: (context, index) => _ResponderTile(
//                     responder: responders[index],
//                     onTap: () {
//                       _mapController?.animateCamera(
//                         CameraUpdate.newLatLngZoom(
//                             LatLng(
//                                 responders[index].lat, responders[index].lng),
//                             _dfZoom + 3),
//                       );
//                       _showResponderDetails(context, responders[index]);
//                     },
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class Responder {
//   final String id;
//   final String visitId;
//   final String name;
//   final double lat;
//   final double lng;
//   final String loc;
//   final String status;
//   final String image;

//   Responder({
//     required this.id,
//     this.visitId = '',
//     required this.name,
//     required this.lat,
//     required this.lng,
//     required this.loc,
//     required this.status,
//     required this.image,
//   });
// }

// // _ResponderTile widget stays the same as you already have it
// // _SearchBar widget stays the same too

// class _SearchBar extends StatelessWidget {
//   final Color color;
//   const _SearchBar(this.color);

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 0.7 * MediaQuery.of(context).size.width,
//       child: TextFormField(
//         decoration: InputDecoration(
//           filled: true,
//           fillColor: Colors.white,
//           focusColor: color,
//           border: _border(const Color(0xFFF2F2F7)),
//           enabledBorder: _border(const Color(0xFFF2F2F7)),
//           hintText: 'Search here...',
//           contentPadding: const EdgeInsets.symmetric(vertical: dfInsets / 2),
//           prefixIcon: const Icon(Icons.search, color: Colors.grey),
//         ),
//         onFieldSubmitted: (value) {},
//       ),
//     );
//   }

//   OutlineInputBorder _border(Color color) => OutlineInputBorder(
//         borderSide: BorderSide(width: 0.5, color: color),
//         borderRadius: BorderRadius.circular(dfRadius),
//       );
// }

// class _ResponderTile extends StatelessWidget {
//   final Responder responder;
//   final VoidCallback? onTap;

//   const _ResponderTile({super.key, required this.responder, this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(dfRadius),
//       child: Card(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(dfRadius),
//         ),
//         color: blue,
//         child: Padding(
//           padding: const EdgeInsets.all(dfInsets),
//           child: Row(
//             children: [
//               CircleAvatar(
//                 radius: 2 * dfRadius,
//                 backgroundImage: NetworkImage(responder.image),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       responder.name,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     Text(
//                       "Status: ${responder.status.toUpperCase()}",
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     Text(
//                       "Location: ${responder.loc}",
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: Colors.white70,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:soba_app/org_app/screens/activities/emergency_details_screen.dart';

const double dfInsets = 20;
const double dfRadius = 20;
const Color blue = Color(0xff003366);
late AnimationController _circleAnimationController;
late Animation<double> _circleOpacityAnimation;

class TilesScreen extends StatefulWidget {
  const TilesScreen({super.key});

  @override
  State<TilesScreen> createState() => _TilesScreenState();
}

class _TilesScreenState extends State<TilesScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  static const LatLng _dfLocation = LatLng(35.2043, -97.4453);
  static const double _dfZoom = 12.0;

  List<Responder> responders = [];

  @override
  void initState() {
    super.initState();
    _loadResponders();
    _circleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true); // Flicker forever
    _circleOpacityAnimation =
        Tween<double>(begin: 0.2, end: 0.5).animate(_circleAnimationController);
  }

  Future<List<LatLng>> fetchNearbyPoliceStations(LatLng location) async {
    final url = Uri.parse(
      "https://overpass-api.de/api/interpreter",
    );

    final query = """
    [out:json];
    (
      node["amenity"="police"](around:1000,${location.latitude},${location.longitude});
    );
    out body;
  """;

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {"data": query},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<LatLng> policeStations = [];

      for (var element in data['elements']) {
        policeStations.add(LatLng(
          element['lat'],
          element['lon'],
        ));
      }

      return policeStations;
    } else {
      throw Exception('Failed to load police stations');
    }
  }

  Future<void> _loadResponders() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    if (userDoc.exists && userDoc.data() != null) {
      final userData = Map<String, dynamic>.from(userDoc.data()!);
      final activeOrg = userData['orgId'] ?? userData['organizationId'];

      if (activeOrg != null) {
        final query1 = await FirebaseFirestore.instance
            .collection('users')
            .where('orgId', isEqualTo: activeOrg)
            .get();

        final query2 = await FirebaseFirestore.instance
            .collection('users')
            .where('organizationId', isEqualTo: activeOrg)
            .get();

        final docs = [...query1.docs, ...query2.docs];
        final uniqueDocs = {
          for (var doc in docs)
            if (doc.id != currentUser.uid) doc.id: doc
        }.values.toList();

        setState(() {
          responders = uniqueDocs.map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
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

  Set<Circle> _buildCircles() {
    return responders.map((responder) {
      double radius;
      Color fillColor;
      Color strokeColor;

      bool isEmergency = responder.status.toUpperCase() == "EMERGENCY" ||
          responder.status.toUpperCase() == "EMERGENCY-RESPONDED";

      radius = isEmergency ? 800 : 400;
      fillColor = isEmergency
          ? Colors.redAccent.withOpacity(_circleOpacityAnimation.value)
          : Colors.blueAccent.withOpacity(0.3);
      strokeColor = isEmergency ? Colors.red : Colors.blueAccent;

      return Circle(
        circleId: CircleId(responder.id),
        center: LatLng(responder.lat, responder.lng),
        radius: radius,
        fillColor: fillColor,
        strokeColor: strokeColor,
        strokeWidth: isEmergency ? 3 : 2,
      );
    }).toSet();
  }

  // void _handleSearch(String searchText) {
  //   if (searchText.trim().isEmpty) return;

  //   final normalizedText = searchText.trim().toLowerCase();
  //   final matchingResponder = responders.where((responder) {
  //     final status = responder.status.toLowerCase();
  //     return (status == 'on scene' ||
  //             status == 'emergency' ||
  //             status == 'emergency-responded') &&
  //         responder.name.toLowerCase().contains(normalizedText);
  //   }).toList();

  //   if (matchingResponder.isNotEmpty) {
  //     final responder = matchingResponder.first;
  //     _mapController?.animateCamera(
  //       CameraUpdate.newLatLngZoom(
  //         LatLng(responder.lat, responder.lng),
  //         _dfZoom + 5, // Zoom closer
  //       ),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Responder not found or not active')),
  //     );
  //   }
  // }

  Future<BitmapDescriptor> _getCustomMarker(String imageUrl) async {
    try {
      final http.Response response = await http.get(Uri.parse(imageUrl));
      final Uint8List bytes = response.bodyBytes;

      final ui.Codec codec =
          await ui.instantiateImageCodec(bytes, targetWidth: 150);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      final Paint paint = Paint();
      final double size = 150;

      // Draw a pin shape
      final Path pinPath = Path()
        ..moveTo(size / 2, size)
        ..quadraticBezierTo(size / 2 - 20, size * 0.7, size / 2, size * 0.4)
        ..quadraticBezierTo(size / 2 + 20, size * 0.7, size / 2, size)
        ..close();

      canvas.drawPath(pinPath, Paint()..color = Colors.blueAccent);

      // Draw the circular image on top
      paint.isAntiAlias = true;
      canvas.save();
      canvas.clipPath(Path()
        ..addOval(Rect.fromCircle(
            center: Offset(size / 2, size * 0.4), radius: size * 0.25)));
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromCircle(
            center: Offset(size / 2, size * 0.4), radius: size * 0.25),
        paint,
      );
      canvas.restore();

      final ui.Image finalImage =
          await recorder.endRecording().toImage(size.toInt(), size.toInt());
      final ByteData? byteData =
          await finalImage.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List resizedBytes = byteData!.buffer.asUint8List();

      return BitmapDescriptor.fromBytes(resizedBytes);
    } catch (e) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }
  }

  Future<Set<Marker>> _buildMarkers() async {
    Set<Marker> markers = {};

    for (var responder in responders) {
      final customIcon = await _getCustomMarker(responder.image);

      // Add responder marker
      markers.add(
        Marker(
          markerId: MarkerId(responder.id),
          position: LatLng(responder.lat, responder.lng),
          icon: customIcon,
          onTap: () {
            _mapController?.animateCamera(CameraUpdate.newLatLngZoom(
                LatLng(responder.lat, responder.lng), _dfZoom + 3));
            _showResponderDetails(context, responder);
          },
        ),
      );

      // Fetch and add nearby police stations (optional: only for emergency)
      if (responder.status.toUpperCase() == "EMERGENCY" ||
          responder.status.toUpperCase() == "EMERGENCY-RESPONDED") {
        final policeStations = await fetchNearbyPoliceStations(
            LatLng(responder.lat, responder.lng));

        for (var police in policeStations) {
          markers.add(
            Marker(
              markerId: MarkerId(
                  'police_${responder.id}_${police.latitude}_${police.longitude}'),
              position: police,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
              infoWindow: const InfoWindow(title: "Police Station"),
            ),
          );
        }
      }
    }
    return markers;
  }

  void _showResponderDetails(BuildContext context, Responder responder) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: responder.status.toUpperCase() == "EMERGENCY"
                    ? Colors.red
                    : blue,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      responder.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: EmergencyDetailsScreen(
                responderId: responder.id,
                visitId: responder.visitId,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.fromLTRB(
                    dfInsets, 2.5 * dfInsets, dfInsets, dfInsets),
                color: blue,
                child: Row(
                  children: [
                    FloatingActionButton(
                      onPressed: () {
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(_dfLocation, _dfZoom),
                        );
                      },
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.my_location, color: blue),
                    ),
                    const Spacer(),
                    _SearchBar(
                      blue,
                      responders: responders,
                      onSelected: (Responder responder) {
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(
                            LatLng(responder.lat, responder.lng),
                            _dfZoom + 5,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<Set<Marker>>(
                  future: _buildMarkers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return AnimatedBuilder(
                      animation: _circleAnimationController,
                      builder: (context, child) {
                        return GoogleMap(
                          initialCameraPosition: const CameraPosition(
                            target: _dfLocation,
                            zoom: _dfZoom,
                          ),
                          markers: snapshot.data ?? {},
                          circles: _buildCircles(), // <==== now animated
                          onMapCreated: (controller) =>
                              _mapController = controller,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          mapType: MapType.normal,
                          zoomControlsEnabled: false,
                        );
                      },
                    );
                  },
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
                    onViewDetails: () {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(responders[index].lat, responders[index].lng),
                          _dfZoom + 3,
                        ),
                      );
                      _showResponderDetails(context, responders[index]);
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
  final VoidCallback onViewDetails;

  const _ResponderTile({
    required this.responder,
    required this.onViewDetails,
  });

  @override
  State<_ResponderTile> createState() => _ResponderTileState();
}

class _ResponderTileState extends State<_ResponderTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  bool get isEmergencyOrResponded =>
      widget.responder.status.toUpperCase() == "EMERGENCY" ||
      widget.responder.status.toUpperCase() == "EMERGENCY-RESPONDED";

  @override
  void initState() {
    super.initState();

    if (widget.responder.status.toLowerCase() == "emergency-responded") {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      )..repeat(reverse: true);

      _colorAnimation = ColorTween(
        begin: Colors.orange.shade700,
        end: Colors.orange.shade300,
      ).animate(_animationController);
    } else {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 0),
        vsync: this,
      );
      _colorAnimation = AlwaysStoppedAnimation<Color?>(
          widget.responder.status.toUpperCase() == "EMERGENCY"
              ? Colors.red
              : blue);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTileTap() {
    if (isEmergencyOrResponded) {
      widget.onViewDetails(); // Only if emergency or responded
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleTileTap,
      borderRadius: BorderRadius.circular(dfRadius),
      child: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(dfRadius),
            ),
            color: _colorAnimation.value,
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
                        Text(
                          widget.responder.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Status: ${widget.responder.status.toUpperCase()}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Location: ${widget.responder.loc}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isEmergencyOrResponded) // Show "eye" button if NOT an emergency
                    IconButton(
                      icon: const Icon(Icons.visibility, color: Colors.white),
                      onPressed: widget.onViewDetails,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  final Color color;
  final List<Responder> responders;
  final void Function(Responder responder) onSelected;

  const _SearchBar(this.color,
      {required this.responders, required this.onSelected});

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final TextEditingController _controller = TextEditingController();

  List<String> get _searchableNames {
    return widget.responders
        .where((r) =>
            r.status.toLowerCase() == 'on scene' ||
            r.status.toLowerCase() == 'emergency' ||
            r.status.toLowerCase() == 'emergency-responded')
        .map((r) => r.name)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 0.7 * MediaQuery.of(context).size.width,
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<String>.empty();
          }
          return _searchableNames.where((name) =>
              name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
        },
        onSelected: (String selectedName) {
          final responder = widget.responders.firstWhere(
            (r) => r.name.toLowerCase() == selectedName.toLowerCase(),
          );
          widget.onSelected(responder);
          _controller.clear();
        },
        fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
          _controller.text = controller.text;
          return TextField(
            controller: controller,
            focusNode: focusNode,
            onEditingComplete: onEditingComplete,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              focusColor: widget.color,
              border: _border(const Color(0xFFF2F2F7)),
              enabledBorder: _border(const Color(0xFFF2F2F7)),
              hintText: 'Search responders...',
              contentPadding:
                  const EdgeInsets.symmetric(vertical: dfInsets / 2),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderSide: BorderSide(width: 0.5, color: color),
        borderRadius: BorderRadius.circular(dfRadius),
      );
}
