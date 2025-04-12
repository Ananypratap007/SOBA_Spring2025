import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Firebase/store packages
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:soba_app/org_app/screens/activities/send_visit_form.dart';
// Home Screen
import 'package:soba_app/org_app/screens/bottom_navigation/home.dart';
//Login Screen
import 'package:soba_app/org_app/screens/authentication/login_screen.dart';
// Sign Up Screens
import 'package:soba_app/org_app/screens/authentication/signup_screen2.dart';
import 'package:soba_app/org_app/screens/authentication/signup_screen1.dart';
// Profile Screen
import 'package:soba_app/org_app/screens/bottom_navigation/profile.dart';
// Additional Helper Screens
import 'package:soba_app/features/org_features/checkintimer.dart';
import 'package:soba_app/features/org_features/addemergencycontact.dart';
import 'package:soba_app/shared/widgets/emergency_contacts_list.dart';
import 'package:soba_app/org_app/screens/bottom_navigation/tiles.dart';
// Bottom navigation bar
import 'package:soba_app/features/org_features/bottom_navigator.dart';
import 'package:soba_app/config/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/create-org-signup',
      builder: (context, state) => const OrganizationCreatorSignUpScreen(),
    ),
    GoRoute(
      path: '/join-org-signup',
      builder: (context, state) => const OrganizationCreatorSignUpScreen(),
    ),
    GoRoute(
      path: '/complete-signup',
      builder: (context, state) {
        final userData = state.extra as Map<String, String>? ?? {};
        return OrganizationRegistrationScreen(userData: userData);
      },
    ),
    // Protected Routes (must be logged in)
    GoRoute(
      path: '/',
      builder: (context, state) => PageWithBottomNav(child: HomeScreen()),
    ),
    GoRoute(
      path: '/visit-form',
      builder: (context, state) => ClientFormScreen(),
    ),
    GoRoute(
      path: '/tiles',
      builder: (context, state) => PageWithBottomNav(child: TilesScreen()),
    ),
    GoRoute(
      path: '/profile',
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
      path: '/emergency-contacts',
      builder: (context, state) => const EmergencyContactsScreen(),
    ),
    GoRoute(
      path: '/add-emergency-contact',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return AddEmergencyContactScreen(
          contact: extra?['contact'] as Map<String, String>?,
          index: extra?['index'] as int?,
        );
      },
    ),
  ],
  redirect: (BuildContext context, GoRouterState state) {
    final user = FirebaseAuth.instance.currentUser;
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/create-org-signup' ||
        state.matchedLocation == '/join-org-signup' ||
        state.matchedLocation == '/complete-signup';

    if (user == null && !isAuthRoute) return '/login';
    if (user != null && isAuthRoute) return '/';
    return null;
  },
);
