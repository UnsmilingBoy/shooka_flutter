import 'package:flutter/material.dart';

/// Breakpoint matching [BottomModalTemplate]: above this width the app shows
/// a centered dialog instead of a bottom sheet.
const double kPickerDesktopBreakpoint = 900;

/// Builds a contrast-safe [ThemeData] wrapper for the persian (Jalali)
/// pickers, derived from the ambient app theme.
///
/// Instead of hardcoding a dark [ColorScheme] (which breaks light mode) or a
/// hardcoded orange accent (which clashes with the app palette), this reuses
/// the app's own [ColorScheme] — blue primary, tuned surfaces — so the
/// picker header, selected days, and action buttons automatically match the
/// rest of the app in both light and dark mode.
ThemeData buildPersianPickerTheme(BuildContext context) {
  final base = Theme.of(context);
  final scheme = base.colorScheme;

  return base.copyWith(
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: scheme.primary),
    ),
    datePickerTheme: base.datePickerTheme.copyWith(
      backgroundColor: scheme.surface,
      headerBackgroundColor: scheme.primary,
      headerForegroundColor: scheme.onPrimary,
      confirmButtonStyle: TextButton.styleFrom(foregroundColor: scheme.primary),
      cancelButtonStyle: TextButton.styleFrom(foregroundColor: scheme.primary),
    ),
  );
}

/// Builder wrapper for `showPersianDatePicker` /
/// `showPersianDateRangePicker`.
///
/// * Mobile: returns the dialog as-is (centered, compact).
/// * Desktop (width > [kPickerDesktopBreakpoint]): constrains the dialog to
///   a wider, shorter card and bumps the text scale slightly so the calendar
///   is easier to scan and click with a mouse/keyboard. Also forces RTL
///   directionality for the Jalali calendar.
Widget persianPickerBuilder(BuildContext context, Widget? child) {
  final media = MediaQuery.of(context);
  final isDesktop = media.size.width > kPickerDesktopBreakpoint;

  Widget dialog = Directionality(
    textDirection: TextDirection.rtl,
    child: child ?? const SizedBox.shrink(),
  );

  if (!isDesktop) return dialog;

  return Directionality(
    textDirection: TextDirection.rtl,
    child: Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: media.size.height * 0.9,
        ),
        child: MediaQuery(
          data: media.copyWith(textScaler: const TextScaler.linear(1.1)),
          child: dialog,
        ),
      ),
    ),
  );
}
