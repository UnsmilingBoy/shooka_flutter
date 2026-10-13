import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/shared/inventory_form_ui.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/services/providers/inventory_provider.dart';
import 'package:shooka_flutter/utils/datepickers/date_range_filter_field.dart';
import 'package:shooka_flutter/utils/dropdowns/searchable_dropdown_with_label.dart';

/// Filter sheet for the inventory forms list.
///
/// Destination is a free-text match; the date window is picked with the
/// shared Jalali range picker ([DateRangeFilterField] → [myRangePicker]),
/// restored from the provider's current `startFilter`/`endFilter`.
class FilterInventoryModal extends StatefulWidget {
  const FilterInventoryModal({super.key});

  @override
  State<FilterInventoryModal> createState() => _FilterInventoryModalState();
}

class _FilterInventoryModalState extends State<FilterInventoryModal> {
  String? _destination;
  JalaliRange? _range;

  @override
  void initState() {
    super.initState();
    final provider = context.read<InventoryProvider>();
    final saved = provider.destinationFilter.trim();
    _destination = saved.isEmpty ? null : saved;
    _range = tryParseCompactRange(provider.startFilter, provider.endFilter);
  }

  bool get _hasDestination => _destination != null;
  bool get _hasRange => _range != null;
  bool get _hasAnyFilter => _hasDestination || _hasRange;

  void _apply() {
    context.read<InventoryProvider>().setFilters(
      destination: _destination ?? '',
      start: _range?.start.formatCompactDate() ?? '',
      end: _range?.end.formatCompactDate() ?? '',
    );
    Navigator.pop(context, true);
  }

  void _clearAll() {
    context.read<InventoryProvider>().setFilters(
      destination: '',
      start: '',
      end: '',
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final generalProvider = context.watch<GeneralProvider>();
    final provinceItems =
        (generalProvider.filters?["locations"] ?? [])
            .map((location) => location["location"][0].toString())
            .toSet()
            .map<DropdownItemModel>(
              (province) => DropdownItemModel(value: province, label: province),
            )
            .toList();

    return BottomModalTemplate(
      title: 'فیلتر فرم‌های انبار',
      children: [
        const InventoryFormHeader(
          title: 'فیلتر کردن فرم‌ها',
          description: 'مقصد و بازه زمانی ثبت فرم را مشخص کنید.',
          icon: Icons.filter_alt_outlined,
        ),
        const SizedBox(height: 16),
        if (_hasAnyFilter) ...[
          _ActiveFilterChips(
            destination: _destination,
            range: _range,
            onRemoveDestination: () => setState(() => _destination = null),
            onRemoveRange: () => setState(() => _range = null),
            onClearAll: _clearAll,
          ),
          const SizedBox(height: 14),
        ],
        InventoryFormSection(
          title: 'مقصد',
          description: 'استان مقصد فرم‌ها',
          icon: Icons.location_on_outlined,
          trailing: _hasDestination
              ? TextButton(
                  onPressed: () => setState(() => _destination = null),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: scheme.error,
                  ),
                  child: const Text('پاک کردن'),
                )
              : null,
          child: SearchableDropdownWithLabel(
            initialValue: _destination,
            iconOnPressed: () => setState(() => _destination = null),
            items: provinceItems,
            onChanged: (value) => setState(() => _destination = value),
            label: 'استان مقصد',
            placeholder: 'انتخاب استان...',
          ),
        ),
        const SizedBox(height: 14),
        InventoryFormSection(
          title: 'بازه زمانی',
          description: 'تاریخ ثبت فرم از ابتدا تا انتها (شمسی)',
          icon: Icons.date_range_outlined,
          trailing: _hasRange
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'فعال',
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              : null,
          child: DateRangeFilterField(
            label: 'بازه ثبت فرم',
            value: _range,
            onChanged: (range) => setState(() => _range = range),
          ),
        ),
        ModalBottomButtons(saveText: 'اعمال فیلتر', onSave: _apply),
      ],
    );
  }
}

/// Summary of the currently-set filters with per-filter remove actions.
class _ActiveFilterChips extends StatelessWidget {
  final String? destination;
  final JalaliRange? range;
  final VoidCallback onRemoveDestination;
  final VoidCallback onRemoveRange;
  final VoidCallback onClearAll;

  const _ActiveFilterChips({
    required this.destination,
    required this.range,
    required this.onRemoveDestination,
    required this.onRemoveRange,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_alt_rounded,
                size: 16,
                color: scheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'فیلترهای فعال',
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.primary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onClearAll,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: scheme.error,
                  textStyle: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: const Text('حذف همه'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (destination != null)
                _RemovableChip(
                  icon: Icons.location_on_outlined,
                  label: destination!,
                  onRemove: onRemoveDestination,
                ),
              if (range != null)
                _RemovableChip(
                  icon: Icons.date_range_outlined,
                  label: formatRangeDisplay(range!),
                  onRemove: onRemoveRange,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RemovableChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onRemove;

  const _RemovableChip({
    required this.icon,
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsetsDirectional.only(start: 10, end: 4),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.primary.withValues(alpha: .35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.primary),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 2),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.close_rounded,
                size: 14,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
