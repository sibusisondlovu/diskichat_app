import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:uuid/uuid.dart';

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  Future<String> uploadImage(File file) async {
    try {
      // 1. Compress Image
      final compressedFile = await _compressImage(file);
      final File uploadFile = compressedFile ?? file; // Fallback to original

      final String fileName = '${_uuid.v4()}.jpg';
      final Reference ref = _storage.ref().child('posts').child(fileName);

      final UploadTask uploadTask = ref.putFile(
        uploadFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image to Firebase Storage: $e');
    }
  }

  Future<File?> _compressImage(File file) async {
    try {
      final String targetPath = '${file.parent.path}/${_uuid.v4()}_compressed.jpg';
      
      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, 
        targetPath,
        quality: 70,
        minWidth: 1080,
        minHeight: 1080,
      );

      if (result != null) {
        return File(result.path);
      }
      return null;
    } catch (e) {
      print("Image compression failed: $e");
      return null;
    }
  }
}
