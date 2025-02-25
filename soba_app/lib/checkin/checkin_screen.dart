import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  CheckinState _state = CheckinState.selfie;

  void _updateState(CheckinState state) {
    // Do any checking to make sure we can go to this screen
    switch (state) {
      case CheckinState.selfie:
        break;
      case CheckinState.selfieReview:
        break;
      case CheckinState.vehicle:
        break;
      case CheckinState.vehicleReview:
        break;
      case CheckinState.success:
        // If everything is ok
        _state = CheckinState.selfie;
        context.go('/');
        return;
    }

    setState(() {
      _state = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 50),
          width: double.infinity,
          height: 120,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orangeAccent, Colors.orange],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const Center(
            child: Text(
              "Checking in",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        _currentPage,
      ],
    );
  }

  Widget get _currentPage {
    switch (_state) {
      case CheckinState.selfie:
        return SelfiePageTemporary(
          pageName: 'Selfie page',
          onPressed: () => _updateState(CheckinState.selfieReview),
        );
      case CheckinState.selfieReview:
        return SelfiePageTemporary(
          pageName: 'Selfie review',
          onPressed: () => _updateState(CheckinState.vehicle),
        );
        return Text('Selfie review page');
      case CheckinState.vehicle:
        return SelfiePageTemporary(
          pageName: 'Vehicle',
          onPressed: () => _updateState(CheckinState.vehicleReview),
        );

      case CheckinState.vehicleReview:
        return SelfiePageTemporary(
          pageName: 'Vehicle Review',
          onPressed: () {
            _updateState(CheckinState.selfie);
            context.go('/');
          },
        );
      case CheckinState.success:
        // We should never be here
        throw UnimplementedError();
    }
  }
}

class SelfiePageTemporary extends StatelessWidget {
  const SelfiePageTemporary({
    super.key,
    required this.pageName,
    required this.onPressed,
  });

  final String pageName;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(pageName),
        MaterialButton(
          onPressed: onPressed,
          child: Text('next'),
        ),
      ],
    );
  }
}

enum CheckinState {
  selfie,
  selfieReview,
  vehicle,
  vehicleReview,
  success;
}
