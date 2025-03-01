import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soba_app/bottom_nav_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWithBottomNav(
      child: Center(
        child: MaterialButton(
          onPressed: () => context.go('/checkin'),
          child: Text('check in'),
        ),
      ),
    );
  }
}
