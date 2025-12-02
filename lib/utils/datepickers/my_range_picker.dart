import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

Future<JalaliRange?> myRangePicker(BuildContext context) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return await showPersianDateRangePicker(
    context: context,
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: isDark
              ? ColorScheme.dark(
                  primary: const Color.fromARGB(255, 228, 103, 7),
                  secondary: const Color.fromARGB(255, 169, 74, 0),
                  onPrimary: Colors.white,
                  onSurface: Colors.white,
                )
              : ColorScheme.light(
                  primary: const Color.fromARGB(255, 228, 103, 7),
                  secondary: const Color.fromARGB(255, 169, 74, 0),
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                  surface: Colors.white,
                ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 228, 103, 7),
            ),
          ),
        ),
        child: child!,
      );
    },
    initialEntryMode: PersianDatePickerEntryMode.calendarOnly,
    initialDateRange: JalaliRange(
      start: Jalali.now(),
      end: Jalali.now().addDays(7),
    ),
    firstDate: Jalali(1400, 1),
    lastDate: Jalali(1450, 9),
    initialDate: Jalali.now(),
  );
}
