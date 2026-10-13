import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:shooka_flutter/utils/datepickers/persian_picker_theme.dart';

/// Shows the Jalali (شمسی) single-date picker with a contrast-safe theme.
///
/// Previously this always forced a dark [ColorScheme], which broke contrast
/// in light mode. Now it derives colors from the app theme (see
/// [buildPersianPickerTheme]) and adapts the dialog size for desktop.
Future<Jalali?> myDatePicker(
  BuildContext context, {
  Jalali? initialDate,
  Jalali? firstDate,
  Jalali? lastDate,
}) async {
  return await showPersianDatePicker(
    context: context,
    textDirection: TextDirection.rtl,
    helpText: 'تاریخ را انتخاب کنید',
    cancelText: 'انصراف',
    confirmText: 'تأیید',
    builder: (context, child) {
      return Theme(
        data: buildPersianPickerTheme(context),
        child: persianPickerBuilder(context, child),
      );
    },
    initialDate: initialDate ?? Jalali.now(),
    firstDate: firstDate ?? Jalali(1385, 1, 1),
    lastDate: lastDate ?? Jalali(1450, 9, 29),
    holidayConfig: PersianHolidayConfig(weekendDays: {7}),
    initialEntryMode: PersianDatePickerEntryMode.calendarOnly,
    initialDatePickerMode: PersianDatePickerMode.year,
  );
}
