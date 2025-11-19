import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  final FlutterSecureStorage storage;

  // Storage keys
  static const _kEncryptionKey = 'encryption_key';
  static const _kEncryptionIv = 'encryption_iv';

  // Hardcoded encryption credentials (from working app)
  static const String _encryptionKey =
      'XkBrelg5SlE3az9ORzkrbXY4U1ZUeFU5NWt6WnA1cHE=';
  static const String _encryptionIv = 'OVFSKzNfYz8zM25lczQtRQ==';

  EncryptionService({required this.storage});

  /// Initialize encryption keys in secure storage
  Future<void> initializeKeys() async {
    // Always update to ensure we have the correct keys
    await storage.write(key: _kEncryptionKey, value: _encryptionKey);
    await storage.write(key: _kEncryptionIv, value: _encryptionIv);
  }

  /// Get encryption key from storage
  Future<String> getKey() async {
    return await storage.read(key: _kEncryptionKey) ?? _encryptionKey;
  }

  /// Get encryption IV from storage
  Future<String> getIv() async {
    return await storage.read(key: _kEncryptionIv) ?? _encryptionIv;
  }

  /// Encrypt data for sending to server
  Future<String> encryptData(String plainText) async {
    if (plainText.isEmpty) {
      return plainText;
    }

    final keyString = await getKey();
    final ivString = await getIv();

    // Decode exactly like the working app: base64.decode -> utf8.decode -> Key.fromUtf8
    var key = Key.fromUtf8(utf8.decode(base64.decode(keyString)));
    var iv = IV.fromUtf8(utf8.decode(base64.decode(ivString)));

    var encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: null));

    // PKCS7-pad the plaintext bytes and encrypt the raw bytes directly.
    final padded = _pkcs7Pad(Uint8List.fromList(utf8.encode(plainText)));

    // Use encryptBytes to avoid trying to interpret padded bytes as UTF-8 string.
    final encrypted = encrypter.encryptBytes(padded, iv: iv);

    return encrypted.base64;
  }

  /// Decrypt data received from server
  Future<String> decryptData(String encryptedText) async {
    if (encryptedText.isEmpty) {
      return encryptedText;
    }

    final keyString = await getKey();
    final ivString = await getIv();

    // Decode exactly like the working app: base64.decode -> utf8.decode -> Key.fromUtf8
    var key = Key.fromUtf8(utf8.decode(base64.decode(keyString)));
    var iv = IV.fromUtf8(utf8.decode(base64.decode(ivString)));

    var decrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: null));

    try {
      var decrypted = decrypter.decryptBytes(
        Encrypted.fromBase64(encryptedText),
        iv: iv,
      );

      // Remove PKCS7 padding
      final unpaddedData = _pkcs7Unpad(Uint8List.fromList(decrypted));
      return utf8.decode(unpaddedData);
    } catch (e) {
      log('Decryption error: $e');
      return encryptedText; // Return original if decryption fails
    }
  }

  /// PKCS7 padding for AES encryption
  Uint8List _pkcs7Pad(Uint8List data) {
    var blockSize = 16;
    var padLength = blockSize - data.length % blockSize;
    var padding = Uint8List(padLength)..fillRange(0, padLength, padLength);
    return Uint8List.fromList([...data, ...padding]);
  }

  /// Remove PKCS7 padding from decrypted data
  Uint8List _pkcs7Unpad(Uint8List data) {
    if (data.isEmpty) return data;

    var padLength = data.last;
    if (padLength < 1 || padLength > 16) {
      // Padding is invalid, return the original data
      return data;
    }
    return Uint8List.sublistView(data, 0, data.length - padLength);
  }
}
