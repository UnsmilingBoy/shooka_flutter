import 'dart:convert';
import 'package:file_picker/file_picker.dart';

class ImageService {
  Future<List<String>> pickMultipleImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true, // Needed for web to access bytes
      );

      if (result == null || result.files.isEmpty) return [];

      // Convert to base64
      final base64Images = result.files
          .where((file) => file.bytes != null)
          .map((file) => base64Encode(file.bytes!))
          .toList();

      return base64Images;
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }
}
