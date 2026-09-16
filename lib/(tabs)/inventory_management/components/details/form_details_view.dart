import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/details/detail_widgets.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/details/settlements_section.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/forms/pack_form_modal.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/forms/parts_form_modal.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/shared/adaptive_modal.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/shared/inventory_form_ui.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/models/inventory_form_data_class.dart';
import 'package:shooka_flutter/services/providers/inventory_provider.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';

/// Opens the get-by-id form-details view as a dialog on desktop and as a
/// bottom sheet on mobile.
void showFormDetails(BuildContext context, InventoryFormItem form) {
  showAdaptiveInventoryModal(context, FormDetailsView(formId: form.id));
}

class FormDetailsView extends StatefulWidget {
  final int formId;

  const FormDetailsView({super.key, required this.formId});

  @override
  State<FormDetailsView> createState() => _FormDetailsViewState();
}

class _FormDetailsViewState extends State<FormDetailsView> {
  late Future<InventoryFormItem> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<InventoryFormItem> _fetch() => context
      .read<InventoryProvider>()
      .api
      .fetchInventoryItemById(formID: widget.formId);

  void _refresh() => setState(() => _future = _fetch());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<InventoryFormItem>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return BottomModalTemplate(
            title: 'جزئیات فرم #${widget.formId}',
            children: const [
              SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          final scheme = Theme.of(context).colorScheme;
          return BottomModalTemplate(
            title: 'جزئیات فرم #${widget.formId}',
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.error.withValues(alpha: .07),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 34,
                      color: scheme.error,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'خطا در دریافت جزئیات',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${snapshot.error ?? 'خطای نامشخص'}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ContainerButton(
                borderRadius: 10,
                fillWidth: true,
                color: scheme.primary,
                padding: const EdgeInsets.all(14),
                onPressed: () => setState(() => _future = _fetch()),
                child: Text(
                  'تلاش مجدد',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.apply(color: Colors.white),
                ),
              ),
            ],
          );
        }
        return _FormDetailsContent(form: snapshot.data!, onChanged: _refresh);
      },
    );
  }
}

class _FormDetailsContent extends StatelessWidget {
  final InventoryFormItem form;
  final VoidCallback? onChanged;

