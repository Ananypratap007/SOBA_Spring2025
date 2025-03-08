import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soba_app/bottom_nav_screen.dart';
import 'package:soba_app/checkin/checkin_screen.dart';
import 'package:soba_app/home/home_screen.dart';
import 'package:soba_app/login/login_screen.dart';
import 'package:soba_app/profile/profile_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: <RouteBase>[
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return LoginPage();
      },
    ),
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) => PageWithBottomNav(
        child: HomeScreen(),
      ),
    ),
    GoRoute(
      path: '/profile',
      builder: (BuildContext context, GoRouterState state) {
        return PageWithBottomNav(
          child: ProfileScreen(),
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
);







/*
          path: '/profile',
          builder: (BuildContext context, GoRouterState state) {
            return PageWithBottomNav(
              child: ProfileScreen(),
            );
          },
        ),
  // This is where we will handle the login - check if the user is logged in
  // and redirect if not.
  redirect: (state, goRouterState) => null,
);
*/