// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';

// class SelfiePage extends StatefulWidget {
//   const SelfiePage({
//     super.key,
//     this.onSelfieTaken,
//   });

//   final VoidCallback? onSelfieTaken;

//   @override
//   State<SelfiePage> createState() => _SelfiePageState();
// }

// class _SelfiePageState extends State<SelfiePage> {
//   CameraController? _controller;
//   bool _isInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   Future<void> _initializeCamera() async {
//     final cameras = await availableCameras();
//     if (cameras.isEmpty) return;

//     // Find the front camera
//     final frontCamera = cameras.firstWhere(
//       (camera) => camera.lensDirection == CameraLensDirection.front,
//       orElse: () => cameras.first,
//     );

//     _controller = CameraController(
//       frontCamera,
//       ResolutionPreset.medium,
//       enableAudio: false,
//     );

//     try {
//       await _controller!.initialize();
//       if (mounted) {
//         setState(() {
//           _isInitialized = true;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error initializing camera: $e');
//     }
//   }

//   Future<void> _takePicture() async {
//     if (!_isInitialized) return;

//     try {
//       final image = await _controller!.takePicture();
//       widget.onSelfieTaken?.call();
//     } catch (e) {
//       debugPrint('Error taking picture: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isInitialized) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         Transform.scale(
//           scale: 1 / (_controller!.value.aspectRatio * MediaQuery.of(context).size.aspectRatio),
//           child: Center(
//             child: CameraPreview(_controller!),
//           ),
//         ),
//         Positioned(
//           bottom: 30,
//           left: 0,
//           right: 0,
//           child: Center(
//             child: GestureDetector(
//               onTap: _takePicture,
//               child: Container(
//                 padding: const EdgeInsets.all(15),
//                 decoration: const BoxDecoration(
//                   color: Colors.redAccent,
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.camera_alt,
//                   color: Colors.white,
//                   size: 30,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';

class SelfiePage extends StatelessWidget {
  const SelfiePage({
    super.key,
    this.onSelfieTaken,
  });

  final VoidCallback? onSelfieTaken;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Replace the image with a large icon
              const Icon(
                Icons.camera_front,
                size: 240,
                color: Colors.grey,
              ),
              const SizedBox(height: 20),
              const Text(
                "Take a selfie for identification",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              // TODO: Convert to an IconButton
              GestureDetector(
                onTap: () {
                  onSelfieTaken?.call();
                }, //
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
            ],
          ),
        ),
      ],
    );
  }
}
