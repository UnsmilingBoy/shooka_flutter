import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickAndConvertToBase64() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return null;

      // ✅ On Web, XFile has bytes directly
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        return base64Encode(bytes);
      }

      // ✅ On Mobile, read from local file path
      final file = File(pickedFile.path);
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }
}
