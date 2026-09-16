import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shooka_flutter/models/event_data_class.dart';
import 'package:shooka_flutter/models/inventory_form_data_class.dart';

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

  /// Export inventory forms to Excel file
  Future<void> exportInventoryForms(List<InventoryFormItem> forms) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['فرم های انبار'];

      final headerStyle = CellStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 11,
        bold: true,
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center,
      );

      final cellStyle = CellStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 11,
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center,
      );

      final headers = [
        'ردیف',
        'نوع فرم',
        'عنوان',
        'طرف حساب',
        'شماره سریال',
        'تعداد',
        'تاریخ ثبت',
        'ثبت کننده',
        'وضعیت',
        'توضیحات',
      ];

      for (var i = 0; i < headers.length; i++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }

      for (var row = 0; row < forms.length; row++) {
        final form = forms[row];
        final values = [
          (row + 1).toString(),
          form.id.toString(),
          form.destination,
          form.exportUnit,
          form.postingType,
          form.deviceCount.toString(),
          form.createdAt,
          form.createdBy,
          form.amount,
          form.note,
        ];

        for (var col = 0; col < values.length; col++) {
          final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1),
          );
          cell.value = TextCellValue(values[col]);
          cell.cellStyle = cellStyle;
        }
      }

      final fileBytes = excel.save();
      if (fileBytes == null) {
        throw Exception('Failed to generate Excel file');
      }

      await _saveFile(
        Uint8List.fromList(fileBytes),
        'inventory_forms_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      );
    } catch (e) {
      log('Error exporting inventory forms to Excel: $e');
      rethrow;
    }
  }

  /// Export events to Word document
  /// [events] - List of Event objects
  Future<void> exportEvents(List<Event> events) async {
    try {
      log('Starting events export with ${events.length} events');

      // Generate HTML content that can be opened in Word
      final htmlContent = _generateEventsHtml(events);

      // Convert to bytes with UTF-8 encoding with BOM for proper RTL display in Word
      final List<int> bytes = [0xEF, 0xBB, 0xBF]; // UTF-8 BOM
      bytes.addAll(utf8.encode(htmlContent));
      final fileBytes = Uint8List.fromList(bytes);

      await _saveFile(
        fileBytes,
        'events_export_${DateTime.now().millisecondsSinceEpoch}.doc',
      );
      log('Word file exported successfully with ${events.length} events');
    } catch (e) {
      log('Error exporting events to Word: $e');
      rethrow;
    }
  }

  /// Generate HTML content for events that can be opened in Word
  String _generateEventsHtml(List<Event> events) {
    final buffer = StringBuffer();
    buffer.writeln('<html xmlns:o="urn:schemas-microsoft-com:office:office"');
    buffer.writeln('xmlns:w="urn:schemas-microsoft-com:office:word"');
    buffer.writeln('xmlns="http://www.w3.org/TR/REC-html40">');
    buffer.writeln('<head>');
    buffer.writeln(
      '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
    );
    buffer.writeln('<meta name="ProgId" content="Word.Document">');
    buffer.writeln('<style>');
    buffer.writeln('@page { size: A4; margin: 2cm; }');
    buffer.writeln(
      'body { font-family: "B Nazanin", Tahoma, Arial; direction: rtl; font-size: 12pt; }',
    );
    buffer.writeln(
      'h1 { text-align: center; color: #2c3e50; font-size: 18pt; margin-bottom: 20px; }',
    );
    buffer.writeln('h2 { font-size: 14pt; color: #34495e; margin: 10px 0; }');
    buffer.writeln('h3 { font-size: 12pt; color: #7f8c8d; margin: 10px 0; }');
    buffer.writeln(
      '.header-info { text-align: center; margin-bottom: 20px; border-bottom: 2px solid #3498db; padding-bottom: 10px; }',
    );
    buffer.writeln(
      '.event { margin-bottom: 30px; border: 1px solid #bdc3c7; padding: 15px; page-break-inside: avoid; }',
    );
    buffer.writeln(
      '.event-header { background-color: #ecf0f1; padding: 10px; margin-bottom: 10px; border-right: 4px solid #3498db; }',
    );
    buffer.writeln('.info-row { margin: 8px 0; padding: 5px; }');
    buffer.writeln('.label { font-weight: bold; color: #2c3e50; }');
    buffer.writeln(
      '.detail { margin: 5px 0; padding: 8px; border-right: 2px solid #95a5a6; }',
    );
    buffer.writeln(
      '.detail.checked { background-color: #d5f4e6; border-right-color: #27ae60; }',
    );
    buffer.writeln(
      '.detail.unchecked { background-color: #fadbd8; border-right-color: #e74c3c; }',
    );
    buffer.writeln('.status-icon { font-weight: bold; margin-left: 5px; }');
    buffer.writeln(
      'hr { border: none; border-top: 1px solid #bdc3c7; margin: 20px 0; }',
    );
    buffer.writeln('</style>');
    buffer.writeln('</head>');
    buffer.writeln('<body>');

    buffer.writeln('<div class="header-info">');
    buffer.writeln('<h1>گزارش رویدادها</h1>');
    buffer.writeln(
      '<p><span class="label">تاریخ تولید:</span> ${_getCurrentPersianDate()}</p>',
    );
    buffer.writeln(
      '<p><span class="label">تعداد رویدادها:</span> ${events.length}</p>',
    );
    buffer.writeln('</div>');

    for (var i = 0; i < events.length; i++) {
      final event = events[i];
      buffer.writeln('<div class="event">');
      buffer.writeln('<div class="event-header">');
      buffer.writeln('<h2>رویداد ${i + 1}: ${_escapeHtml(event.title)}</h2>');
      buffer.writeln('</div>');

      buffer.writeln('<div class="info-row">');
      buffer.writeln(
        '<span class="label">دستگاه:</span> ${_escapeHtml(event.deviceName)}',
      );
      buffer.writeln('</div>');

      buffer.writeln('<div class="info-row">');
      buffer.writeln(
        '<span class="label">ایجادکننده:</span> ${_escapeHtml(event.creator)}',
      );
      buffer.writeln('</div>');

      buffer.writeln('<div class="info-row">');
      buffer.writeln(
        '<span class="label">زمان:</span> ${_escapeHtml(event.timestamp)}',
      );
      buffer.writeln('</div>');

      final registeredRequester = _requesterName(event.registeredRequester);
      if (registeredRequester.isNotEmpty) {
        buffer.writeln('<div class="info-row">');
        buffer.writeln(
          '<span class="label">درخواست‌دهنده (کاربر ثبت‌شده):</span> ${_escapeHtml(registeredRequester)}',
        );
        buffer.writeln('</div>');
      }

      if (event.externalRequester != null &&
          event.externalRequester!.isNotEmpty) {
        buffer.writeln('<div class="info-row">');
        buffer.writeln(
          '<span class="label">درخواست‌دهنده خارجی:</span> ${_escapeHtml(event.externalRequester!)}',
        );
        buffer.writeln('</div>');
      }

      if (event.requesterPhoneNumber != null &&
          event.requesterPhoneNumber!.isNotEmpty) {
        buffer.writeln('<div class="info-row">');
        buffer.writeln(
          '<span class="label">شماره درخواست‌دهنده:</span> ${_escapeHtml(event.requesterPhoneNumber!)}',
        );
        buffer.writeln('</div>');
      }

      if (event.domain != null && event.domain!.isNotEmpty) {
        buffer.writeln('<div class="info-row">');
        buffer.writeln(
          '<span class="label">نوع رویداد:</span> ${_escapeHtml(event.domain!)}',
        );
        buffer.writeln('</div>');
      }

      buffer.writeln('<h3>جزئیات رویداد:</h3>');

      for (var detail in event.eventCategoryDetails) {
        final cssClass = detail.isChecked ? 'checked' : 'unchecked';
        final status = detail.isChecked ? '✓' : '✗';
        buffer.writeln('<div class="detail $cssClass">');
        buffer.writeln('<span class="status-icon">$status</span>');
        buffer.writeln(
          '<span class="label">${_escapeHtml(detail.category)}:</span> ${_escapeHtml(detail.text)}',
        );
        buffer.writeln('</div>');
      }

      buffer.writeln('</div>');
      if (i < events.length - 1) {
        buffer.writeln('<hr/>');
      }
    }

    buffer.writeln('</body>');
    buffer.writeln('</html>');

    return buffer.toString();
  }

  /// Escape HTML special characters
  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  /// Resolve the display name of a registered requester, which may be a
  /// plain string or an object (e.g. `{"username": "...", "first_name": ...}`).
  String _requesterName(dynamic requester) {
    if (requester == null) return '';
    if (requester is String) return requester;
    if (requester is Map) {
      final firstName = requester['first_name']?.toString();
      final username = requester['username']?.toString();
      final name = requester['name']?.toString();
      return [firstName, name, username]
          .where((s) => s != null && s.isNotEmpty)
          .join(' ');
    }
    return requester.toString();
  }

  /// Get current Persian date
  String _getCurrentPersianDate() {
    final now = DateTime.now();
    return '${now.year}/${now.month}/${now.day} - ${now.hour}:${now.minute}';
  }

  /// Save file based on platform
  Future<void> _saveFile(Uint8List bytes, String fileName) async {
    if (kIsWeb) {
      // Web: Download using browser
      final mimeType = fileName.endsWith('.docx')
          ? 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
          : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

      final blob = html.Blob([bytes], mimeType);
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
