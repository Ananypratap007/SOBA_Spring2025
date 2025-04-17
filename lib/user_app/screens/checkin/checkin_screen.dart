import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soba_app/user_app/screens/checkin/checkin.dart';
import 'package:soba_app/user_app/screens/checkin/selfie_confirmation.dart';
import 'package:soba_app/user_app/screens/checkin/vehicle_picture.dart';
import 'package:soba_app/user_app/screens/checkin/vehicle_review.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  CheckinState _state = CheckinState.selfie;
  String? _selfieImagePath;
  String? _vehicleImagePath;

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
      backgroundColor: const Color(0XFF4CAF93),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50),
            width: double.infinity,
            height: 120,
            decoration: const BoxDecoration(
              color: Color(0XFF4CAF93),
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
                      'Exit',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
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
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF003366),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: _currentPage,
            ),
          ),
        ],
      ),
    );
  }

  Widget get _currentPage {
    switch (_state) {
      case CheckinState.selfie:
        return SelfiePage(
          onSelfieTaken: (imagePath) {
            setState(() {
              _selfieImagePath = imagePath;
            });
            _updateState(CheckinState.selfieConfirmation);
          },
        );
      case CheckinState.selfieConfirmation:
        return SelfieReviewScreen(
          imagePath: _selfieImagePath!,
          onSelfieConfirmed: () => _updateState(CheckinState.vehicle),
        );

      case CheckinState.vehicle:
        return VehiclePhotoScreen(
          onVehiclePhotoTaken: (imagePath) {
            setState(() {
              _vehicleImagePath = imagePath;
            });
            _updateState(CheckinState.vehicleReview);
          },
        );

      case CheckinState.vehicleReview:
        return VehicleReviewScreen(
          imagePath: _vehicleImagePath!,
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
