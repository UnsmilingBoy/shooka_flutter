import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:excel/excel.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:shooka_flutter/models/inventory_form_data_class.dart';

/// Builds the inventory-forms workbook, split by the day each form was
/// received.
///
/// Kept free of Flutter/platform imports so the layout can be exercised from a
/// plain Dart script; [ExportService] owns saving/downloading the bytes.
///
/// Two sheets are written:
/// * «خلاصه» — a KPI strip, one row per day (forms by type, devices, install
///   items, that day's destinations and the merged internal-code range) and a
///   grand total.
/// * «فرم‌ها» — every form with all of its data, grouped under a day banner
///   that repeats that day's totals, so each day reads as its own block.
///
/// Days run newest-first; forms without a receipt date end up in a final
/// «بدون تاریخ» block.
Uint8List buildInventoryFormsWorkbook(List<InventoryFormItem> forms) {
  final days = _groupFormsByDay(forms);
  final styles = _InventoryStyles();

  final excel = Excel.createExcel();
  final summary = excel['خلاصه'];
  final detail = excel['فرم‌ها'];
  excel.delete('Sheet1');

  _writeSummarySheet(summary, days, forms.length, styles);
  _writeFormsSheet(detail, days, styles);

  final bytes = excel.save();
  if (bytes == null) {
    throw Exception('Failed to generate Excel file');
  }
  return _applySheetRtl(Uint8List.fromList(bytes));
}

/// Forces both worksheets to open right-to-left.
///
/// `excel` 4.0.6 keeps `Sheet.isRTL` in memory but drops it when the sheet
/// XML is written, so the flag is injected into the saved package instead.
/// Without it Excel opens the report left-to-right and the Persian columns
/// read backwards.
Uint8List _applySheetRtl(Uint8List bytes) {
  final archive = ZipDecoder().decodeBytes(bytes);
  final patched = <ArchiveFile>[];
  for (final file in archive.files) {
    if (!file.isFile) continue;
    if (!file.name.startsWith('xl/worksheets/sheet')) continue;
    if (!file.name.endsWith('.xml')) continue;
    final xml = utf8.decode(file.content as List<int>);
    if (xml.contains('rightToLeft')) continue;
    var next = xml;
    if (next.contains('<sheetView ')) {
      next = next.replaceFirst('<sheetView ', '<sheetView rightToLeft="1" ');
    } else if (next.contains('<sheetView/>')) {
      next = next.replaceFirst('<sheetView/>', '<sheetView rightToLeft="1"/>');
    }
    if (next == xml) continue;
    final data = utf8.encode(next);
    patched.add(ArchiveFile(file.name, data.length, data));
  }
  if (patched.isEmpty) return bytes;
  for (final file in patched) {
    archive.addFile(file);
  }
  final encoded = ZipEncoder().encode(archive);
  return encoded == null ? bytes : Uint8List.fromList(encoded);
}

/// Groups forms by their receipt day, newest first. Forms without a date are
/// collected into a single trailing block.
List<_FormDay> _groupFormsByDay(List<InventoryFormItem> forms) {
  final buckets = <String, List<InventoryFormItem>>{};
  for (final form in forms) {
    final day = _dayKey(form.dateOfReceipt);
    buckets.putIfAbsent(day, () => []).add(form);
  }
  final days = [
    for (final entry in buckets.entries) _FormDay(entry.key, entry.value),
  ];
  days.sort((a, b) {
    if (!a.hasDate && !b.hasDate) return 0;
    if (!a.hasDate) return 1;
    if (!b.hasDate) return -1;
    return b.date.compareTo(a.date);
  });
  return days;
}

/// `1405/06/12 00:00:00` → `1405/06/12`; empty when there is no date.
String _dayKey(String value) {
  final text = value.trim();
  if (text.isEmpty) return '';
  final day = text.split(' ').first.replaceAll('-', '/');
  return day == 'null' ? '' : day;
}

