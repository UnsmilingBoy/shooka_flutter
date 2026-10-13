import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:shooka_flutter/utils/datepickers/my_range_picker.dart';
import 'package:shooka_flutter/utils/datepickers/persian_picker_theme.dart';

/// Parses a compact Jalali date (`yyyy/MM/dd`, as produced by
/// [Jalali.formatCompactDate]) back into a [Jalali]. Returns null when the
/// saved value is missing or malformed.
Jalali? tryParseCompactDate(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  try {
    final parts = value.split('/');
    return Jalali(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  } catch (_) {
    return null;
  }
}

/// Parses a saved start/end pair into a [JalaliRange]. Returns null unless
/// both ends parse and start is not after end.
JalaliRange? tryParseCompactRange(String? start, String? end) {
  final startDate = tryParseCompactDate(start);
  final endDate = tryParseCompactDate(end);
  if (startDate == null || endDate == null) return null;
  if (endDate.isBefore(startDate)) return null;
  return JalaliRange(start: startDate, end: endDate);
}

/// Display string for a picked range, e.g. `۱۲ فروردین ۱۴۰۳ تا ۱۹ فروردین ۱۴۰۳`.
String formatRangeDisplay(JalaliRange range) {
  return '${range.start.formatFullDate()} تا ${range.end.formatFullDate()}';
}

/// Single shared Jalali (شمسی) date-range filter field used by every filter
/// modal — device list, event list, accounting — so the UI stays consistent
/// with zero copy-paste.
///
/// The parent owns the state: pass the current [value] and apply [onChanged].
/// Colors come from the ambient [ColorScheme] (never hardcoded white), so the
/// selected-range text stays readable in both light and dark mode.
///
/// The [isDesktop] layout (width > [kPickerDesktopBreakpoint]) uses a
/// full-width summary card plus 52px Material buttons with tooltips and
/// keyboard-focus support; mobile keeps a compact 44px row.
class DateRangeFilterField extends StatelessWidget {
  final String label;
  final JalaliRange? value;
  final ValueChanged<JalaliRange?> onChanged;
  final String pickLabel;

  const DateRangeFilterField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.pickLabel = 'انتخاب بازه',
  });

  Future<void> _pick(BuildContext context) async {
    final picked = await myRangePicker(context, initialRange: value);
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDesktop =
        MediaQuery.sizeOf(context).width > kPickerDesktopBreakpoint;
    final range = value;

    final double controlHeight = isDesktop ? 52 : 44;
    final EdgeInsets cardPadding = isDesktop
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 14)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 10);
    // OutlineVariant renders near-white in dark mode; tone it down so the
    // buttons don't glow against the dark surface.
    final Color buttonBorderColor =
        scheme.brightness == Brightness.dark
            ? scheme.outlineVariant.withValues(alpha: 0.4)
            : scheme.outlineVariant;

    return Semantics(
      container: true,
      label: label,
      value: range == null ? 'انتخاب نشده' : formatRangeDisplay(range),
      child: Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(label, style: textTheme.titleSmall),
            Row(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    padding: cardPadding,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: buttonBorderColor),
                    ),
                    child: Text(
                      range == null ? 'بازه‌ای انتخاب نشده' : formatRangeDisplay(range),
                      style: (range == null
                              ? textTheme.labelSmall
                              : textTheme.labelMedium)
                          ?.copyWith(
                            color: range == null
                                ? scheme.onSurfaceVariant
                                : scheme.onSurface,
                          ),
                      maxLines: isDesktop ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (range != null)
                  SizedBox(
                    width: controlHeight,
                    height: controlHeight,
                    child: IconButton(
                      tooltip: 'پاک کردن بازه',
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: buttonBorderColor),
                        ),
                      ),
                      onPressed: () => onChanged(null),
                      icon: Icon(
                        Icons.clear,
                        size: 18,
                        color: scheme.error,
                        semanticLabel: 'پاک کردن بازه زمانی',
                      ),
                    ),
                  ),
                SizedBox(
                  height: controlHeight,
                  child: OutlinedButton.icon(
                    onPressed: () => _pick(context),
                    icon: Icon(
                      Icons.date_range_rounded,
                      size: 18,
                      color: scheme.primary,
                    ),
                    label: Text(
                      range == null ? pickLabel : 'تغییر بازه',
                      style: textTheme.labelMedium?.copyWith(
                        color: scheme.primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 20 : 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(color: buttonBorderColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
