import 'package:go_router/go_router.dart';
import '../features/org_features/checkintimer.dart';
import 'screens/bottom_navigation/profile.dart';
import '../features/org_features/addemergencycontact.dart';

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
      }),
  GoRoute(
    path: '/add-emergency-contact',
    builder: (context, state) => AddEmergencyContactScreen(),
  ),
]);
