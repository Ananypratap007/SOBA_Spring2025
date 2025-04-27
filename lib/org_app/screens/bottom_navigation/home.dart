// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:go_router/go_router.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   String activeCount = "0";
//   String pendingCount = "0";
//   String completedCount = "0";

//   @override
//   void initState() {
//     super.initState();
//     _loadStatusCounts();
//   }

//   Future<void> _loadStatusCounts() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;

//     final userDoc = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(user.uid)
//         .get();

//     final userData = userDoc.data();
//     final String? orgId = userData?['orgId'] ?? userData?['organizationId'];

//     if (orgId == null) return;

//     final today = DateTime.now();
//     final todayString =
//         '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

//     final docRef = FirebaseFirestore.instance
//         .collection('daily_status_counts')
//         .doc(orgId)
//         .collection('dates')
//         .doc(todayString);

//     docRef.snapshots().listen((snapshot) {
//       if (snapshot.exists) {
//         final data = snapshot.data();
//         setState(() {
//           activeCount = (data?['active'] ?? 0).toString();
//           pendingCount = (data?['pending'] ?? 0).toString();
//           completedCount = (data?['completed'] ?? 0).toString();
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(60),
//         child: Container(
//           decoration: const BoxDecoration(
//             color: Color(0xFF003366),
//           ),
//           child: AppBar(
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             centerTitle: true,
//             title: const Text(
//               'Dashboard',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 25,
//               ),
//             ),
//           ),
//         ),
//       ),
//       body: ListView(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12.0),
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildSection(
//                         title: "Team Activity",
//                         child: Row(
//                           children: [
//                             Expanded(
//                               flex: 1,
//                               child: _StatItem(
//                                 title: "Active",
//                                 value: activeCount,
//                                 color: Color(0xFFFFF9C4),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               flex: 1,
//                               child: _StatItem(
//                                 title: "Pending",
//                                 value: pendingCount,
//                                 color: Color(0xFFFFF9C4),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               flex: 1,
//                               child: _StatItem(
//                                 title: "Done",
//                                 value: completedCount,
//                                 color: Color(0xFFFFF9C4),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 15),
//                       _buildSection(
//                         title: "Live Feed",
//                         child: Container(
//                           height: 320,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(45),
//                             border: Border.all(
//                               color: Color(0xFF003366),
//                               width: 2.5,
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.2),
//                                 blurRadius: 6,
//                                 spreadRadius: 2,
//                                 offset: Offset(0, 3),
//                               ),
//                             ],
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(42),
//                             child: FlutterMap(
//                               options: MapOptions(
//                                 initialCenter: LatLng(37.7749, -122.4194),
//                                 initialZoom: 12,
//                                 maxZoom: 18.0,
//                               ),
//                               children: [
//                                 TileLayer(
//                                   urlTemplate:
//                                       'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                                   userAgentPackageName: 'com.example.yourapp',
//                                 ),
//                                 MarkerLayer(
//                                   markers: [
//                                     Marker(
//                                       point: LatLng(37.7749, -122.4194),
//                                       width: 40,
//                                       height: 40,
//                                       child: Icon(
//                                         Icons.location_pin,
//                                         color: Colors.red,
//                                         size: 30,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 15),
//                       _buildSection(
//                         title: "Quick Actions",
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             SizedBox(
//                               width: MediaQuery.of(context).size.width * 0.428,
//                               child: ElevatedButton(
//                                 onPressed: () => {},
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFFCC6666),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(15),
//                                   ),
//                                 ),
//                                 child: const Text(
//                                   "Schedule Visit",
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               width: MediaQuery.of(context).size.width * 0.428,
//                               child: ElevatedButton(
//                                 onPressed: () => {},
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFFCC6666),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(15),
//                                   ),
//                                 ),
//                                 child: const Text(
//                                   "Reschedule Visit",
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 15),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Color(0xFF4CAF93),
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(22),
//                             ),
//                           ),
//                           onPressed: () {
//                             context.go("/visit-form");
//                           },
//                           child: const Text(
//                             "Dispatch Now",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 15),
//                       _buildSection(
//                         title: "Activity Feed",
//                         child: Column(
//                           children: [
//                             _buildActivityItem(
//                                 "9:30 AM - Dispatched James Moore"),
//                             _buildActivityItem(
//                                 "10:23 AM - Scheduled visit for Arthur Lee"),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSection({required String title, required Widget child}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF003366),
//           ),
//         ),
//         const SizedBox(height: 8),
//         child,
//       ],
//     );
//   }

//   Widget _buildActivityItem(String text) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Color(0xFF219EBC),
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(
//               Icons.star,
//               size: 16,
//               color: Colors.white,
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 text,
//                 style: const TextStyle(color: Colors.white),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _StatItem extends StatelessWidget {
//   final String title;
//   final String value;
//   final Color color;

//   const _StatItem({
//     required this.title,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Color(0xFF4CAF93),
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             spreadRadius: 1,
//             blurRadius: 5,
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//           Text(
//             title,
//             style: const TextStyle(
//                 color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String activeCount = "0";
  String pendingCount = "0";
  String completedCount = "0";

  @override
  void initState() {
    super.initState();
    _loadStatusCounts();
  }

  Future<void> _loadStatusCounts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final userData = userDoc.data();
    final String? orgId = userData?['orgId'] ?? userData?['organizationId'];

    if (orgId == null) return;

    final today = DateTime.now();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final docRef = FirebaseFirestore.instance
        .collection('daily_status_counts')
        .doc(orgId)
        .collection('dates')
        .doc(todayString);

    docRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        setState(() {
          activeCount = (data?['active'] ?? 0).toString();
          pendingCount = (data?['pending'] ?? 0).toString();
          completedCount = (data?['completed'] ?? 0).toString();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF003366),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          const SizedBox(height: 15),
          _buildSection(
            title: "Team Activity",
            child: Row(
              children: [
                Expanded(
                  child: _StatItem(
                      title: "Active",
                      value: activeCount,
                      color: Color(0xFFFFF9C4)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatItem(
                      title: "Pending",
                      value: pendingCount,
                      color: Color(0xFFFFF9C4)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatItem(
                      title: "Done",
                      value: completedCount,
                      color: Color(0xFFFFF9C4)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          _buildSection(
            title: "Live Feed",
            child: Container(
              height: 320,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(45),
                border: Border.all(color: Color(0xFF003366), width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    spreadRadius: 2,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(42),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(37.7749, -122.4194),
                    initialZoom: 12,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.yourapp',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(37.7749, -122.4194),
                          width: 40,
                          height: 40,
                          child: Icon(Icons.location_pin,
                              color: Colors.red, size: 30),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          _buildSection(
            title: "Quick Actions",
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.go("/schedule-visit"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFCC6666),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "Schedule Visit",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.go("/reschedule-visit"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFCC6666),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "Reschedule Visit",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          // === DISPATCH NOW FULL BUTTON ===
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go("/visit-form"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF93),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: const Text(
                "Dispatch Now",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          _buildSection(
            title: "Activity Feed",
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('activity_logs')
                  .orderBy('timestamp', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No activities yet."));
                }

                final activities = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity =
                        activities[index].data() as Map<String, dynamic>;
                    final detail = activity['details'] ?? "No details";

                    return _buildActivityItem(detail);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF003366),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildActivityItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFF219EBC),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            const Icon(Icons.star, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatItem(
      {required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF4CAF93),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
