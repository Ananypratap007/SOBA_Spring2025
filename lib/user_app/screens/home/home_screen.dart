import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool connected = false;
  bool _isVisitAccepted = false;
  bool _notificationsEnabled = true;

  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<double> _bellAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    // Bell shake animation
    _bellAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.2, end: 0.2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.2, end: -0.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.1, end: 0.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.1, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5),
    ));
    
    _animationController.repeat(reverse: true);
  }

  void _toggleNotifications() {
    setState(() {
      _notificationsEnabled = !_notificationsEnabled;
      
      // Play animation once when enabling notifications
      if (_notificationsEnabled) {
        _animationController.reset();
        _animationController.forward().then((_) {
          // After animation completes, continue the regular animation
          _animationController.repeat(reverse: true);
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Page background
      backgroundColor: const Color(0XFF4CAF93),

      // AppBar with matching color scheme
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Dashboard',
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
        elevation: 0, // Remove shadow to match profile screen
        actions: [
          // Animated notification bell
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Animated bell icon 
                RotationTransition(
                  turns: _notificationsEnabled ? _bellAnimation : const AlwaysStoppedAnimation(0),
                  child: IconButton(
                    icon: Icon(
                      _notificationsEnabled 
                          ? Icons.notifications_active
                          : Icons.notifications_off_outlined,
                      color: Colors.white,
                    ),
                    onPressed: _toggleNotifications,
                    tooltip: _notificationsEnabled 
                        ? 'Disable notifications' 
                        : 'Enable notifications',
                  ),
                ),
                
                // Indicator dot when notifications are enabled
                if (_notificationsEnabled)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),

      body: Container(
        decoration: const BoxDecoration(
          color: Color(0XFF4CAF93),
        ),
        child: Column(
          children: [
            // Top spacing to match profile layout
            const SizedBox(height: 10),
            
            // Main content area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF003366),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('visits')
                            .where('responderId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                            .where('status', whereIn: ['pending', 'accepted'])
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text(
                                "No upcoming jobs",
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }
                          // Define urgency sort order and color mapping
                          final Map<String, int> urgencyOrder = {
                            "Critical": 4,
                            "High": 3,
                            "Medium": 2,
                            "Low": 1,
                          };
                          Color getUrgencyColor(String? urgency) {
                            switch (urgency) {
                              case 'Critical':
                                return Colors.red;
                              case 'High':
                                return Colors.orange;
                              case 'Medium':
                                return Colors.amber;
                              case 'Low':
                                return Colors.green;
                              default:
                                return Colors.grey;
                            }
                          }

                          // Get all job documents and sort by urgency descending (highest first)
                          List<QueryDocumentSnapshot> jobs = snapshot.data!.docs;
                          jobs.sort((a, b) {
                            final urgencyA = (a.data() as Map<String, dynamic>)['urgency'] ?? 'Low';
                            final urgencyB = (b.data() as Map<String, dynamic>)['urgency'] ?? 'Low';
                            return urgencyOrder[urgencyB]!.compareTo(urgencyOrder[urgencyA]!);
                          });

                          return Column(
                            children: jobs.map((doc) {
                              final job = doc.data() as Map<String, dynamic>;
                              final urgency = job['urgency'] as String?;
                              final urgencyColor = getUrgencyColor(urgency);

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Upcoming Job Card
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Top Row: "Upcoming Job" & Urgency Badge
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: const [
                                                Icon(Icons.work_outline, color: Colors.white, size: 22),
                                                SizedBox(width: 8),
                                                Text(
                                                  "Upcoming Job",
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: urgencyColor.withOpacity(0.9),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                children: [
                                                  FadeTransition(
                                                    opacity: _animation,
                                                    child: const Icon(
                                                      Icons.warning_amber_rounded,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    urgency ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        // Recipient Info
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0XFF4CAF93).withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(Icons.person, color: Colors.white70, size: 18),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      "Recipient: ${job['clientName'] ?? ''}",
                                                      style: const TextStyle(fontSize: 16, color: Colors.white),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Icon(Icons.cake, color: Colors.white70, size: 18),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      "Age: ${job['age'] ?? ''}",
                                                      style: const TextStyle(fontSize: 16, color: Colors.white),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Icon(Icons.location_on, color: Colors.white70, size: 18),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      "Address: ${job['address'] ?? ''}",
                                                      style: const TextStyle(fontSize: 16, color: Colors.white),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        // Description label and content
                                        const Text(
                                          "Description:",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.white24, width: 1),
                                          ),
                                          child: Text(
                                            job['description'] ?? '',
                                            style: const TextStyle(fontSize: 15, color: Colors.white, height: 1.4),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        // Accept/Decline Buttons (only if status is pending)
                                        if (job['status'] == 'pending')
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    // Decline: remove job from Firestore
                                                    await FirebaseFirestore.instance
                                                        .collection('visits')
                                                        .doc(doc.id)
                                                        .delete();
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                                    backgroundColor: Colors.red.shade700,
                                                    foregroundColor: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    elevation: 3,
                                                  ),
                                                  child: const Text(
                                                    "Decline",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    await FirebaseFirestore.instance
                                                        .collection('visits')
                                                        .doc(doc.id)
                                                        .update({'status': 'accepted'});
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                                    backgroundColor: const Color(0XFF4CAF93),
                                                    foregroundColor: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    elevation: 3,
                                                  ),
                                                  child: const Text(
                                                    "Accept",
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
                                      ],
                                    ),
                                  ),
                                  // "Start Visit" Card appears below the job card if status is accepted
                                  if (job['status'] == 'accepted')
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(20),
                                      margin: const EdgeInsets.only(bottom: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            spreadRadius: 1,
                                            blurRadius: 5,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: const [
                                              Icon(Icons.play_circle_outline, color: Colors.white, size: 26),
                                              SizedBox(width: 8),
                                              Text(
                                                "Start Visit",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: const Color(0XFF4CAF93).withOpacity(0.3),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              "Tap to check in and start your visit",
                                              style: TextStyle(fontSize: 15, color: Colors.white),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          ElevatedButton(
                                            onPressed: () {
                                              context.go('/checkin');
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0XFF4CAF93),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                              elevation: 3,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: const [
                                                Icon(Icons.login, color: Colors.white),
                                                SizedBox(width: 10),
                                                Text(
                                                  "Start",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}