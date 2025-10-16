import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

Future<Jalali?> myDatePicker(BuildContext context) async {
  return await showPersianDatePicker(
    context: context,
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: const Color.fromARGB(255, 228, 103, 7),
            secondary: const Color.fromARGB(255, 169, 74, 0),
          ),
        ),
        child: child!,
      );
    },
    initialDate: Jalali.now(),
    firstDate: Jalali(1385, 8),
    lastDate: Jalali(1450, 9),
    holidayConfig: PersianHolidayConfig(weekendDays: {7}),
    initialEntryMode: PersianDatePickerEntryMode.calendarOnly,
    initialDatePickerMode: PersianDatePickerMode.year,
  );
}
