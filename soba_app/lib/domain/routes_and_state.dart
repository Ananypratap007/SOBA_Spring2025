import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soba_app/bottom_nav_screen.dart';
import 'package:soba_app/checkin/checkin_screen.dart';
import 'package:soba_app/domain/profile_model.dart';
import 'package:soba_app/home/home_screen.dart';
import 'package:soba_app/home/visit_screen.dart';
import 'package:soba_app/login/login_screen.dart';
import 'package:soba_app/profile/profile_presenter.dart';
import 'package:soba_app/profile/profile_screen.dart';

bool _ifLoggedIn = false;
final ProfileModel _currentUser = dummyUsers[0];

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return LoginPage(
          onLoggedIn: () {
            _ifLoggedIn = true;
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
  
  // This is where we will handle the login - check if the user is logged in
  // and redirect if not.
  redirect: (state, goRouterState) => _ifLoggedIn ? null : '/login',
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
