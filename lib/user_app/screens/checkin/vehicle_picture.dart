import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class VehiclePhotoScreen extends StatefulWidget {
  const VehiclePhotoScreen({super.key, this.onVehiclePhotoTaken});

  final VoidCallback? onVehiclePhotoTaken;

  @override
  State<VehiclePhotoScreen> createState() => _VehiclePhotoScreenState();
}

class _VehiclePhotoScreenState extends State<VehiclePhotoScreen> {
  CameraController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _takePicture() async {
    if (!_isInitialized) return;

    try {
      final image = await _controller!.takePicture();
      widget.onVehiclePhotoTaken?.call();
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Transform.scale(
            scale: 1 / (_controller!.value.aspectRatio * MediaQuery.of(context).size.aspectRatio),
            child: Center(
              child: CameraPreview(_controller!),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _takePicture,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
