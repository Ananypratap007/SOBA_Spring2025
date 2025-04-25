import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VisitScreen extends StatefulWidget {
  const VisitScreen({super.key});

  @override
  _VisitScreenState createState() => _VisitScreenState();
}

class _VisitScreenState extends State<VisitScreen> with SingleTickerProviderStateMixin {
  Timer? _timer;
  Duration _remaining = const Duration(minutes: 45, seconds: 0);
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  // For emergency confirmation
  bool _isEmergencyDialogOpen = false;
  double _sliderValue = 0.0;
  int _confirmCountdown = 0;
  Timer? _countdownTimer;
  
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
    
    // Start the timer automatically
    startTimer();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds > 0) {
        setState(() {
          _remaining = _remaining - const Duration(seconds: 1);
        });
      } else {
        timer.cancel();
        _showTimerExpiredDialog();
      }
    });
  }

  void _showTimerExpiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Color(0XFF4CAF93)),
              SizedBox(width: 10),
              Text('Status Check Needed'),
            ],
          ),
          content: const Text('Please check in to confirm you are safe and well.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _remaining = const Duration(minutes: 45, seconds: 0);
                });
                startTimer();
              },
              child: const Text('Check In Now', style: TextStyle(color: Color(0XFF4CAF93))),
            ),
          ],
        );
      },
    );
  }
  
  void _showEmergencyConfirmationDialog() {
    // Reset state
    _sliderValue = 0.0;
    _confirmCountdown = 0;
    _isEmergencyDialogOpen = true;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 28),
                  const SizedBox(width: 10),
                  const Text(
                    'EMERGENCY',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_confirmCountdown > 0)
                    Column(
                      children: [
                        Text(
                          'Emergency will be triggered in $_confirmCountdown',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text('Tap anywhere to cancel', style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 20),
                      ],
                    )
                  else
                    Column(
                      children: [
                        const Text('Slide to confirm emergency', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 20),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.all(5),
                              child: Row(
                                children: [
                                  const SizedBox(width: 65),
                                  Expanded(
                                    child: Text(
                                      'SLIDE RIGHT TO CONFIRM',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              left: 0,
                              child: Container(
                                height: 80,
                                width: MediaQuery.of(context).size.width * 0.7 * _sliderValue,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.red.shade300, Colors.red.shade700],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                            ),
                            Positioned(
                              left: (_sliderValue * (MediaQuery.of(context).size.width * 0.7 - 70)),
                              child: Container(
                                height: 70,
                                width: 70,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade700,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.arrow_forward, color: Colors.white, size: 30),
                              ),
                            ),
                            Slider(
                              value: _sliderValue,
                              onChanged: (value) {
                                setState(() {
                                  _sliderValue = value;
                                });
                                if (value >= 0.95) {
                                  setState(() {
                                    _confirmCountdown = 3;
                                  });
                                  _startCountdown(dialogContext, setState);
                                }
                              },
                              thumbColor: Colors.transparent,
                              activeColor: Colors.transparent,
                              inactiveColor: Colors.transparent,
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _cancelCountdown();
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      _isEmergencyDialogOpen = false;
      _cancelCountdown();
    });
  }
  
  void _startCountdown(BuildContext dialogContext, StateSetter setState) {
    _cancelCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_confirmCountdown > 1) {
        setState(() {
          _confirmCountdown--;
        });
      } else {
        _cancelCountdown();
        if (_isEmergencyDialogOpen) {
          Navigator.of(dialogContext).pop();
          _triggerEmergency();
        }
      }
    });
  }
  
  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }
  
  void _triggerEmergency() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final visitSnapshot = await FirebaseFirestore.instance
          .collection('visits')
          .where('responderId', isEqualTo: currentUser.uid)
          .where('status', isEqualTo: 'active')
          .get();
      if (visitSnapshot.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('visits')
            .doc(visitSnapshot.docs.first.id)
            .update({'status': 'emergency'});
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'status': 'Emergency'});
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency services have been notified'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ),
    );
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
    _countdownTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003366),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF003366), Color(0xFF002244)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              children: [
                // Current Visit Row
                Row(
                  children: [
                    const Icon(Icons.person_pin, color: Color(0xFF5DBEA4), size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Brad Miller, Age: 47',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.exit_to_app, color: Colors.white, size: 22),
                      onPressed: () async {
                        final currentUser = FirebaseAuth.instance.currentUser;
                        if (currentUser != null) {
                          final snapshot = await FirebaseFirestore.instance
                              .collection('visits')
                              .where('responderId', isEqualTo: currentUser.uid)
                              .where('status', isEqualTo: 'accepted')
                              .get();
                          if (snapshot.docs.isNotEmpty) {
                            await FirebaseFirestore.instance
                                .collection('visits')
                                .doc(snapshot.docs.first.id)
                                .delete();
                          }
                        }
                        context.go('/');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Timer and Check In
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFF5DBEA4).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.access_alarm, color: Color(0xFF5DBEA4), size: 32),
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
                      const Spacer(),
                      ElevatedButton(
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
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: const Size(40, 36),
                        ),
                        child: const Text(
                          'Check In',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Emergency Button
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      _showEmergencyConfirmationDialog();
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.red.shade700, Colors.red.shade900],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.shade900.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
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
                              size: 60,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'EMERGENCY?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tap Here',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
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
        ),
      ),
    );
  }
}