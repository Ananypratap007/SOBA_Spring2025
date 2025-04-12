import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VisitScreen extends StatefulWidget {
  const VisitScreen({super.key});

  @override
  _VisitScreenState createState() => _VisitScreenState();
}

class _VisitScreenState extends State<VisitScreen> with SingleTickerProviderStateMixin {
  Timer? _timer;
  Duration _remaining = const Duration(minutes: 45, seconds: 00);
  late AnimationController _animationController;
  late Animation<double> _animation;
  
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
    _animationController.repeat(reverse: true);
  }

  void startTimer() {
    // Cancel any existing timer
    _timer?.cancel();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds > 0) {
        setState(() {
          _remaining = _remaining - const Duration(seconds: 1);
        });
      } else {
        timer.cancel();
      }
    });
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
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
          'Visit',
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
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              // Help button action
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
                      // ===================
                      // CURRENT VISIT
                      // ===================
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.person_pin, color: Colors.white, size: 28),
                                SizedBox(width: 10),
                                Text(
                                  'Current Visit',
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0XFF4CAF93).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Row(
                                    children: [
                                      Icon(Icons.person, color: Colors.white70, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'Recipient: Brad Miller',
                                        style: TextStyle(fontSize: 16, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.cake, color: Colors.white70, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'Age: 47',
                                        style: TextStyle(fontSize: 16, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ===================
                      // EMERGENCY
                      // ===================
                      GestureDetector(
                        onTap: () {
                          // Handle emergency tap here
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade700,
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FadeTransition(
                                opacity: _animation,
                                child: const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'EMERGENCY?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Tap Here',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ===================
                      // STATUS CHECK
                      // ===================
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
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
                                Icon(Icons.schedule, color: Colors.white, size: 22),
                                SizedBox(width: 8),
                                Text(
                                  'Status Check',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Timer with alarm icon
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0XFF4CAF93).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.access_alarm,
                                    color: Colors.white,
                                    size: 34,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    formatDuration(_remaining),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // "Check in" button
                            SizedBox(
                              height: 42,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _remaining = const Duration(minutes: 45, seconds: 0);
                                  });
                                  startTimer();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0XFF4CAF93),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 0,
                                  ),
                                  elevation: 3,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                                    SizedBox(width: 6),
                                    Text(
                                      'Check In',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ===================
                      // END VISIT
                      // ===================
                      GestureDetector(
                        onTap: () {
                          context.go('/');
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          decoration: BoxDecoration(
                            color: const Color(0XFF4CAF93), // Gray-blue color
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.exit_to_app,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'End Visit',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
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