  const _FormDetailsContent({required this.form, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isReturned = form.kind == InventoryFormType.returned;
    final (accent, icon) = switch (form.kind) {
      InventoryFormType.returned => (
        scheme.error,
        Icons.assignment_return_outlined,
      ),
      InventoryFormType.pack => (scheme.primary, Icons.inventory_2_outlined),
      InventoryFormType.parts => (scheme.tertiary, Icons.handyman_outlined),
    };
    final subtitle = isReturned
        ? 'مبدأ ${form.source} • ${form.dateOfReceipt}'
        : '${form.destination} • ${form.dateOfReceipt}';
    return BottomModalTemplate(
      title: 'جزئیات فرم #${form.id}',
      children: [
        InventoryFormHeader(
          title: 'فرم ${form.kind.label} #${form.id}',
          description: subtitle,
          icon: icon,
          color: accent,
          showRequiredHint: false,
        ),
        const SizedBox(height: 14),
        InventoryFormSection(
          title: isReturned ? 'اطلاعات برگشت' : 'اطلاعات فرم',
          description: isReturned
              ? 'مبدأ و مشخصات ثبت برگشت'
              : 'مقصد، گیرنده و مشخصات ثبت فرم',
          icon: Icons.fact_check_outlined,
          child: _DetailsInfo(form: form),
        ),
        if (form.devices.isNotEmpty) ...[
          const SizedBox(height: 14),
          InventoryFormSection(
            title: 'دستگاه‌ها (${form.devices.length})',
            description: 'وضعیت هر دستگاه را ببینید',
            icon: Icons.devices_other_outlined,
            child: Column(
              children: [
                for (final device in form.devices) _DeviceCard(device: device),
              ],
            ),
          ),
        ],
        if (form.installItems.isNotEmpty) ...[
          const SizedBox(height: 14),
          InventoryFormSection(
            title: 'اقلام نصب (${form.installItems.length})',
            description: 'اقلام همراه این فرم',
            icon: Icons.handyman_outlined,
            child: Column(
              children: [
                for (final item in form.installItems)
                  DetailRow(
                    title: item.itemType.isEmpty
                        ? 'قلم #${item.formItemId}'
                        : item.itemType,
                    subtitle: item.formItemId > 0
                        ? 'شناسه: ${item.formItemId}'
                        : null,
                    trailing: '${item.quantity} عدد',
                  ),
              ],
            ),
          ),
        ],
        if (!isReturned) ...[
          const SizedBox(height: 14),
          SettlementsSection(form: form, onChanged: onChanged),
        ],
        if (isReturned) ...[
          const SizedBox(height: 14),
          InventoryFormSection(
            title: 'اقلام برگشتی (${form.returnData.length})',
            description: 'دستگاه‌ها و اقلام برگشت‌خورده این فرم',
            icon: Icons.assignment_return_outlined,
            child: form.returnData.isEmpty
                ? const InventoryEmptyItems(
                    message: 'برای این فرم قلم برگشتی ثبت نشده است.',
                  )
                : Column(
                    children: [
                      for (final entry in form.returnData)
                        _ReturnEntryCard(entry: entry),
                    ],
                  ),
          ),
        ],
        const SizedBox(height: 12),
        if (!isReturned)
          Row(
            children: [
              Expanded(
                child: ContainerButton(
                  borderRadius: 10,
                  fillWidth: true,
                  color: scheme.secondary,
                  padding: const EdgeInsets.all(14),
                  onPressed: () => _openEdit(context, form),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'ویرایش',
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.apply(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ContainerButton(
                  borderRadius: 10,
                  fillWidth: true,
                  color: scheme.primary,
                  padding: const EdgeInsets.all(14),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'بستن',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.apply(color: Colors.white),
                  ),
                ),
              ),
            ],
          )
        else
          ContainerButton(
            borderRadius: 10,
            fillWidth: true,
            color: scheme.primary,
            padding: const EdgeInsets.all(14),
            onPressed: () => Navigator.pop(context),
            child: Text(
              'بستن',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.apply(color: Colors.white),
            ),
          ),
      ],
    );
  }
}

Future<void> _openEdit(BuildContext context, InventoryFormItem form) async {
  bool? edited;
  if (form.kind == InventoryFormType.pack) {
    edited = await showAdaptiveInventoryModal<bool>(
      context,
      PackFormModal(form: form),
    );
  } else if (form.kind == InventoryFormType.parts) {
    edited = await showAdaptiveInventoryModal<bool>(
      context,
      PartsFormModal(form: form),
    );
  }
  if (edited == true && context.mounted) {
    Navigator.pop(context);
  }
}

class _DetailsInfo extends StatelessWidget {
  final InventoryFormItem form;

  const _DetailsInfo({required this.form});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = <Widget>[
      if (form.kind == InventoryFormType.returned)
        InfoItem(
          icon: Icons.location_on_outlined,
          label: 'مبدأ',
          value: form.source,
        ),
      if (form.kind != InventoryFormType.returned)
        InfoItem(
          icon: Icons.location_on_outlined,
          label: 'مقصد',
          value: form.destination,
        ),
      InfoItem(
        icon: Icons.business_outlined,
        label: 'واحد صادرکننده',
        value: form.exportUnit,
      ),
      InfoItem(
        icon: Icons.local_shipping_outlined,
        label: 'نوع ارسال',
        value: form.postingType,
      ),
      InfoItem(
        icon: Icons.calendar_today_outlined,
        label: 'تاریخ دریافت',
        value: form.dateOfReceipt,
      ),
      if (form.sentTo.isNotEmpty)
        InfoItem(
          icon: Icons.badge_outlined,
          label: 'گیرنده',
          value: form.sentTo,
        ),
      InfoItem(
        icon: Icons.person_outline,
        label: 'ثبت‌کننده',
        value: form.createdBy,
      ),
      InfoItem(
        icon: Icons.event_outlined,
        label: 'تاریخ ثبت',
        value: form.createdAt,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(spacing: 24, runSpacing: 16, children: items),
        if (form.note.trim().isNotEmpty) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.notes_rounded, size: 16, color: scheme.primary),
              const SizedBox(width: 6),
              Text(
                'توضیحات',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            form.note,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final InventoryDevice device;

  const _DeviceCard({required this.device});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final chips = <Widget>[
      if (device.isReturned)
        StatusChip(label: 'برگشت‌خورده', color: scheme.error),
      if (device.isInstalled)
        StatusChip(label: 'نصب‌شده', color: scheme.secondary),
      if (device.isSent && !device.isReturned)
        StatusChip(label: 'ارسال‌شده', color: scheme.primary),
    ];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outline.withValues(alpha: .3)),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 8),
        shape: const Border(),
        collapsedShape: const Border(),
        title: Row(
          children: [
            Expanded(
              child: Text(
                device.code,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            ...chips,
          ],
        ),
        subtitle: Text(
          '${device.deviceType} • ${device.serialNumber}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        children: [
          if (device.items.isEmpty)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'قلمی برای این دستگاه ثبت نشده است.',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            )
          else
            for (final item in device.items)
              DetailRow(
                title: item.itemType,
                trailing: '${item.quantity} عدد',
              ),
        ],
      ),
    );
  }
}

class _ReturnEntryCard extends StatelessWidget {
  final InventoryReturnEntry entry;

  const _ReturnEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outline.withValues(alpha: .3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: scheme.error.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  entry.isDevice
                      ? Icons.devices_other_outlined
                      : Icons.handyman_outlined,
                  size: 17,
                  color: scheme.error,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (entry.subtitle.trim().isNotEmpty &&
                        entry.subtitle.trim() != '•') ...[
                      const SizedBox(height: 2),
                      Text(
                        entry.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (entry.sourceFormId > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'فرم مبدأ #${entry.sourceFormId}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              if (entry.returnedBy.isNotEmpty)
                MetaText(icon: Icons.person_outline, value: entry.returnedBy),
              if (entry.returnedAt.isNotEmpty)
                MetaText(icon: Icons.event_outlined, value: entry.returnedAt),
              if (!entry.isDevice && entry.quantity > 0)
                MetaText(
                  icon: Icons.numbers_rounded,
                  value: '${entry.quantity} عدد',
                ),
            ],
          ),
          if (entry.note.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              entry.note,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}