/// Summary sheet: header band, KPI strip, then one row per day.
void _writeSummarySheet(
  Sheet sheet,
  List<_FormDay> days,
  int formCount,
  _InventoryStyles styles,
) {
  // Date, weekday, destination, then the numeric counts, then the code range.
  const widths = <double>[16, 12, 30, 11, 10, 13, 10, 11, 13, 38];
  // Columns written as real numbers (the rest stay text).
  const numericColumns = {3, 4, 5, 6, 7, 8};
  sheet.isRTL = true;
  for (var c = 0; c < widths.length; c++) {
    sheet.setColumnWidth(c, widths[c]);
  }
  final lastColumn = widths.length - 1;

  final title = sheet.cell(
    CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
  );
  title.value = TextCellValue('گزارش فرم‌های انبار');
  title.cellStyle = styles.title;
  sheet.merge(
    CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
    CellIndex.indexByColumnRow(columnIndex: lastColumn, rowIndex: 0),
  );
  sheet.setRowHeight(0, 36);

  final subtitle = sheet.cell(
    CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
  );
  subtitle.value = TextCellValue(
    'تاریخ تولید: ${_nowJalali()}   •   $formCount فرم در ${days.length} روز   •   سامانه شوکا',
  );
  subtitle.cellStyle = styles.subtitle;
  sheet.merge(
    CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
    CellIndex.indexByColumnRow(columnIndex: lastColumn, rowIndex: 1),
  );
  sheet.setRowHeight(1, 24);
  sheet.setRowHeight(2, 10);

  final packTotal = days.fold(0, (sum, d) => sum + d.packCount);
  final partsTotal = days.fold(0, (sum, d) => sum + d.partsCount);
  final returnedTotal = days.fold(0, (sum, d) => sum + d.returnedCount);
  final deviceTotal = days.fold(0, (sum, d) => sum + d.deviceCount);
  final installTotal = days.fold(0, (sum, d) => sum + d.installCount);
  final returnTotal = days.fold(0, (sum, d) => sum + d.returnCount);
  final destinationTotal = <String>{
    for (final day in days) ...day.destinations,
  }.length;
  final averagePerDay = days.isEmpty ? 0.0 : formCount / days.length;

  final kpis = <(String, String)>[
    ('کل فرم‌ها', '$formCount'),
    ('ارسال پک', '$packTotal'),
    ('ارسال قطعات', '$partsTotal'),
    ('برگشتی', '$returnedTotal'),
    ('دستگاه‌ها', '$deviceTotal'),
    ('اقلام نصب', '$installTotal'),
    ('اقلام برگشتی', '$returnTotal'),
    ('روزها', '${days.length}'),
    ('مقاصد', '$destinationTotal'),
    ('میانگین روزانه', averagePerDay.toStringAsFixed(1)),
  ];
  for (var i = 0; i < kpis.length; i++) {
    final label = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 3),
    );
    label.value = TextCellValue(kpis[i].$1);
    label.cellStyle = styles.kpiLabel;

    final value = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 4),
    );
    value.value = _numberValue(kpis[i].$2, numeric: true);
    value.cellStyle = styles.kpiValue;
  }
  sheet.setRowHeight(3, 20);
  sheet.setRowHeight(4, 28);

  const headers = [
    'تاریخ',
    'روز هفته',
    'مقصد',
    'فرم‌ها',
    'ارسال پک',
    'ارسال قطعات',
    'برگشتی',
    'دستگاه‌ها',
    'اقلام نصب',
    'محدوده کد داخلی',
  ];
  const headerRow = 6;
  for (var c = 0; c < headers.length; c++) {
    final cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: c, rowIndex: headerRow),
    );
    cell.value = TextCellValue(headers[c]);
    cell.cellStyle = styles.header;
  }
  sheet.setRowHeight(headerRow, 30);

  var row = headerRow + 1;
  for (var i = 0; i < days.length; i++) {
    final day = days[i];
    final values = [
      day.label,
      day.weekDay,
      day.destinationList,
      '${day.forms.length}',
      '${day.packCount}',
      '${day.partsCount}',
      '${day.returnedCount}',
      '${day.deviceCount}',
      '${day.installCount}',
      day.codeRange,
    ];
    for (var c = 0; c < values.length; c++) {
      final numeric = numericColumns.contains(c);
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: c, rowIndex: row),
      );
      cell.value = _numberValue(values[c], numeric: numeric);
      cell.cellStyle = styles.data(center: numeric, alt: i.isOdd);
    }
    // The destination list can wrap, so the row height follows the longest
    // wrapped text instead of a fixed value.
    var lines = 1;
    for (var c = 0; c < values.length; c++) {
      if (values[c].isEmpty) continue;
      final estimated = (values[c].runes.length / (widths[c] * 1.15)).ceil();
      if (estimated > lines) lines = estimated;
    }
    sheet.setRowHeight(row, 16.0 * (lines > 4 ? 4 : lines) + 10);
    row++;
  }

  for (var c = 0; c <= lastColumn; c++) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: row))
        .cellStyle = c == 0 ? styles.totalLabel : styles.totalValue;
  }
  void putTotal(int column, CellValue value) {
    sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row))
            .value =
        value;
  }

  putTotal(0, TextCellValue('جمع کل'));
  putTotal(3, IntCellValue(formCount));
  putTotal(4, IntCellValue(packTotal));
  putTotal(5, IntCellValue(partsTotal));
  putTotal(6, IntCellValue(returnedTotal));
  putTotal(7, IntCellValue(deviceTotal));
  putTotal(8, IntCellValue(installTotal));
  sheet.setRowHeight(row, 28);

  final footer = sheet.cell(
    CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row + 2),
  );
  footer.value = TextCellValue(
    'فرم‌ها به تفکیک روز دریافت دسته‌بندی شده‌اند؛ جزئیات هر فرم در برگه «فرم‌ها» آمده است.',
  );
  footer.cellStyle = styles.footer;
  sheet.merge(
    CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row + 2),
    CellIndex.indexByColumnRow(columnIndex: lastColumn, rowIndex: row + 2),
  );
}

