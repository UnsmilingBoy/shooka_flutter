import 'dart:developer';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// ignore: avoid_web_libraries_in_flutter
import 'package:universal_html/html.dart' as html;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ExportService {
  /// Fetches the template Excel file from assets
  Future<Excel> _loadTemplate() async {
    final ByteData data = await rootBundle.load('assets/export.xlsx');
    final Uint8List bytes = data.buffer.asUint8List();
    return Excel.decodeBytes(bytes);
  }

  /// Export devices to Excel file
  /// [devices] - List of device data maps from API
  Future<void> exportDevices(List<Map<String, dynamic>> devices) async {
    try {
      // Load the template
      final excel = await _loadTemplate();

      // Get the first sheet (assuming it's the template sheet)
      final sheetName = excel.tables.keys.first;
      final sheet = excel[sheetName];

      // Start from row 2 (row 1 is header in template)
      int rowIndex = 1;

      for (var device in devices) {
        // Column 0: ردیف (Row number)
        sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
            )
            .value = TextCellValue(
          rowIndex.toString(),
        );

        // Column 1: اسامی نصب (Name)
        sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex),
            )
            .value = TextCellValue(
          device['name']?.toString() ?? '',
        );

        // Column 2: شماره اشتراک (Subscription number)
        sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex),
            )
            .value = TextCellValue(
          device['meter_subscription_number']?.toString() ?? '',
        );

        // Column 3: شهر (City)
        sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex),
            )
            .value = TextCellValue(
          device['city']?.toString() ?? '',
        );

        // Column 4: تاریخ نصب (Installation date)
        sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex),
            )
            .value = TextCellValue(
          device['created_at']?.toString() ?? '',
        );

        // Column 5: موبایل مشترک (Subscriber mobile)
        sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex),
            )
            .value = TextCellValue(
          device['phone_number1']?.toString() ?? '',
        );

        // Column 6: شماره سریال دستگاه (Device serial number)
        sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex),
            )
            .value = TextCellValue(
          device['serial_number']?.toString() ?? '',
        );

        // Column 7: توضیحات (Description/Installation address)
        sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex),
            )
            .value = TextCellValue(
          device['linker_person1']?.toString() ?? '',
        );

        // Column 8: اسامی نصاب (Installer name/Creator)
        sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex),
            )
            .value = TextCellValue(
          device['creator']?.toString() ?? '',
        );

        // Column 9: شماره قرارداد (Contract number - not in API)
        sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex),
            )
            .value = TextCellValue(
          '',
        );

        // آدرس
        sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex),
            )
            .value = TextCellValue(
          device['installation_address']?.toString() ?? '',
        );

        rowIndex++;
      }

      // Save the file
      final fileBytes = excel.save();
      if (fileBytes == null) {
        throw Exception('Failed to generate Excel file');
      }

      await _saveFile(Uint8List.fromList(fileBytes), 'devices_export.xlsx');
      log('Excel file exported successfully with ${devices.length} devices');
    } catch (e) {
      log('Error exporting to Excel: $e');
      rethrow;
    }
  }

  /// Save file based on platform
  Future<void> _saveFile(Uint8List bytes, String fileName) async {
    if (kIsWeb) {
      // Web: Download using browser
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // Mobile/Desktop: Save to downloads folder
      final directory =
          await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      log('File saved to: $filePath');
    }
  }
}
