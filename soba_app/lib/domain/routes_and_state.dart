import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soba_app/bottom_nav_screen.dart';
import 'package:soba_app/checkin/checkin_screen.dart';
import 'package:soba_app/home/home_screen.dart';
import 'package:soba_app/login.dart';
import 'package:soba_app/profile/profile_screen.dart';

bool _isLoggedIn = false;

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return HomeScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'map',
          builder: (BuildContext context, GoRouterState state) {
            return PageWithBottomNav(
              child: Placeholder(),
            );
          },
        ),
        GoRoute(
          path: 'profile',
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