/// Detail sheet: one header row, then a day banner + that day's forms.
void _writeFormsSheet(
  Sheet sheet,
  List<_FormDay> days,
  _InventoryStyles styles,
) {
  sheet.isRTL = true;
  for (var c = 0; c < _formColumns.length; c++) {
    sheet.setColumnWidth(c, _formColumns[c].width);
  }

  for (var c = 0; c < _formColumns.length; c++) {
    final cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0),
    );
    cell.value = TextCellValue(_formColumns[c].title);
    cell.cellStyle = styles.header;
  }
  sheet.setRowHeight(0, 34);

  var row = 1;
  var counter = 0;
  for (final day in days) {
    // Day banner, merged across the full width so each day reads as its own
    // block and carries that day's totals inline.
    final banner = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
    );
    banner.value = TextCellValue(_dayBanner(day));
    banner.cellStyle = day.hasDate ? styles.banner : styles.bannerUndated;
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      CellIndex.indexByColumnRow(
        columnIndex: _formColumns.length - 1,
        rowIndex: row,
      ),
    );
    sheet.setRowHeight(row, 26);
    row++;

    for (final form in day.forms) {
      counter++;
      final values = _formRowValues(form, counter);
      for (var c = 0; c < values.length; c++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: c, rowIndex: row),
        );
        final isAmount = c == _amountColumn;
        cell.value = isAmount
            ? _amountValue(form.amount)
            : _numberValue(
                values[c],
                numeric: _numericFormColumns.contains(c),
              );
        cell.cellStyle = styles.data(
          center: _formColumns[c].center,
          alt: counter.isEven,
          amount: isAmount,
        );
      }
      sheet.setRowHeight(row, _rowHeightFor(values));
      row++;
    }
  }

  final deviceTotal = days.fold(0, (sum, d) => sum + d.deviceCount);
  final installTotal = days.fold(0, (sum, d) => sum + d.installCount);
  final returnTotal = days.fold(0, (sum, d) => sum + d.returnCount);
  final amountTotal = days.fold<num>(0, (sum, d) => sum + d.amount);

  for (var c = 0; c < _formColumns.length; c++) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: row))
        .cellStyle = switch (c) {
      0 => styles.totalLabel,
      _amountColumn => styles.totalAmount,
      _ => styles.totalValue,
    };
  }
  sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value =
      TextCellValue('جمع کل (${days.length} روز)');
  sheet.merge(
    CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
    CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: row),
  );
  void putTotal(int column, CellValue value) {
    sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row))
            .value =
        value;
  }

  putTotal(10, IntCellValue(deviceTotal));
  putTotal(14, IntCellValue(installTotal));
  putTotal(15, IntCellValue(returnTotal));
  if (amountTotal > 0) {
    putTotal(_amountColumn, _amountValue(amountTotal.toString()));
  }
  sheet.setRowHeight(row, 28);
}

/// One line describing a day, used for the merged banner in «فرم‌ها».
String _dayBanner(_FormDay day) {
  final parts = <String>[
    if (day.weekDay.isNotEmpty) day.weekDay,
    day.label,
    '${day.forms.length} فرم',
    '${day.deviceCount} دستگاه',
    if (day.installCount > 0) '${day.installCount} قلم نصب',
    if (day.returnCount > 0) '${day.returnCount} برگشتی',
    if (day.codeRange.isNotEmpty) 'کد داخلی: ${day.codeRange}',
  ];
  return parts.join('   •   ');
}

