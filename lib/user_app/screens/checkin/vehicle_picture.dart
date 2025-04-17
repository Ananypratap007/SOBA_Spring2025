import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class VehiclePhotoScreen extends StatefulWidget {
  const VehiclePhotoScreen({super.key, this.onVehiclePhotoTaken});

  final Function(String imagePath)? onVehiclePhotoTaken;

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
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint('No cameras available');
        return;
      }

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

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
    if (!_isInitialized || _controller == null) return;

    try {
      final image = await _controller!.takePicture();
      widget.onVehiclePhotoTaken?.call(image.path);
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
        backgroundColor: Color(0xFF003366),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0XFF4CAF93),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFF003366),
      body: Stack(
        children: [
          Transform.scale(
            scale: 1 / (_controller!.value.aspectRatio * MediaQuery.of(context).size.aspectRatio),
            child: Center(
              child: CameraPreview(_controller!),
            ),
          ),
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0XFF4CAF93).withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Please take a clear photo of your vehicle',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _takePicture,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    color: Color(0XFF4CAF93),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
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
