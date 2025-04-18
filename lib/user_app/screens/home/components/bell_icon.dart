import 'package:flutter/material.dart';

// Custom animated bell icon widget
class BellIcon extends StatefulWidget {
  final bool enabled;
  final VoidCallback onTap;
  
  const BellIcon({
    Key? key,
    required this.enabled,
    required this.onTap,
  }) : super(key: key);
  
  @override
  BellIconState createState() => BellIconState();
}

class BellIconState extends State<BellIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -0.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.2, end: 0.2)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.2, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
    ]).animate(_controller);
  }
  
  void triggerAnimation() {
    _controller.reset();
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: IconButton(
            icon: Icon(
              widget.enabled 
                ? Icons.notifications_active
                : Icons.notifications_outlined,
              color: Colors.white,
            ),
            tooltip: widget.enabled ? 'Disable notifications' : 'Enable notifications',
            onPressed: widget.onTap,
          ),
        );
      },
    );
  }
} 