import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/providers/event_provider.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/services/providers/software_support_provider.dart';
import 'package:shooka_flutter/utils/toastifications/toasts.dart';

class ExportEventsModal extends StatefulWidget {
  const ExportEventsModal({super.key, this.isSoftwareSupport = false});

  final bool isSoftwareSupport;

  @override
  State<ExportEventsModal> createState() => _ExportEventsModalState();
}

class _ExportEventsModalState extends State<ExportEventsModal> {
  bool _isDeviceEvents = false;
  bool _isSoftwareEvents = false;
  bool _exportLoading = false;

  bool get _hasSelection => _isDeviceEvents || _isSoftwareEvents;

  Future<void> _export() async {
    if (!_hasSelection) return;
    setState(() => _exportLoading = true);
    try {
      if (widget.isSoftwareSupport) {
        await context.read<SoftwareSupportProvider>().exportEventsToWord(
              isDeviceEvents: _isDeviceEvents,
              isSoftwareEvents: _isSoftwareEvents,
            );
      } else {
        await context.read<EventProvider>().exportEventsToWord(
              isDeviceEvents: _isDeviceEvents,
              isSoftwareEvents: _isSoftwareEvents,
            );
      }
      if (!mounted) return;
      Navigator.pop(context);
      filledSuccessToast(title: 'فایل ورد با موفقیت دانلود شد');
    } catch (e) {
      if (!mounted) return;
      setState(() => _exportLoading = false);
      flatErrorToast(
        title: 'خطا در دانلود فایل ورد',
        description: e.toString(),
      );
    }
  }

  String _resolveOptionName(dynamic list, int? id, String key) {
    if (id == null) return '';
    if (list != null) {
      for (final item in list) {
        if (item["id"].toString() == id.toString()) {
          return item[key].toString();
        }
      }
    }
    return id.toString();
  }

  List<String> _activeFilterLabels({
    required dynamic filters,
    required String? search,
    required int? creatorId,
    required int? deviceId,
    required String? title,
    required String? organization,
    required String? administration,
    required String? province,
    required String? city,
    required String? plan,
    required String? start,
    required String? end,
  }) {
    return [
      if (search != null && search.isNotEmpty) "جستجو: $search",
      if (creatorId != null)
        "ایجاد کننده: ${_resolveOptionName(filters?["installers"], creatorId, "installer")}",
      if (deviceId != null)
        "دستگاه: ${_resolveOptionName(filters?["devices"], deviceId, "name")}",
      if (title != null) "عنوان: $title",
      if (organization != null) "سازمان: $organization",
      if (administration != null) "وزارت‌خانه: $administration",
      if (province != null) "استان: $province",
      if (city != null) "شهر: $city",
      if (plan != null)
        "پلن: ${plan == "optimized" ? "طرح بهینه سازی" : plan == "free" ? "رایگان" : plan}",
      if (start != null || end != null)
        "بازه زمانی: ${start ?? '؟'} تا ${end ?? '؟'}",
    ];
  }

  Widget _buildActiveFiltersSection(List<String> labels) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "فیلترهای اعمال شده:",
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          if (labels.isEmpty)
            Text(
              "فیلتری اعمال نشده است",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final label in labels)
                  Chip(
                    label: Text(
                      label,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    backgroundColor: colorScheme.surface,
                    side: BorderSide(
                      color: colorScheme.outlineVariant.withOpacity(0.4),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required VoidCallback onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: value ? 1 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: value
              ? Theme.of(context).colorScheme.primary.withOpacity(0.6)
              : Theme.of(context).colorScheme.outlineVariant.withOpacity(0.2),
          width: value ? 1.5 : 1,
        ),
      ),
      color: value
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.15)
          : Theme.of(context).colorScheme.surface,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onChanged,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: value,
                onChanged: (_) => onChanged(),
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final generalFilters = context.watch<GeneralProvider>().filters;

    String? search;
    int? creatorId;
    int? deviceId;
    String? title;
    String? organization;
    String? administration;
    String? province;
    String? city;
    String? plan;
    String? startDate;
    String? endDate;

    if (widget.isSoftwareSupport) {
      final provider = context.watch<SoftwareSupportProvider>();
      search = provider.lastSearchedText;
      creatorId = provider.lastSelectedCreator;
      deviceId = provider.lastSelectedDevice;
      title = provider.lastSelectedTitle;
      organization = provider.lastSelectedOrganization;
      administration = provider.lastSelectedAdministration;
      province = provider.lastSelectedProvince;
      city = provider.lastSelectedCity;
      plan = provider.lastSelectedPlan;
      startDate = provider.lastSelectedStart;
      endDate = provider.lastSelectedEnd;
    } else {
      final provider = context.watch<EventProvider>();
      search = provider.lastSearchedText;
      creatorId = provider.lastSelectedCreator;
      deviceId = provider.lastSelectedDevice;
      title = provider.lastSelectedTitle;
      organization = provider.lastSelectedOrganization;
      administration = provider.lastSelectedAdministration;
      province = provider.lastSelectedProvince;
      city = provider.lastSelectedCity;
      plan = provider.lastSelectedPlan;
      startDate = provider.lastSelectedStart;
      endDate = provider.lastSelectedEnd;
    }

    final filterLabels = _activeFilterLabels(
      filters: generalFilters,
      search: search,
      creatorId: creatorId,
      deviceId: deviceId,
      title: title,
      organization: organization,
      administration: administration,
      province: province,
      city: city,
      plan: plan,
      start: startDate,
      end: endDate,
    );

    return BottomModalTemplate(
      title: "خروجی رویدادها",
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(
            "نوع رویدادهای مورد نظر برای خروجی را انتخاب کنید",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        _buildActiveFiltersSection(filterLabels),
        _buildOption(
          icon: Icons.devices_other_rounded,
          title: "رویداد های نصاب ها",
          subtitle: "رویدادهای ثبت شده توسط نصاب ها",
          value: _isDeviceEvents,
          onChanged: () => setState(() => _isDeviceEvents = !_isDeviceEvents),
        ),
        _buildOption(
          icon: Icons.support_agent_rounded,
          title: "پشتیبانی نرم افزاری",
          subtitle: "رویدادهای پشتیبانی نرم افزاری",
          value: _isSoftwareEvents,
          onChanged: () =>
              setState(() => _isSoftwareEvents = !_isSoftwareEvents),
        ),
        ModalBottomButtons(
          saveText: "دانلود فایل ورد",
          isLoading: _exportLoading,
          onSave: (_hasSelection && !_exportLoading) ? _export : null,
        ),
      ],
    );
  }
}
