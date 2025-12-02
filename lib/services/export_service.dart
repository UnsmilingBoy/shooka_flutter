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

      // Define Vazirmatn font style for cells
      final cellStyle = CellStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 11,
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center,
      );

      // Start from row 2 (row 1 is header in template)
      int rowIndex = 1;

      for (var device in devices) {
        // Column 0: ردیف (Row number)
        final cell0 = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
        );
        cell0.value = TextCellValue(rowIndex.toString());
        cell0.cellStyle = cellStyle;

        // Column 1: اسامی نصب (Name)
        final cell1 = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex),
        );
        cell1.value = TextCellValue(device['name']?.toString() ?? '');
        cell1.cellStyle = cellStyle;

        // Column 2: شماره اشتراک (Subscription number)
        final cell2 = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex),
        );
        cell2.value = TextCellValue(
          device['meter_subscription_number']?.toString() ?? '',
        );
        cell2.cellStyle = cellStyle;

        // Column 3: شهر (City)
        final cell3 = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex),
        );
        cell3.value = TextCellValue(device['city']?.toString() ?? '');
        cell3.cellStyle = cellStyle;

        // Column 4: تاریخ نصب (Installation date)
        final cell4 = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex),
        );
        cell4.value = TextCellValue(device['created_at']?.toString() ?? '');
        cell4.cellStyle = cellStyle;

        // Column 5: موبایل مشترک (Subscriber mobile)
        final cell5 = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex),
        );
        cell5.value = TextCellValue(device['phone_number1']?.toString() ?? '');
        cell5.cellStyle = cellStyle;

        // Column 6: شماره سریال دستگاه (Device serial number)
        final cell6 = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex),
        );
        cell6.value = TextCellValue(device['serial_number']?.toString() ?? '');
        cell6.cellStyle = cellStyle;

        // Column 7: توضیحات (Description/Installation address)
        final cell7 = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex),
        );
        cell7.value = TextCellValue(device['linker_person1']?.toString() ?? '');
        cell7.cellStyle = cellStyle;

        // Column 8: اسامی نصاب (Installer name/Creator)
        final cell8 = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex),
        );
        cell8.value = TextCellValue(device['creator']?.toString() ?? '');
        cell8.cellStyle = cellStyle;

        // Column 9: شماره قرارداد (Contract number - not in API)
        final cell9 = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex),
        );
        cell9.value = TextCellValue('');
        cell9.cellStyle = cellStyle;

        // Column 10: آدرس (Address)
        final cell10 = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex),
        );
        cell10.value = TextCellValue(
          device['installation_address']?.toString() ?? '',
        );
        cell10.cellStyle = cellStyle;

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
      final blob = html.Blob([
        bytes,
      ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement()
        ..href = url
        ..download = fileName
        ..style.display = 'none';
      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
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
