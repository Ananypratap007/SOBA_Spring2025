import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soba_app/bottom_nav_screen.dart';
import 'package:soba_app/checkin/checkin_screen.dart';
import 'package:soba_app/profile/profile_screen.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return PageWithBottomNav(
          child: CheckinScreen(),
        );
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
      ],
    ),
  ],
);
