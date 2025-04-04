import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:soba_app/config/firebase_options.dart';

class FirebaseConfig {
  static Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Firebase Auth instance
  static FirebaseAuth get auth => FirebaseAuth.instance;

  // Firestore instance
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  // Firebase Storage instance
  static FirebaseStorage get storage => FirebaseStorage.instance;
}
