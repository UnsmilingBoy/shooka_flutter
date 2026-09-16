import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/details/detail_widgets.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/forms/settlement_form_modal.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/shared/adaptive_modal.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/shared/inventory_form_ui.dart';
import 'package:shooka_flutter/models/inventory_form_data_class.dart';
import 'package:shooka_flutter/services/providers/inventory_provider.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';

String? _settlementReceiptUrl(BuildContext context, String? path) {
  if (path == null || path.trim().isEmpty) return null;
  final trimmed = path.trim();
  if (trimmed.startsWith('http')) return trimmed;
  if (trimmed.startsWith('data:image')) return trimmed;
  final base = context.read<InventoryProvider>().api.dio.options.baseUrl;
  if (trimmed.startsWith('/')) return '$base$trimmed';
  return '$base/$trimmed';
}

Future<void> _openSettlement(
  BuildContext context,
  InventoryFormItem form,
  VoidCallback? onChanged,
) async {
  final created = await showAdaptiveInventoryModal<bool>(
    context,
    SettlementFormModal(form: form),
  );
  if (created == true) onChanged?.call();
}

/// Settlement (تسویه حساب) section of the form-details view. Price, banks
/// and receipt images live here — not in the general form-info section.
class SettlementsSection extends StatelessWidget {
  final InventoryFormItem form;
  final VoidCallback? onChanged;

  const SettlementsSection({super.key, required this.form, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final settlements = form.allSettlements;
    final deviceCount = form.deviceSettlements.length;
    final repCount = form.representativeSettlements.length;
    return InventoryFormSection(
      title: 'فرم‌های تسویه حساب (${settlements.length})',
      description: deviceCount > 0 || repCount > 0
          ? '$deviceCount تسویه دستگاه • $repCount تسویه نماینده'
          : 'مبلغ، بانک‌ها و رسید پرداخت این فرم',
      icon: Icons.payments_outlined,
      trailing: ContainerButton(
        borderRadius: 8,
        color: scheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        onPressed: form.devices.isEmpty
            ? null
            : () => _openSettlement(context, form, onChanged),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, size: 17, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'تسویه جدید',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      child: settlements.isEmpty
          ? const InventoryEmptyItems(
              message:
                  'برای این فرم هنوز تسویه‌ای ثبت نشده است. با «تسویه جدید» مبلغ دستگاه یا تسویه نماینده را ثبت کنید.',
            )
          : Column(
              children: [
                for (final settlement in settlements)
                  _SettlementCard(
                    settlement: settlement,
                    deviceCodes: form.deviceCodesForSettlement(settlement.id),
                  ),
              ],
            ),
    );
  }
}

class _SettlementCard extends StatelessWidget {
  final InventorySettlement settlement;
  final List<String> deviceCodes;

  const _SettlementCard({required this.settlement, this.deviceCodes = const []});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isRep = settlement.isRepresentative;
    final accent = isRep ? scheme.secondary : scheme.primary;
    final typeIcon = isRep
        ? Icons.badge_outlined
        : Icons.business_outlined;
    final receiptUrl = _settlementReceiptUrl(
      context,
      settlement.receiptImage,
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: .35)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(typeIcon, size: 19, color: accent),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settlement.typeLabel,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                      if (settlement.createdAt.isNotEmpty)
                        Text(
                          settlement.createdAt,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    settlement.amount.isEmpty
                        ? '—'
                        : '${settlement.amount} تومان',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    if (settlement.sourceBank.isNotEmpty)
                      MetaText(
                        icon: Icons.account_balance_outlined,
                        value: 'مبدأ: ${settlement.sourceBank}',
                      ),
                    if (settlement.destinationBank.isNotEmpty)
                      MetaText(
                        icon: Icons.account_balance_outlined,
                        value: 'مقصد: ${settlement.destinationBank}',
                      ),
                    if (settlement.sentTo.isNotEmpty)
                      MetaText(
                        icon: Icons.badge_outlined,
                        value: 'گیرنده: ${settlement.sentTo}',
                      ),
                    if (settlement.createdBy.isNotEmpty)
                      MetaText(
                        icon: Icons.person_outline,
                        value: settlement.createdBy,
                      ),
                  ],
                ),
                if (deviceCodes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.devices_other_outlined,
                        size: 15,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final code in deviceCodes)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: accent.withValues(alpha: .12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: accent.withValues(alpha: .35),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.qr_code_rounded,
                                      size: 13,
                                      color: accent,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      code,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: accent,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                if (settlement.note.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.notes_rounded,
                        size: 15,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          settlement.note,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ],
                if (receiptUrl != null) ...[
                  const SizedBox(height: 10),
                  _ReceiptThumbnail(url: receiptUrl),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptThumbnail extends StatelessWidget {
  final String url;

  const _ReceiptThumbnail({required this.url});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isBase64 = url.startsWith('data:image');
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => showDialog(
          context: context,
          builder: (_) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(12),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: InteractiveViewer(
                minScale: .5,
                maxScale: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: isBase64
                      ? Image.memory(
                          UriData.parse(url).contentAsBytes(),
                          fit: BoxFit.contain,
                        )
                      : CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.contain,
                          placeholder: (_, __) => const SizedBox(
                            height: 200,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (_, __, ___) => const SizedBox(
                            height: 200,
                            child: Center(
                              child: Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: scheme.outline.withValues(alpha: .35)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: isBase64
                      ? Image.memory(
                          UriData.parse(url).contentAsBytes(),
                          fit: BoxFit.cover,
                        )
                      : CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: scheme.surfaceContainerHighest,
                            child: const Center(
                              child: SizedBox.square(
                                dimension: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: scheme.surfaceContainerHighest,
                            child: const Icon(
                              Icons.receipt_long_outlined,
                              size: 22,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تصویر رسید',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'برای مشاهده در اندازه بزرگ لمس کنید',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.zoom_in_rounded, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