/// Every column of the «فرم‌ها» sheet, in display order.
List<String> _formRowValues(InventoryFormItem form, int index) {
  final isReturned = form.kind == InventoryFormType.returned;
  final codes = [
    for (final device in form.devices)
      if (device.code.trim().isNotEmpty) device.code.trim(),
  ];
  final items = [
    for (final item in form.installItems) '${item.itemType} × ${item.quantity}',
  ];
  return [
    '$index',
    '#${form.id}',
    form.kind.label,
    isReturned ? form.source : form.destination,
    form.exportUnit,
    form.postingType,
    _dayKey(form.dateOfReceipt),
    form.sentTo,
    form.createdBy,
    form.createdAt,
    '${form.devices.length}',
    form.deviceCodeRange,
    codes.join('، '),
    items.join('، '),
    '${form.installItems.length}',
    '${form.returnData.length}',
    '${form.allSettlements.length}',
    _formatAmount(form.amount),
    form.sourceBank,
    form.destinationBank,
    (form.receiptImage ?? '').trim().isEmpty ? '' : 'دارد',
    form.note,
  ];
}

/// Plain numbers are written as numbers so Excel can sum and sort them
/// instead of flagging them as "number stored as text"; everything else stays
/// text.
CellValue _numberValue(String text, {bool numeric = false}) {
  if (numeric) {
    final trimmed = text.trim();
    final intValue = int.tryParse(trimmed);
    if (intValue != null) return IntCellValue(intValue);
    final doubleValue = double.tryParse(trimmed);
    if (doubleValue != null) return DoubleCellValue(doubleValue);
  }
  return TextCellValue(text);
}

/// Amounts become real numbers (the cell carries a thousands format) so they
/// can be totalled in Excel; non-numeric values such as «توافقی» stay text.
CellValue _amountValue(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return TextCellValue('');
  final value = num.tryParse(text.replaceAll(',', ''));
  if (value == null) return TextCellValue(text);
  return DoubleCellValue(value.toDouble());
}

/// Estimates a row height from the longest wrapped value, capped at four
/// lines so a single long note cannot stretch the row off the screen.
double _rowHeightFor(List<String> values) {
  var lines = 1;
  for (var c = 0; c < values.length && c < _formColumns.length; c++) {
    final text = values[c];
    if (text.isEmpty) continue;
    final estimated = (text.runes.length / (_formColumns[c].width * 1.15))
        .ceil();
    if (estimated > lines) lines = estimated;
  }
  if (lines > 4) lines = 4;
  return 16.0 * lines + 6;
}

/// Groups thousands (`1200000` → `1,200,000`) and keeps decimals when the
/// amount actually carries them; unparsable values pass through untouched.
String _formatAmount(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return '';
  final value = num.tryParse(text.replaceAll(',', ''));
  if (value == null) return text;
  final whole = value == value.roundToDouble();
  final fixed = whole ? value.round().toString() : value.toStringAsFixed(2);
  final negative = fixed.startsWith('-');
  final digits = negative ? fixed.substring(1) : fixed;
  final dot = digits.indexOf('.');
  final integerPart = dot == -1 ? digits : digits.substring(0, dot);
  final decimalPart = dot == -1 ? '' : digits.substring(dot);
  final buffer = StringBuffer();
  for (var i = 0; i < integerPart.length; i++) {
    if (i > 0 && (integerPart.length - i) % 3 == 0) buffer.write(',');
    buffer.write(integerPart[i]);
  }
  return '${negative ? '-' : ''}$buffer$decimalPart';
}

/// Jalali timestamp used in the summary header.
String _nowJalali() {
  final now = Jalali.now();
  final date =
      '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';
  final time =
      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  return '$date - $time';
}

/// The destination a form was sent to. Returned forms may carry their origin
/// in `source` instead, so that is used as a fallback.
String _formDestination(InventoryFormItem form) {
  final destination = form.destination.trim();
  if (destination.isNotEmpty) return destination;
  return form.source.trim();
}

/// One day of inventory forms, used to split the export by day.
class _FormDay {
  final String date;
  final List<InventoryFormItem> forms;

  const _FormDay(this.date, this.forms);

  bool get hasDate => date.isNotEmpty;

  String get label => hasDate ? date : 'بدون تاریخ';

  String get weekDay => _weekDayName(date);

