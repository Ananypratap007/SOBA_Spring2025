import 'package:go_router/go_router.dart';
import 'checkintimer.dart';
import 'profile.dart';

final GoRouter router = GoRouter(routes: [
  GoRoute(
    path: '/profile',
    builder: (context, state) => const ProfileScreen(),
  ),
  GoRoute(
      path: '/check-in',
      builder: (context, state) {
        final initialDuration =
            state.extra as Duration? ?? Duration(minutes: 10);
        return CheckInTimer(initialDuration: initialDuration);
      })
]);
