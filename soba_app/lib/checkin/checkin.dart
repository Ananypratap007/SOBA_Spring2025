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