  /// Distinct destinations of that day's forms, in first-seen order.
  List<String> get destinations {
    final seen = <String>{};
    for (final form in forms) {
      final destination = _formDestination(form);
      if (destination.isEmpty) continue;
      seen.add(destination);
    }
    return seen.toList();
  }

  String get destinationList => destinations.join('، ');

  int get packCount =>
      forms.where((form) => form.kind == InventoryFormType.pack).length;

  int get partsCount =>
      forms.where((form) => form.kind == InventoryFormType.parts).length;

  int get returnedCount =>
      forms.where((form) => form.kind == InventoryFormType.returned).length;

  int get deviceCount =>
      forms.fold(0, (sum, form) => sum + form.devices.length);

  int get installCount =>
      forms.fold(0, (sum, form) => sum + form.installItems.length);

  int get returnCount =>
      forms.fold(0, (sum, form) => sum + form.returnData.length);

  num get amount => forms.fold<num>(
    0,
    (sum, form) =>
        sum + (num.tryParse(form.amount.trim().replaceAll(',', '')) ?? 0),
  );

  /// Internal device codes of the whole day merged into a single range.
  String get codeRange => formatDeviceCodeRange(
    forms.expand((form) => form.devices.map((device) => device.code)),
  );
}

/// Persian week-day names, indexed by [Jalali.weekDay] - 1.
const _persianWeekDays = [
  'شنبه',
  'یکشنبه',
  'دوشنبه',
  'سه‌شنبه',
  'چهارشنبه',
  'پنجشنبه',
  'جمعه',
];

/// Week-day name of a Jalali `yyyy/MM/dd` string, or '' when unparsable.
String _weekDayName(String date) {
  final parts = date.split('/');
  if (parts.length != 3) return '';
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) return '';
  try {
    return _persianWeekDays[Jalali(year, month, day).weekDay - 1];
  } catch (_) {
    return '';
  }
}

/// A column of the «فرم‌ها» sheet: title, Excel width and alignment.
class _FormColumn {
  final String title;
  final double width;
  final bool center;

  const _FormColumn(this.title, this.width, {this.center = false});
}

/// Every piece of data we hold about a form, in reading order.
const _formColumns = <_FormColumn>[
  _FormColumn('ردیف', 6, center: true),
  _FormColumn('شناسه فرم', 9, center: true),
  _FormColumn('نوع فرم', 12, center: true),
  _FormColumn('مقصد / مبدأ', 16),
  _FormColumn('واحد صادرکننده', 16),
  _FormColumn('نوع ارسال', 14),
  _FormColumn('تاریخ دریافت', 12, center: true),
  _FormColumn('گیرنده', 16),
  _FormColumn('ثبت‌کننده', 14),
  _FormColumn('تاریخ ثبت', 16),
  _FormColumn('تعداد دستگاه', 10, center: true),
  _FormColumn('محدوده کد داخلی', 24),
  _FormColumn('کدهای دستگاه‌ها', 30),
  _FormColumn('اقلام نصب', 26),
  _FormColumn('تعداد اقلام', 9, center: true),
  _FormColumn('برگشتی', 8, center: true),
  _FormColumn('تسویه', 8, center: true),
  _FormColumn('مبلغ', 13),
  _FormColumn('بانک مبدأ', 13),
  _FormColumn('بانک مقصد', 13),
  _FormColumn('رسید', 7, center: true),
  _FormColumn('توضیحات', 32),
];

/// Columns written as real numbers, so Excel can sum and sort them instead of
/// flagging them as "number stored as text".
const _numericFormColumns = {0, 10, 14, 15, 16};

/// Index of the amount column, formatted with thousands separators.
const _amountColumn = 17;

/// Shared palette and cell styles for both inventory-export sheets.
class _InventoryStyles {
  static const _navy = 'FF1F3864';
  static const _white = 'FFFFFFFF';
  static const _bannerFill = 'FFE8F0FB';
  static const _undatedFill = 'FFF1F1F1';
  static const _zebraFill = 'FFF7F9FC';
  static const _totalFill = 'FFFFF2CC';
  static const _borderColor = 'FFD6DCE5';

  static final _border = Border(
    borderStyle: BorderStyle.Thin,
    borderColorHex: ExcelColor.fromHexString(_borderColor),
  );

  /// `1,200,000` / `1,200,000.5` — separators without forcing decimals.
  static final _amountFormat = NumFormat.custom(formatCode: '#,##0.##');

