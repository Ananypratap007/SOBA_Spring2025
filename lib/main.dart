import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'org_app/profile.dart';
import 'org_app/checkintimer.dart';
import 'org_app/addemergencycontact.dart';
import 'org_app/emergency_contacts_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    await resetHive();
    print('[DEBUG] Hive reset complete');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return HiveHotReloadReset(
      child: MaterialApp.router(
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ProfileScreen(),
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
      builder: (context, state) => const EmergencyContactListScreen(),
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
);

class HiveHotReloadReset extends StatefulWidget {
  final Widget child;

  const HiveHotReloadReset({super.key, required this.child});

  @override
  State<HiveHotReloadReset> createState() => _HiveHotReloadResetState();
}

class _HiveHotReloadResetState extends State<HiveHotReloadReset> {
  Future<void>? _resetFuture;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      _resetFuture = _resetHiveWithRetry();
    }
  }

  Future<void> _resetHiveWithRetry() async {
    try {
      await resetHive();
      await Hive.openBox('emergencyContacts');
      print('[HOT RELOAD RESET] Hive reset successful');
    } catch (e) {
      print('[HOT RELOAD RESET ERROR] $e');
      await Future.delayed(const Duration(milliseconds: 100));
      return _resetHiveWithRetry();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _resetFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return widget.child;
        }
        return const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}

Future<void> resetHive() async {
  try {
    // Close if box is open
    if (Hive.isBoxOpen('emergencyContacts')) {
      await Hive.box('emergencyContacts').close();
    }

    // Nuclear reset
    final appDir = await getApplicationDocumentsDirectory();
    final hiveDir = Directory('${appDir.path}/hive');
    print('[HIVE RESET] Attempting to delete: ${hiveDir.path}');

    // Retry mechanism for file locks
    var retries = 3;
    while (retries > 0) {
      try {
        if (await hiveDir.exists()) {
          await hiveDir.delete(recursive: true);
          print('[HIVE RESET] Directory deleted successfully');
        }
        break;
      } catch (e) {
        print('[HIVE RESET] Retrying... ($retries left)');
        await Future.delayed(const Duration(milliseconds: 50));
        retries--;
      }
    }

    // Reinitialize with fresh instance
    await Hive.initFlutter();
    print('[HIVE RESET] Initialized fresh instance');
  } catch (e) {
    print('[HIVE RESET ERROR] $e');
    rethrow;
  }
}
