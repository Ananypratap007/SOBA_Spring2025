import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soba_app/features/user_features/bottom_nav_screen.dart';
import 'package:soba_app/user_app/screens/checkin/checkin_screen.dart';
import 'package:soba_app/shared/widgets/emergency_contacts_list.dart';
import 'package:soba_app/user_app/screens/home/home_screen.dart';
import 'package:soba_app/user_app/screens/home/visit_screen.dart';
import 'package:soba_app/user_app/screens/authentication/login_screen.dart';
import 'package:soba_app/user_app/screens/authentication/signup_screen.dart';
import 'package:soba_app/user_app/screens/authentication/complete_signup_screen.dart';
import 'package:soba_app/user_app/screens/map/map_screen.dart';
import 'package:soba_app/user_app/screens/profile/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Create a stream to listen to auth state changes
final authStateStream = FirebaseAuth.instance.authStateChanges();

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) =>
          PageWithBottomNav(child: HomeScreen()),
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return LoginPage(
          onLoggedIn: () {
            context.go('/');
          },
        );
      },
    ),
    GoRoute(
      path: '/signup',
      builder: (BuildContext context, GoRouterState state) {
        return SignUpPage(
          // If sign-up succeeds, we want to go to /complete-signup
          onSignUpComplete: () {
            context.go('/complete-signup');
          },
        );
      },
    ),
    GoRoute(
      path: '/complete-signup',
      builder: (BuildContext context, GoRouterState state) {
        return const CompleteSignupScreen();
      },
    ),
    GoRoute(
      path: '/emergency-contacts',
      builder: (context, state) => const EmergencyContactsScreen(),
    ),
    GoRoute(
      path: '/visit',
      builder: (BuildContext context, GoRouterState state) {
        return PageWithBottomNav(child: VisitScreen());
      },
    ),
    GoRoute(
      path: '/map',
      builder: (BuildContext context, GoRouterState state) {
        return PageWithBottomNav(child: MapScreen());
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (BuildContext context, GoRouterState state) {
        return ProfileScreen();
      },
    ),
    GoRoute(
      path: '/checkin',
      builder: (BuildContext context, GoRouterState state) {
        return CheckinScreen();
      },
    ),
  ],
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final location = state.matchedLocation;

    final isLoginRoute = (location == '/login');
    final isSignupRoute = (location == '/signup');
    final isCompleteSignupRoute = (location == '/complete-signup');

    // If user is NOT logged in, redirect to /login (unless they're on signup or complete-signup)
    if (user == null &&
        !isLoginRoute &&
        !isSignupRoute &&
        !isCompleteSignupRoute) {
      return '/login';
    }

    // No forced redirect for logged-in user
    return null;
  },
);
