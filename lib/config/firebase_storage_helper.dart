import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Helper class for Firebase Storage operations
class FirebaseStorageHelper {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Uploads a file to Firebase Storage and returns the download URL
  static Future<String> uploadProfileImage({
    required File file,
    required BuildContext context,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    
    try {
      // Try multiple paths to find one that works
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Try different paths in order
      final possiblePaths = [
        'profile_images/${user.uid}/$fileName',  // Recommended path
        'users/${user.uid}/profile_images/$fileName', // Alternative path
        'images/profiles/${user.uid}/$fileName', // Another alternative
        '${user.uid}/$fileName', // Simple path
        fileName, // Root level
      ];
      
      String? uploadUrl;
      String? lastError;
      
      // Try each path until one succeeds
      for (final path in possiblePaths) {
        try {
          debugPrint('Attempting upload to path: $path');
          
          final ref = _storage.ref().child(path);
          final metadata = SettableMetadata(contentType: 'image/jpeg');
          
          // Upload the file
          final uploadTask = ref.putFile(file, metadata);
          
          // Wait for upload to complete
          final snapshot = await uploadTask;
          
          // Get download URL
          uploadUrl = await snapshot.ref.getDownloadURL();
          
          // If we got here, upload succeeded
          debugPrint('Upload successful to path: $path');
          break;
        } catch (e) {
          lastError = e.toString();
          debugPrint('Upload failed for path $path: $e');
          // Continue to next path
        }
      }
      
      if (uploadUrl != null) {
        return uploadUrl;
      } else {
        throw Exception('All upload paths failed. Last error: $lastError');
      }
      
    } catch (e) {
      _showFirebaseRulesDialog(context);
      throw Exception('Error uploading profile image: $e');
    }
  }

  /// Shows a dialog explaining how to fix Firebase Storage rules
  static void _showFirebaseRulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Firebase Storage Rules Required'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Firebase Storage rules need to be updated:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text('1. Go to Firebase Console: https://console.firebase.google.com'),
              const Text('2. Select your project'),
              const Text('3. Go to "Storage" in the left sidebar'),
              const Text('4. Click the "Rules" tab at the top'),
              const Text('5. Replace the rules with:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: const Text(
                  '''rules_version = "2";
service firebase.storage {
  match /b/{bucket}/o {
    // Allow public read access to profile images
    match /profile_images/{userId}/{allPaths=**} {
      allow read;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow authenticated users to access their own data
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // For testing - allow authenticated users broader access
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}''',
                  style: TextStyle(fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(height: 12),
              const Text('6. Click "Publish" to save the rules'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Shows the Firebase rules dialog manually
  static void showRulesDialog(BuildContext context) {
    _showFirebaseRulesDialog(context);
  }
} 