import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'org_app/profile.dart';
import 'org_app/checkintimer.dart';
import 'org_app/addemergencycontact.dart';

void main() {
  runApp(MyApp());
}

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => ProfileScreen(),
    ),
    GoRoute(
      path: '/check-in',
      builder: (context, state) {
        final duration =
            state.extra as Duration? ?? const Duration(minutes: 10);
        return CheckInTimer(initialDuration: duration);
      },
    ),
    GoRoute(
      path: '/add-emergency-contact',
      builder: (context, state) => AddEmergencyContactScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
