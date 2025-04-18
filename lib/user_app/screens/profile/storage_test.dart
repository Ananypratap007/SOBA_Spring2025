import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:soba_app/config/firebase_storage_helper.dart';

class StorageTest extends StatefulWidget {
  const StorageTest({super.key});

  @override
  State<StorageTest> createState() => _StorageTestState();
}

class _StorageTestState extends State<StorageTest> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  
  File? _imageFile;
  String? _uploadUrl;
  bool _isLoading = false;
  String _errorMessage = '';
  String _storageInfo = '';
  
  @override
  void initState() {
    super.initState();
    _getStorageInfo();
  }
  
  Future<void> _getStorageInfo() async {
    try {
      final user = _auth.currentUser;
      final bucket = _storage.ref().bucket;
      
      setState(() {
        _storageInfo = '''
Storage Bucket: $bucket
User ID: ${user?.uid ?? 'Not signed in'}
''';
      });
    } catch (e) {
      setState(() {
        _storageInfo = 'Error getting storage info: $e';
      });
    }
  }
  
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;
      
      setState(() {
        _imageFile = File(pickedFile.path);
        _uploadUrl = null;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking image: $e';
      });
    }
  }
  
  Future<void> _testUpload() async {
    if (_imageFile == null) {
      setState(() {
        _errorMessage = 'Please select an image first';
      });
      return;
    }
    
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'You must be signed in to upload';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Use the helper to upload
      final url = await FirebaseStorageHelper.uploadProfileImage(
        file: _imageFile!,
        context: context,
      );
      
      setState(() {
        _isLoading = false;
        _uploadUrl = url;
      });
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Storage Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => FirebaseStorageHelper.showRulesDialog(context),
            tooltip: 'View Required Rules',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Firebase Storage Test',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_storageInfo),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => FirebaseStorageHelper.showRulesDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('View Required Storage Rules'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Select Image'),
            ),
            const SizedBox(height: 8),
            if (_imageFile != null) ...[
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.file(_imageFile!, fit: BoxFit.cover),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _testUpload,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Test Upload'),
              ),
            ],
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
            if (_uploadUrl != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upload Successful!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('URL: $_uploadUrl'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 