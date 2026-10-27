import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shooka_flutter/models/device_flowchart_step_data_class.dart';
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

  /// Payload keys that may carry a device's per-step flowchart history. The
  /// list endpoint has used more than one spelling over time, so all of them
  /// are accepted — a wrong guess here silently yields zero columns.
  static const _flowHistoryKeys = <String>[
    'flowcharthistory',
    'flowchart_history',
    'device_flowchart',
    'flowchart_items',
    'flowchart',
  ];

  /// Coerces the shapes a "done" flag arrives in (bool, 0/1, "true", "done",
  /// …) into a bool. `null` means unknown and renders as a blank cell.
  static bool? _asDone(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value.toString().trim().toLowerCase();
    if (text.isEmpty || text == 'null') return null;
    if (const {'true', '1', 'done', 'completed', 'finished'}.contains(text)) {
      return true;
    }
    if (const {'false', '0', 'pending', 'not_done', 'undone'}.contains(text)) {
      return false;
    }
    return null;
  }

  static String? _flowLabelOf(Map entry) {
    for (final key in const ['label', 'name', 'title', 'step']) {
      final text = (entry[key] ?? '').toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  static bool? _flowDoneOf(Map entry) {
    for (final key in const [
      'is_done',
      'done',
      'isDone',
      'completed',
      'is_completed',
    ]) {
      final done = _asDone(entry[key]);
      if (done != null) return done;
    }
    // A finished step usually carries a timestamp even when the flag is
    // absent, so treat a non-empty `done_at` as done.
    for (final key in const ['done_at', 'completed_at', 'finished_at']) {
      final text = (entry[key] ?? '').toString().trim();
      if (text.isNotEmpty && text != 'null') return true;
    }
    return null;
  }

  static Map<String, bool?> _parseFlowHistory(dynamic raw) {
    final progress = <String, bool?>{};
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          final label = _flowLabelOf(item);
          if (label == null) continue;
          progress[label] = _flowDoneOf(item);
        } else if (item is String && item.trim().isNotEmpty) {
          progress[item.trim()] = null;
        }
      }
      return progress;
    }
    if (raw is Map) {
      // A single step object rather than a `label -> value` map.
      final single = _flowLabelOf(raw);
      if (single != null) return {single: _flowDoneOf(raw)};
      // `{label: true}` and `{label: {is_done: true}}` both occur.
      raw.forEach((key, value) {
        final label = key.toString().trim();
        if (label.isEmpty) return;
        progress[label] = value is Map ? _flowDoneOf(value) : _asDone(value);
      });
    }
    return progress;
  }

  /// Reads a device's flowchart history as `label -> done`. Returns an empty
  /// map when the row carries no flowchart data at all.
  static Map<String, bool?> _flowchartProgress(Map<String, dynamic> device) {
    for (final key in _flowHistoryKeys) {
      final progress = _parseFlowHistory(device[key]);
      if (progress.isNotEmpty) return progress;
    }
    return const {};
  }

  /// Fills [progressRows] from the per-device flowchart endpoint, used when
  /// the list payload carried no history. Concurrency is bounded so a large
  /// export does not open hundreds of sockets at once.
  Future<void> _fillFlowchartFromApi(
    List<Map<String, dynamic>> devices,
    List<Map<String, bool?>> progressRows,
    Future<List<DeviceFlowchartStep>> Function(int deviceId) loadFlowchart,
  ) async {
    var next = 0;
    Future<void> worker() async {
      while (next < devices.length) {
        final index = next++;
        final id = int.tryParse((devices[index]['id'] ?? '').toString());
        if (id == null) continue;
        try {
          final steps = await loadFlowchart(id);
          progressRows[index] = {
            for (final step in steps) step.label: step.isDone,
          };
        } catch (e) {
          log('Flowchart fetch failed for device $id: $e');
        }
      }
    }

    await Future.wait(List.generate(8, (_) => worker()));
  }

  /// Export devices to Excel file
  /// [devices] - List of device data maps from API
  /// [loadFlowchart] - optional per-device flowchart loader, used only when
  /// the list payload carries no flowchart history (see [_flowchartProgress]).
  Future<void> exportDevices(
    List<Map<String, dynamic>> devices, {
    Future<List<DeviceFlowchartStep>> Function(int deviceId)? loadFlowchart,
  }) async {
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

      // NOTE: Do not overwrite the header row here. Headers (with orange
      // fill) live in assets/export.xlsx. Rewriting them in code breaks the
      // template fill on save (excel pkg drops fills already in the file),
      // which is why headers lost their orange background.
      // Column order in template: ردیف، اسامی نصب، شماره اشتراک، شهر،
      // تاریخ نصب، موبایل مشترک، شماره سریال دستگاه، کد داخلی دستگاه،
      // توضیحات، اسامی نصاب، شماره قرارداد، آدرس.
      //
      // Flowchart history columns are APPENDED after them (column 12+) —
      // existing header cells are never touched, so template fills survive.

      // Style for the appended flowchart header cells.
      final flowHeaderStyle = CellStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 11,
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      // Collect the flowchart step labels (stable, first-seen order) from
      // the rows themselves, since the labels come from the re-orderable
      // backend flowchart template. Rows without history are skipped.
      final progressRows = [
        for (final device in devices) _flowchartProgress(device),
      ];

      // The devices-list serializer does not always include flowchart
      // history — when it is missing everywhere, ask the per-device endpoint
      // instead of silently dropping the columns.
      if (devices.isNotEmpty &&
          progressRows.every((row) => row.isEmpty) &&
          loadFlowchart != null) {
        log(
          'No flowchart history in export payload — fetching per device '
          'for ${devices.length} device(s)...',
        );
        await _fillFlowchartFromApi(devices, progressRows, loadFlowchart);
      }

      final flowLabels = <String>[];
      for (final progress in progressRows) {
        for (final label in progress.keys) {
          if (!flowLabels.contains(label)) flowLabels.add(label);
        }
      }

      if (flowLabels.isEmpty && devices.isNotEmpty) {
        log(
          'Flowchart columns skipped — no flowchart data found. '
          'Device keys: ${devices.first.keys.toList()}',
        );
      } else {
        log('Flowchart columns: ${flowLabels.length} step(s)');
      }

      // Header row for the flowchart columns (row 1 in the sheet).
      for (var i = 0; i < flowLabels.length; i++) {
        final headerCell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 12 + i, rowIndex: 0),
        );
        headerCell.value = TextCellValue(flowLabels[i]);
        headerCell.cellStyle = flowHeaderStyle;
      }

      // Start from row 2 (row 1 is header in template)
      int rowIndex = 1;

      if (devices.isNotEmpty) {
        log('Export device keys sample: ${devices.first.keys.toList()}');
      }

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

        // Column 7: کد داخلی دستگاه (Internal device code) - beside serial
        final cellCode = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex),
        );
        cellCode.value = TextCellValue(
          (device['code'] ??
                  device['device_code'] ??
                  device['internal_code'] ??
                  device['internal_device_code'] ??
                  '')
              .toString(),
        );
        cellCode.cellStyle = cellStyle;

        // Column 8: توضیحات (Description/Installation address)
        final cell7 = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex),
        );
        cell7.value = TextCellValue(device['linker_person1']?.toString() ?? '');
        cell7.cellStyle = cellStyle;

        // Column 9: اسامی نصاب (Installer name/Creator)
        final cell8 = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex),
        );
        cell8.value = TextCellValue(device['creator']?.toString() ?? '');
        cell8.cellStyle = cellStyle;

        // Column 10: شماره قرارداد (Contract number - not in API)
        final cell9 = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex),
        );
        cell9.value = TextCellValue('');
        cell9.cellStyle = cellStyle;

        // Column 11: آدرس (Address)
        final cell10 = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: rowIndex),
        );
        cell10.value = TextCellValue(
          device['installation_address']?.toString() ?? '',
        );
        cell10.cellStyle = cellStyle;

        // Flowchart history columns (appended, column 12+): ✔ done,
        // ✘ not done, blank when the step is unknown / legacy nulls.
        // `rowIndex` starts at 1 and advances once per device, so the row's
        // progress map is the one at `rowIndex - 1`.
        final progress = progressRows[rowIndex - 1];
        for (var i = 0; i < flowLabels.length; i++) {
          final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 12 + i, rowIndex: rowIndex),
          );
          final done = progress[flowLabels[i]];
          cell.value = TextCellValue(done == null ? '' : (done ? '✔' : '✘'));
          cell.cellStyle = cellStyle;
        }

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
        'کد داخلی دستگاه',
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

  static String? _vazirmatnFontFaceCache;

  /// Loads assets/fonts/Vazirmatn-Regular.ttf and returns an embedded
  /// `@font-face` rule (base64 data URI) so the Word (.doc) HTML export
  /// renders with Vazirmatn even on systems without the font installed.
  /// Returns '' on failure so export still works with fallback fonts.
  Future<String> _vazirmatnFontFace() async {
    if (_vazirmatnFontFaceCache != null) return _vazirmatnFontFaceCache!;
    try {
      final data = await rootBundle.load('assets/fonts/Vazirmatn-Regular.ttf');
      final b64 = base64Encode(data.buffer.asUint8List());
      _vazirmatnFontFaceCache =
          "@font-face { font-family: 'Vazirmatn'; src: url(data:font/ttf;base64,$b64) format('truetype'); font-weight: 400; font-style: normal; mso-font-charset: 178; mso-generic-font-family: swiss; mso-font-pitch: variable; mso-font-signature: 8193 -2147483648 8 0 64 0; }"
          " @font-face { font-family: 'B Nazanin'; mso-font-charset: 178; mso-generic-font-family: auto; mso-font-pitch: variable; mso-font-signature: 8193 -2147483648 8 0 64 0; }";
    } catch (e) {
      log('Could not embed Vazirmatn font: $e');
      _vazirmatnFontFaceCache = '';
    }
    return _vazirmatnFontFaceCache!;
  }

  /// Export events to Word document
  /// [events] - List of Event objects
  Future<void> exportEvents(List<Event> events) async {
    try {
      log('Starting events export with ${events.length} events');

      // Embed Vazirmatn so Word uses it without requiring installation
      final fontFace = await _vazirmatnFontFace();
      // Generate HTML content that can be opened in Word
      final htmlContent = _generateEventsHtml(events, fontFaceCss: fontFace);

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

  /// Generate compact, print-friendly HTML for events (opened in Word).
  /// Layout: cover header + summary strip + one compact card per event.
  /// Uses tables only (Word-compatible) — no flex/grid.
  /// [fontFaceCss] is the embedded `@font-face` for Vazirmatn (may be '').
  String _generateEventsHtml(List<Event> events, {String fontFaceCss = ''}) {
    final cards = [
      for (var i = 0; i < events.length; i++) _eventCard(events[i], i),
    ].join();

    return '''
<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word" xmlns="http://www.w3.org/TR/REC-html40" lang="FA">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta name="ProgId" content="Word.Document">
<!--[if gte mso 9]><xml><w:WordDocument><w:View>Print</w:View><w:DoNotOptimizeForBrowser/></w:WordDocument><w:LatentStyles DefLockedState="false" DefUnhideWhenUsed="false"/></xml><![endif]-->
<style>
$fontFaceCss
@page { size: A4; margin: 1.4cm 1.2cm; }
body, table, td, th, h1, h2, h3, p, span, div, li { font-family: "Vazirmatn", "B Nazanin", Tahoma, Arial; mso-ascii-font-family: Vazirmatn; mso-hansi-font-family: Vazirmatn; mso-bidi-font-family: "B Nazanin"; }
p.MsoNormal, li.MsoNormal, div.MsoNormal, table.MsoTableGrid, span.MsoNormal { font-family: "Vazirmatn", "B Nazanin", Tahoma, Arial; mso-ascii-font-family: Vazirmatn; mso-hansi-font-family: Vazirmatn; mso-bidi-font-family: "B Nazanin"; mso-style-parent: ""; }
body { direction: rtl; font-size: 12pt; color: #2b2b2b; line-height: 1.8; margin: 0; mso-bidi-font-family: "B Nazanin"; }
.cover { background: #d6d6d6; color: #000000; }
.cover h1 { font-size: 20pt; margin: 0 0 2px 0; }
.cover p { font-size: 12pt; margin: 0; }
.card { border: .75pt solid #555555; margin-bottom: 10px; page-break-inside: avoid; }
.card-head { background: #ededed; border-bottom: .75pt solid #555555; }
.num { display: inline-block; color: #333333; font-weight: bold; font-size: 12pt; width: 24pt; height: 24pt; text-align: center; }
.title { font-size: 14pt; font-weight: bold; color: #2b2b2b; }
.ltr { direction: ltr; unicode-bidi: embed; }
.badge { display: inline-block; font-size: 12pt; font-weight: bold; padding: 2px 10px; border: .5pt solid #555555; }
.badge-blue { background: #ffffff; color: #333333; }
.badge-gray { background: #f4f4f4; color: #333333; }
.meta td { font-size: 12pt; padding: 3px 8px; border-bottom: .5pt dotted #aaaaaa; color: #2b2b2b; }
.meta .k { color: #666666; white-space: nowrap; width: 1%; }
.meta .v { font-weight: bold; color: #2b2b2b; }
.details th { background: #d6d6d6; color: #000000; font-size: 12pt; padding: 4px 8px; }
.details td { font-size: 12pt; padding: 4px 8px; border-bottom: .5pt solid #bbbbbb; color: #2b2b2b; }
.row-alt td { background: #f6f6f6; }
.footer { text-align: center; font-size: 12pt; color: #777777; border-top: .75pt solid #999999; }
</style>
</head>
<body dir="rtl" lang="FA">

<table class="cover" width="100%" cellpadding="10" cellspacing="0"><tr>
<td>
<h1>گزارش رویدادها</h1>
<p>تولید: ${_escapeHtml(_getCurrentPersianDate())} &nbsp;•&nbsp; سامانه شوکا</p>
</td>
<td align="left" valign="middle">
<span class="badge" style="color:#000000;">${events.length} رویداد</span>
</td>
</tr></table>

<br/>

$cards

</body>
</html>''';
  }

  /// One compact event card (header + 2-col meta + details table).
  String _eventCard(Event e, int index) {
    final req = _requesterName(e.registeredRequester);
    final ext = (e.externalRequester ?? '').trim();
    final requester = req.isNotEmpty ? req : ext;
    final domain = (e.domain ?? '').trim();
    final domainBadge = domain.isEmpty
        ? ''
        : '<span class="badge badge-blue">${_escapeHtml(_domainLabel(domain))}</span>';

    final phone = (e.requesterPhoneNumber ?? '').trim().isEmpty
        ? '—'
        : e.requesterPhoneNumber!.trim();
    final dateLtr = _ltr(e.timestamp);
    final metaRows = [
      ['دستگاه', e.deviceName, 'زمان ثبت', dateLtr],
      [
        'ایجادکننده',
        e.creator,
        'درخواست‌دهنده',
        requester.isEmpty ? '—' : requester,
      ],
      ['تماس', phone, '', ''],
    ];

    String val(String s) => s.startsWith('<span') ? s : _escapeHtml(s);
    final meta = metaRows
        .map(
          (r) => r[2].isEmpty
              ? '<tr><td class="k">${r[0]}:</td><td class="v" colspan="3">${val(r[1])}</td></tr>'
              : '<tr><td class="k">${r[0]}:</td><td class="v">${val(r[1])}</td>'
                    '<td class="k">${r[2]}:</td><td class="v">${val(r[3])}</td></tr>',
        )
        .join();

    final details = [
      for (var j = 0; j < e.eventCategoryDetails.length; j++)
        _detailRow(e.eventCategoryDetails[j], j),
    ].join();

    return '''
<table class="card" width="100%" cellpadding="0" cellspacing="0">
<tr class="card-head"><td style="padding:6px 8px;">
<span class="num">${index + 1} - </span>
&nbsp;<span class="title">${_escapeHtml(e.title.isEmpty ? 'بدون عنوان' : e.title)}</span>
&nbsp;$domainBadge
</td></tr>
<tr><td style="padding:0;">
<table class="meta" width="100%" cellpadding="0" cellspacing="0">$meta</table>
<table class="details" width="100%" cellpadding="0" cellspacing="0">
<tr><th width="6%">#</th><th align="right">اقدام / شرح</th></tr>
$details
</table>
</td></tr>
</table>''';
  }

  /// Single compact detail row: "category — text".
  String _detailRow(EventCategoryDetails d, int j) {
    final cat = d.category.trim();
    final txt = d.text.trim();
    final desc = cat.isEmpty
        ? (txt.isEmpty ? '—' : txt)
        : txt.isEmpty
        ? cat
        : '$cat — $txt';
    final price = d.price != null
        ? ' <span class="badge badge-gray">${d.price}</span>'
        : '';
    final alt = j.isOdd ? ' class="row-alt"' : '';
    return '<tr$alt><td align="center">${j + 1}</td><td>${_escapeHtml(desc)}$price</td></tr>';
  }

  /// Maps API domain values to Persian labels for display.
  String _domainLabel(String domain) {
    switch (domain.trim().toLowerCase()) {
      case 'software_support':
      case 'software':
      case 'software_event':
      case 'software_events':
        return 'پشتیبانی نرم افزاری';
      case 'device':
      case 'device_event':
      case 'device_events':
      case 'device_support':
      case 'installer':
      case 'installer_event':
      case 'installer_events':
        return 'پشتیبانی نصاب';
      default:
        return domain;
    }
  }

  /// Wraps a date/time string so it always renders LTR inside RTL doc.
  String _ltr(String text) =>
      '<span class="ltr" dir="ltr">${_escapeHtml(text)}</span>';

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
      return [
        firstName,
        name,
        username,
      ].where((s) => s != null && s.isNotEmpty).join(' ');
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
      final mimeType = fileName.endsWith('.doc')
          ? 'application/msword'
          : fileName.endsWith('.docx')
          ? 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
          : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

      final blob = html.Blob([bytes], mimeType);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement()
        ..href = url
        ..download = fileName
        ..style.display = 'none';
      html.document.body?.append(anchor);
      // Single programmatic click. Revoke deferred: revoking synchronously
      // can abort the download in some browsers (user retries → "twice").
      anchor.click();
      anchor.remove();
      Future.delayed(const Duration(seconds: 5), () {
        try {
          html.Url.revokeObjectUrl(url);
        } catch (_) {}
      });
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
