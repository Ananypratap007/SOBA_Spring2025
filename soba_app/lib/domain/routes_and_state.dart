import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soba_app/bottom_nav_screen.dart';
import 'package:soba_app/checkin/checkin_screen.dart';
import 'package:soba_app/domain/profile_model.dart';
import 'package:soba_app/home/home_screen.dart';
import 'package:soba_app/home/visit_screen.dart';
import 'package:soba_app/login/login_screen.dart';
import 'package:soba_app/map/map_screen.dart';
import 'package:soba_app/profile/profile_presenter.dart';
import 'package:soba_app/profile/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Create a stream to listen to auth state changes
final authStateStream = FirebaseAuth.instance.authStateChanges();

final ProfileModel _currentUser = dummyUsers[0];

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
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
      path: '/visit',
      builder: (BuildContext context, GoRouterState state) {
        return PageWithBottomNav(
          child: VisitScreen(),
        );
      },
    ),
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => PageWithBottomNav(
        child: HomeScreen(),
      ),
    ),
    GoRoute(
      path: '/map',
      builder: (BuildContext context, GoRouterState state) => PageWithBottomNav(
        child: MapScreen(),
      ),
    ),
    GoRoute(
      path: '/profile',
      builder: (BuildContext context, GoRouterState state) {
        return PageWithBottomNav(
          child: ProfileScreen(
            presenter: ProfilePresenter(currentUser: _currentUser),
          ),
        );
      },
    ),
    GoRoute(
      path: '/checkin',
      builder: (BuildContext context, GoRouterState state) {
        return CheckinScreen();
      },
    ),
  ],
  
  // Handle authentication state and redirect accordingly
  redirect: (context, state) {
    // Get the current user
    final user = FirebaseAuth.instance.currentUser;
    
    // Check if we're on the login page
    final isLoginRoute = state.matchedLocation == '/login';
    
    // If there's no user and we're not on the login page, redirect to login
    if (user == null && !isLoginRoute) {
      return '/login';
    }
    
    // If there is a user and we're on the login page, redirect to home
    if (user != null && isLoginRoute) {
      return '/';
    }
    
    return null;
  },
);
/*
          path: '/profile',
          builder: (BuildContext context, GoRouterState state) {
            return PageWithBottomNav(
              child: ProfileScreen(),
            );
          },
        ),
        GoRoute(
          path: 'checkin',
          builder: (BuildContext context, GoRouterState state) {
            return CheckinScreen();
          },
        ),
        GoRoute(
          path: 'login',
          builder: (BuildContext context, GoRouterState state) {
            return LoginPage(
              onSuccessfulLogin: () {
                _isLoggedIn = true;
                context.go('/');
              },
            );
          },
        ),
      ],
    ),
  ],
  // This is where we will handle the login - check if the user is logged in
  // and redirect if not.
  redirect: (state, goRouterState) => !_isLoggedIn ? '/login' : null,
);
*/

