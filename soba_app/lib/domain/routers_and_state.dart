import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'colors.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const Placeholder();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'map',
          builder: (BuildContext context, GoRouterState state) {
            return Scaffold(
              backgroundColor: coral,
              // body: ButtonPage(),
              body: Placeholder(),
            );
          },
        ),
      ],
    ),
  ],
);
