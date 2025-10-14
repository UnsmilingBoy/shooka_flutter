import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File, Platform;

class ImageService {
  Future<List<String>> pickMultipleImages() async {
    try {
      if (kIsWeb) {
        // Web: use file_picker
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: true,
          withData: true,
        );
        if (result == null || result.files.isEmpty) return [];
        return result.files
            .where((file) => file.bytes != null)
            .map((file) => base64Encode(file.bytes!))
            .toList();
      } else {
        // Desktop or Mobile
        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          // Desktop: use file_picker
          final result = await FilePicker.platform.pickFiles(
            type: FileType.image,
            allowMultiple: true,
            withData: true,
          );
          if (result == null || result.files.isEmpty) return [];
          return result.files
              .where((file) => file.bytes != null)
              .map((file) => base64Encode(file.bytes!))
              .toList();
        } else {
          // Mobile: use image_picker
          final picker = ImagePicker();
          final pickedFiles = await picker.pickMultiImage();
          if (pickedFiles.isEmpty) return [];
          List<String> base64List = [];
          for (var file in pickedFiles) {
            final bytes = await File(file.path).readAsBytes();
            base64List.add(base64Encode(bytes));
          }
          return base64List;
        }
      }
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }
}
