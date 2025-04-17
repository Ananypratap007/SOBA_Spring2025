import 'dart:io';
import 'package:flutter/material.dart';

class SelfieReviewScreen extends StatelessWidget {
  const SelfieReviewScreen({
    super.key,
    required this.imagePath,
    this.onSelfieConfirmed,
  });

  final String imagePath;
  final VoidCallback? onSelfieConfirmed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003366),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0XFF4CAF93),
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.file(
                            File(imagePath),
                            fit: BoxFit.cover,
                            width: 180,
                            height: 180,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.account_circle,
                                size: 150,
                                color: Colors.white70,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "Describe what you are wearing today",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          hintText: 'i.e. red shirt, blue jeans',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: const Color(0XFF4CAF93).withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0XFF4CAF93),
                              width: 2,
                            ),
                          ),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => onSelfieConfirmed?.call(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0XFF4CAF93),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
