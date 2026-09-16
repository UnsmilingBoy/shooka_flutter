import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/data/iran_provinces.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/shared/inventory_form_ui.dart';
import 'package:shooka_flutter/services/providers/software_support_provider.dart';
import 'package:shooka_flutter/utils/dropdowns/searchable_dropdown_with_label.dart';

/// Shared helpers for the inventory form modals (pack / parts / returned /
/// settlement). Extracted to remove the copy-pasted province matching, date
/// formatting, field pairs, dropdowns, repeating cards and receipt pickers.

String matchIranProvince(String destination) {
  final raw = destination.trim();
  if (raw.isEmpty) return '';
  if (iranProvinces.contains(raw)) return raw;
  for (final province in iranProvinces) {
    if (raw.contains(province) || province.contains(raw)) return province;
  }
  return '';
}

String jalaliDateText(Jalali date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

/// Two required text fields side by side (stacked on narrow screens).
Widget pairFormFields(
  String firstLabel,
  TextEditingController firstController,
  IconData firstIcon,
  String secondLabel,
  TextEditingController secondController,
  IconData secondIcon, {
  String secondHint = '',
  bool secondNumber = false,
}) => InventoryFormPair(
  first: InventoryFormField(
    label: firstLabel,
    controller: firstController,
    icon: firstIcon,
    required: true,
  ),
  second: InventoryFormField(
    label: secondLabel,
    controller: secondController,
    icon: secondIcon,
    hint: secondHint,
    keyboardType: secondNumber ? TextInputType.number : null,
    required: true,
  ),
);

class ProvinceDropdownField extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const ProvinceDropdownField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SearchableDropdownWithLabel(
      initialValue: value,
      iconOnPressed: () => onChanged(null),
      items: iranProvinces
          .map<DropdownItemModel>(
            (province) => DropdownItemModel(value: province, label: province),
          )
          .toList(),
      onChanged: onChanged,
      label: 'مقصد (استان)*',
      placeholder: 'انتخاب استان...',
    );
  }
}

class RecipientDropdownField extends StatelessWidget {
  final int? userId;
  final ValueChanged<int?> onChanged;

  const RecipientDropdownField({
    super.key,
    required this.userId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final supportProvider = context.watch<SoftwareSupportProvider>();
    return SearchableDropdownWithLabel(
      initialValue: userId?.toString(),
      iconOnPressed: () => onChanged(null),
      items: supportProvider.users
          .map<DropdownItemModel>(
            (user) => DropdownItemModel(
              value: user.id.toString(),
              label: user.fullName,
            ),
          )
          .toList(),
      loadItems: (filter) async {
        final users = await context
            .read<SoftwareSupportProvider>()
            .fetchUsers(search: filter);
        return users
            .map<DropdownItemModel>(
              (user) => DropdownItemModel(
                value: user.id.toString(),
                label: user.fullName,
              ),
            )
            .toList();
      },
      onChanged: (value) =>
          onChanged(value == null ? null : int.tryParse(value)),
      label: 'نماینده (گیرنده)*',
      placeholder: 'انتخاب نماینده...',
    );
  }
}

/// Card wrapper for repeating rows (devices, install items, ...).
class FormRepeatingCard extends StatelessWidget {
  final String badge;
  final Widget child;
  final VoidCallback? onDelete;

  const FormRepeatingCard({
    super.key,
    required this.badge,
    required this.child,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outline.withValues(alpha: .35)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              if (onDelete != null)
                IconButton(
                  tooltip: 'حذف',
                  visualDensity: VisualDensity.compact,
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
                ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// Picks an image file and returns it as a base64 string, or null when the
/// user cancels.
Future<String?> pickReceiptImageAsBase64() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    withData: true,
  );
  final bytes = result?.files.single.bytes;
  if (bytes == null) return null;
  return base64Encode(bytes);
}

class ReceiptPickerButton extends StatelessWidget {
  final bool picked;
  final VoidCallback onPick;
  final VoidCallback? onRemove;

  const ReceiptPickerButton({
    super.key,
    required this.picked,
    required this.onPick,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: picked
          ? scheme.primary.withValues(alpha: .08)
          : scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: picked
                  ? scheme.primary.withValues(alpha: .5)
                  : scheme.outline.withValues(alpha: .4),
            ),
          ),
          child: Row(
            children: [
              Icon(
                picked
                    ? Icons.check_circle_outline_rounded
                    : Icons.upload_file_outlined,
                size: 20,
                color: picked ? scheme.primary : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  picked
                      ? 'تصویر رسید انتخاب شد'
                      : 'افزودن تصویر رسید (اختیاری)',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: picked ? scheme.primary : scheme.onSurfaceVariant,
                    fontWeight: picked ? FontWeight.w700 : null,
                  ),
                ),
              ),
              if (picked && onRemove != null)
                TextButton(onPressed: onRemove, child: const Text('حذف')),
              Text(
                picked ? 'تغییر' : 'انتخاب',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: scheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
