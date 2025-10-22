import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File, Platform;
import 'package:image/image.dart' as img_lib;

// Resize / compress settings
const int _maxWidth = 1280; // resize images wider than this
const int _jpegQuality = 75; // output JPEG quality (0-100)

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
        List<String> base64List = [];
        for (var file in result.files) {
          if (file.bytes == null) continue;
          final bytes = file.bytes!;
          try {
            final decoded = img_lib.decodeImage(bytes);
            if (decoded != null) {
              img_lib.Image resized = decoded;
              if (decoded.width > _maxWidth) {
                resized = img_lib.copyResize(decoded, width: _maxWidth);
              }
              final jpg = img_lib.encodeJpg(resized, quality: _jpegQuality);
              base64List.add(base64Encode(jpg));
            } else {
              base64List.add(base64Encode(bytes));
            }
          } catch (e) {
            base64List.add(base64Encode(bytes));
          }
        }
        return base64List;
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
          List<String> base64List = [];
          for (var file in result.files) {
            if (file.bytes == null) continue;
            final bytes = file.bytes!;
            try {
              final decoded = img_lib.decodeImage(bytes);
              if (decoded != null) {
                img_lib.Image resized = decoded;
                if (decoded.width > _maxWidth) {
                  resized = img_lib.copyResize(decoded, width: _maxWidth);
                }
                final jpg = img_lib.encodeJpg(resized, quality: _jpegQuality);
                base64List.add(base64Encode(jpg));
              } else {
                base64List.add(base64Encode(bytes));
              }
            } catch (e) {
              base64List.add(base64Encode(bytes));
            }
          }
          return base64List;
        } else {
          // Mobile: use image_picker
          final picker = ImagePicker();
          final pickedFiles = await picker.pickMultiImage();
          if (pickedFiles.isEmpty) return [];
          List<String> base64List = [];
          for (var file in pickedFiles) {
            final bytes = await File(file.path).readAsBytes();

            try {
              // decode image
              final decoded = img_lib.decodeImage(bytes);
              if (decoded != null) {
                img_lib.Image resized = decoded;
                if (decoded.width > _maxWidth) {
                  resized = img_lib.copyResize(decoded, width: _maxWidth);
                }
                final jpg = img_lib.encodeJpg(resized, quality: _jpegQuality);
                base64List.add(base64Encode(jpg));
              } else {
                base64List.add(base64Encode(bytes));
              }
            } catch (e) {
              // on any error, fallback to original bytes
              base64List.add(base64Encode(bytes));
            }
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
