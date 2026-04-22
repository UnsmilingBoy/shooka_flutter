import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shooka_flutter/(tabs)/accounting/components/set_factor_id_modal.dart';
import 'package:shooka_flutter/models/event_data_class.dart';
import 'package:shooka_flutter/models/factor_data_class.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';

/// Detail panel for the accounting split view.
/// Shows factor info, groups, and their events.
class AccountingDetailPanel extends StatelessWidget {
  final Factor factor;
  final VoidCallback? onClose;

  const AccountingDetailPanel({super.key, required this.factor, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          //
          // Panel Header
          //
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'جزئیات فاکتور',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onClose != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                    tooltip: 'بستن',
                    iconSize: 20,
                  ),
              ],
            ),
          ),

          //
          // Panel Content
          //
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  //
                  // Factor Info Card
                  //
                  _FactorInfoCard(factor: factor),

                  //
                  // Edit Factor Button
                  //
                  ContainerButton(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: 10,
                    fillWidth: true,
                    onPressed: () {
                      final modal = SetFactorIdModal(
                        factorId: factor.factorId,
                        currentFactorNumber: factor.factorNumber,
                        currentNote: factor.note,
                        isPrinted: factor.isPrinted,
                      );
                      final isDesktop = MediaQuery.of(context).size.width > 900;
                      if (isDesktop) {
                        showDialog(
                          context: context,
                          builder: (context) => modal,
                        );
                      } else {
                        showMaterialModalBottomSheet(
                          enableDrag: false,
                          context: context,
                          builder: (context) => modal,
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 8,
                      children: [
                        Icon(
                          Icons.edit_note_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        Text(
                          'ویرایش فاکتور',
                          style: Theme.of(
                            context,
                          ).textTheme.labelLarge?.apply(color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  //
                  // Groups Section
                  //
                  Text(
                    'رویدادهای فاکتور (${factor.groups.length})',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ...factor.groups.map(
                    (group) => _FactorGroupCard(group: group),
                  ),

                  //
                  // Total Price
                  //
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'جمع کل فاکتور:',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_formatPrice(factor.totalPrice)} ریال',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//
// Factor Info Card
//
class _FactorInfoCard extends StatelessWidget {
  final Factor factor;
  const _FactorInfoCard({required this.factor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          // Factor number
          Row(
            spacing: 6,
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              Expanded(
                child: Text(
                  'شماره فاکتور:  ${factor.factorNumber}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
          // Created info
          _InfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'تاریخ ایجاد:  ${factor.createdAt}',
            context: context,
          ),
          _InfoRow(
            icon: Icons.person_outline,
            label: 'ایجاد کننده:  ${factor.createdBy}',
            context: context,
          ),
          // Print status
          _InfoRow(
            icon: factor.isPrinted
                ? Icons.print_rounded
                : Icons.print_disabled_rounded,
            label: factor.isPrinted
                ? 'چاپ شده${factor.printedAt != null ? ':  ${factor.printedAt}' : ''}'
                : 'چاپ نشده',
            context: context,
            color: factor.isPrinted
                ? Colors.green
                : Theme.of(context).hintColor,
          ),
          // Note
          if (factor.note != null && factor.note!.isNotEmpty)
            _InfoRow(
              icon: Icons.notes_rounded,
              label: 'یادداشت:  ${factor.note}',
              context: context,
            ),
        ],
      ),
    );
  }
}

//
// Factor Group Card
//
class _FactorGroupCard extends StatelessWidget {
  final FactorGroup group;
  const _FactorGroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        group.title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Text(
                      '${_formatPrice(group.groupTotalPrice)} ریال',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: 16,
                  children: [
                    _SmallInfo(
                      icon: Icons.heat_pump_rounded,
                      label: group.deviceName,
                      context: context,
                    ),
                    _SmallInfo(
                      icon: Icons.person_outline,
                      label: group.creator,
                      context: context,
                    ),
                    _SmallInfo(
                      icon: Icons.access_time,
                      label: group.timestamp,
                      context: context,
                    ),
                  ],
                ),
                Row(
                  spacing: 12,
                  children: [
                    _StatusChip(
                      icon: group.isCompleted
                          ? Icons.check_circle
                          : Icons.pending_outlined,
                      label: group.isCompleted ? 'تکمیل شده' : 'در انتظار',
                      color: group.isCompleted
                          ? Colors.green
                          : Theme.of(context).hintColor,
                    ),
                    _StatusChip(
                      icon: group.isSent
                          ? Icons.send
                          : Icons.schedule_send_outlined,
                      label: group.isSent ? 'ارسال شده' : 'ارسال نشده',
                      color: group.isSent
                          ? Colors.blue
                          : Theme.of(context).hintColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Events in this group
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              spacing: 6,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: group.events.map((event) {
                return _EventRow(event: event);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    final intPrice = price.toInt();
    final str = intPrice.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

//
// Event Row
//
class _EventRow extends StatelessWidget {
  final EventCategoryDetails event;
  const _EventRow({required this.event});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Icon(Icons.check, color: Colors.green, size: 18),
            Expanded(
              child: Text(
                '${event.category}: ${event.text}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        if (event.price != null && event.price! > 0)
          Padding(
            padding: const EdgeInsets.only(right: 22),
            child: Text(
              'مبلغ: ${_formatPrice(event.price!)} ریال',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }

  String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

//
// Helper widgets
//
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final BuildContext context;
  final Color? color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.context,
    this.color,
  });

  @override
  Widget build(BuildContext ctx) {
    return Row(
      spacing: 6,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color ?? Theme.of(ctx).hintColor),
        Expanded(child: Text(label, style: Theme.of(ctx).textTheme.labelSmall)),
      ],
    );
  }
}

class _SmallInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final BuildContext context;

  const _SmallInfo({
    required this.icon,
    required this.label,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 3,
      children: [
        Icon(icon, size: 12, color: Theme.of(ctx).hintColor),
        Flexible(
          child: Text(
            label,
            style: Theme.of(ctx).textTheme.labelSmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 3,
      children: [
        Icon(icon, size: 12, color: color),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: color, fontSize: 10),
        ),
      ],
    );
  }
}

String _formatPrice(double price) {
  final intPrice = price.toInt();
  final str = intPrice.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
    buffer.write(str[i]);
  }
  return buffer.toString();
}
