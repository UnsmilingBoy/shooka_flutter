import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:shooka_flutter/utils/datepickers/persian_picker_theme.dart';

/// Shows the Jalali (شمسی) date-range picker with a contrast-safe theme.
///
/// * Light/dark: derives surface colors from the app theme and uses a
///   per-brightness brand primary so selected days / header text always pass
///   contrast (see [buildPersianPickerTheme]).
/// * Desktop (width > [kPickerDesktopBreakpoint]): wider dialog with
///   slightly larger text for mouse/keyboard use; mobile keeps the compact
///   dialog.
/// * All chrome labels are Persian and the dialog is forced RTL.
Future<JalaliRange?> myRangePicker(
  BuildContext context, {
  JalaliRange? initialRange,
  Jalali? initialDate,
}) async {
  return await showPersianDateRangePicker(
    context: context,
    textDirection: TextDirection.rtl,
    helpText: 'بازه زمانی را انتخاب کنید',
    cancelText: 'انصراف',
    confirmText: 'تأیید',
    saveText: 'ذخیره',
    errorInvalidRangeText: 'بازه زمانی نامعتبر است',
    fieldStartLabelText: 'تاریخ شروع',
    fieldEndLabelText: 'تاریخ پایان',
    builder: (context, child) {
      return Theme(
        data: buildPersianPickerTheme(context),
        child: persianPickerBuilder(context, child),
      );
    },
    initialEntryMode: PersianDatePickerEntryMode.calendarOnly,
    initialDateRange:
        initialRange ?? JalaliRange(start: Jalali.now(), end: Jalali.now().addDays(7)),
    firstDate: Jalali(1400, 1),
    lastDate: Jalali(1450, 9),
    initialDate: initialDate ?? initialRange?.start ?? Jalali.now(),
  );
}
