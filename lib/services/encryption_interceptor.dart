import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'encryption_service.dart';

class EncryptionInterceptor extends Interceptor {
  final EncryptionService encryptionService;

  EncryptionInterceptor(this.encryptionService);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Log the endpoint being called
      log('API Request: ${options.method} ${options.path}');

      // Encrypt request data if it exists
      if (options.data != null) {
        String plainData;

        // Convert data to JSON string
        if (options.data is Map || options.data is List) {
          plainData = jsonEncode(options.data);
        } else if (options.data is String) {
          plainData = options.data;
        } else {
          plainData = options.data.toString();
        }

        log('Encrypting request data: $plainData');

        // Encrypt the data
        final encryptedData = await encryptionService.encryptData(plainData);

        // Replace the original data with encrypted data (use 'ciphertext' to match server)
        options.data = {'ciphertext': encryptedData};

        log('Encrypted request data sent');
      }
    } catch (e) {
      log('Encryption error: $e');
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    try {
      // Decrypt response data if it exists
      if (response.data != null) {
        // Check if response has encrypted data field (either 'data' or 'ciphertext')
        if (response.data is Map) {
          String? encryptedData;

          if (response.data['data'] != null) {
            encryptedData = response.data['data'] as String;
          } else if (response.data['ciphertext'] != null) {
            encryptedData = response.data['ciphertext'] as String;
          }

          if (encryptedData != null) {
            log('Decrypting response data...');

            // Decrypt the data
            final decryptedData = await encryptionService.decryptData(
              encryptedData,
            );

            log('Decrypted response: $decryptedData');

            // Parse the decrypted JSON string back to object
            try {
              response.data = jsonDecode(decryptedData);
            } catch (e) {
              // If not valid JSON, keep as string
              response.data = decryptedData;
            }
          }
        } else if (response.data is String) {
          // Try to decrypt if entire response is a string
          try {
            final decryptedData = await encryptionService.decryptData(
              response.data,
            );

            // Try to parse as JSON
            try {
              response.data = jsonDecode(decryptedData);
            } catch (e) {
              response.data = decryptedData;
            }
          } catch (e) {
            // If decryption fails, assume it's not encrypted
            log('Response not encrypted or decryption failed: $e');
          }
        }
      }
    } catch (e) {
      log('Decryption error: $e');
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Try to decrypt error response if it exists
    try {
      log(
        'Error interceptor - response data type: ${err.response?.data.runtimeType}',
      );
      log('Error interceptor - response data: ${err.response?.data}');

      if (err.response?.data != null) {
        if (err.response!.data is Map) {
          String? encryptedData;

          if (err.response!.data['data'] != null) {
            encryptedData = err.response!.data['data'] as String;
          } else if (err.response!.data['ciphertext'] != null) {
            encryptedData = err.response!.data['ciphertext'] as String;
          }

          if (encryptedData != null) {
            log('Decrypting error response...');
            final decryptedData = await encryptionService.decryptData(
              encryptedData,
            );
            log('Decrypted error response: $decryptedData');

            try {
              err.response!.data = jsonDecode(decryptedData);
            } catch (e) {
              err.response!.data = decryptedData;
            }
          }
        } else if (err.response!.data is String) {
          // Try to decrypt if entire response is a string
          log('Attempting to decrypt string error response...');
          try {
            final decryptedData = await encryptionService.decryptData(
              err.response!.data,
            );
            log('Decrypted error response: $decryptedData');

            try {
              err.response!.data = jsonDecode(decryptedData);
            } catch (e) {
              err.response!.data = decryptedData;
            }
          } catch (e) {
            log('Error response decryption failed: $e');
          }
        }
      }
    } catch (e) {
      log('Error decryption failed: $e');
    }

    handler.next(err);
  }
}
