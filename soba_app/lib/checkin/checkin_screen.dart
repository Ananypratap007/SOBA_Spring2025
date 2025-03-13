import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soba_app/checkin/checkin.dart';
import 'package:soba_app/checkin/selfie_confirmation.dart';
import 'package:soba_app/checkin/vehicle_picture.dart';
import 'package:soba_app/checkin/vehicle_review.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  CheckinState _state = CheckinState.selfie;

  String get _pageTitle {
    switch (_state) {
      case CheckinState.selfie:
        return 'Checking in';
      case CheckinState.selfieConfirmation:
        return 'Checking in';
      case CheckinState.vehicle:
        return 'Vehicle Photo';
      case CheckinState.vehicleReview:
        return 'Vehicle Review';
      case CheckinState.success:
        return 'Success';
    }
  }

  void _previousState() => _updateState(switch (_state) {
        CheckinState.selfie => CheckinState.selfie,
        CheckinState.selfieConfirmation => CheckinState.selfie,
        CheckinState.vehicle => CheckinState.selfieConfirmation,
        CheckinState.vehicleReview => CheckinState.vehicle,
        CheckinState.success => CheckinState.selfie,
      });

  void _updateState(CheckinState state) {
    // Do any checking to make sure we can go to this screen
    switch (state) {
      case CheckinState.selfie:
        break;
      case CheckinState.selfieConfirmation:
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
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50),
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF003366), const Color(0xFF0066CC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
            child: Stack(
              children: [
                if (_state != CheckinState.selfie)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.white,
                      onPressed: _previousState,
                    ),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Text(
                      'exit',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      _updateState(CheckinState.selfie);
                      context.go('/');
                    },
                  ),
                ),
                Center(
                  child: Text(
                    _pageTitle,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(child: _currentPage),
        ],
      ),
    );
  }

  Widget get _currentPage {
    switch (_state) {
      case CheckinState.selfie:
        return SelfiePage(
          onSelfieTaken: () => _updateState(CheckinState.selfieConfirmation),
        );
      case CheckinState.selfieConfirmation:
        return SelfieReviewScreen(
          onSelfieConfirmed: () => _updateState(CheckinState.vehicle),
        );

      case CheckinState.vehicle:
        return VehiclePhotoScreen(
          onVehiclePhotoTaken: () => _updateState(CheckinState.vehicleReview),
        );

      case CheckinState.vehicleReview:
        return VehicleReviewScreen(
          onFinished: () {
            _updateState(CheckinState.selfie);
            context.go('/visit');
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
  selfieConfirmation,
  vehicle,
  vehicleReview,
  success;
}