  final CellStyle title = CellStyle(
    fontFamily: 'Vazirmatn',
    fontSize: 16,
    bold: true,
    fontColorHex: ExcelColor.fromHexString(_white),
    backgroundColorHex: ExcelColor.fromHexString(_navy),
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
  );

  final CellStyle subtitle = CellStyle(
    fontFamily: 'Vazirmatn',
    fontSize: 11,
    fontColorHex: ExcelColor.fromHexString('FF5A6B85'),
    horizontalAlign: HorizontalAlign.Right,
    verticalAlign: VerticalAlign.Center,
  );

  final CellStyle header = CellStyle(
    fontFamily: 'Vazirmatn',
    fontSize: 10,
    bold: true,
    fontColorHex: ExcelColor.fromHexString(_white),
    backgroundColorHex: ExcelColor.fromHexString(_navy),
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
    textWrapping: TextWrapping.WrapText,
  );

  final CellStyle banner = CellStyle(
    fontFamily: 'Vazirmatn',
    fontSize: 11,
    bold: true,
    fontColorHex: ExcelColor.fromHexString(_navy),
    backgroundColorHex: ExcelColor.fromHexString(_bannerFill),
    horizontalAlign: HorizontalAlign.Right,
    verticalAlign: VerticalAlign.Center,
  );

  final CellStyle bannerUndated = CellStyle(
    fontFamily: 'Vazirmatn',
    fontSize: 11,
    bold: true,
    fontColorHex: ExcelColor.fromHexString('FF6B6B6B'),
    backgroundColorHex: ExcelColor.fromHexString(_undatedFill),
    horizontalAlign: HorizontalAlign.Right,
    verticalAlign: VerticalAlign.Center,
  );

  final CellStyle kpiLabel = CellStyle(
    fontFamily: 'Vazirmatn',
    fontSize: 10,
    bold: true,
    fontColorHex: ExcelColor.fromHexString('FF44546A'),
    backgroundColorHex: ExcelColor.fromHexString('FFEFF3F9'),
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
    topBorder: _border,
    leftBorder: _border,
    rightBorder: _border,
  );

  final CellStyle kpiValue = CellStyle(
    fontFamily: 'Vazirmatn',
    fontSize: 14,
    bold: true,
    fontColorHex: ExcelColor.fromHexString(_navy),
    backgroundColorHex: ExcelColor.fromHexString('FFFBFCFE'),
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
    bottomBorder: _border,
    leftBorder: _border,
    rightBorder: _border,
  );

  final CellStyle totalLabel = CellStyle(
    fontFamily: 'Vazirmatn',
    fontSize: 11,
    bold: true,
    fontColorHex: ExcelColor.fromHexString(_navy),
    backgroundColorHex: ExcelColor.fromHexString(_totalFill),
    horizontalAlign: HorizontalAlign.Right,
    verticalAlign: VerticalAlign.Center,
  );

  final CellStyle totalValue = CellStyle(
    fontFamily: 'Vazirmatn',
    fontSize: 11,
    bold: true,
    fontColorHex: ExcelColor.fromHexString(_navy),
    backgroundColorHex: ExcelColor.fromHexString(_totalFill),
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
  );

  /// Same as [totalValue] but keeps thousands separators on amounts.
  late final CellStyle totalAmount = totalValue.copyWith(
    numberFormat: _amountFormat,
  );

  final CellStyle footer = CellStyle(
    fontFamily: 'Vazirmatn',
    fontSize: 9,
    italic: true,
    fontColorHex: ExcelColor.fromHexString('FF8A8A8A'),
    horizontalAlign: HorizontalAlign.Right,
    verticalAlign: VerticalAlign.Center,
  );

  /// Data-cell style cache: only four variants exist (centered/right ×
  /// zebra/plain), plus the amount variant, so they are built once and
  /// reused by every cell.
  final Map<String, CellStyle> _dataCache = {};

  CellStyle data({
    required bool center,
    required bool alt,
    bool amount = false,
  }) => _dataCache.putIfAbsent('$center-$alt-$amount', () {
    final style = CellStyle(
      fontFamily: 'Vazirmatn',
      fontSize: 10,
      horizontalAlign: center ? HorizontalAlign.Center : HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
      textWrapping: TextWrapping.WrapText,
      backgroundColorHex: ExcelColor.fromHexString(alt ? _zebraFill : _white),
      bottomBorder: _border,
    );
    return amount ? style.copyWith(numberFormat: _amountFormat) : style;
  });
}
