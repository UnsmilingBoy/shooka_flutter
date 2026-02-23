import 'package:flutter/material.dart';
import 'package:shooka_flutter/models/event_data_class.dart';

/// Shared content widget for displaying event details.
/// Used by both EventPage (mobile) and EventDetailPanel (large screens).
class EventContent extends StatelessWidget {
  final String title;
  final String device;
  final String creator;
  final String timeCreated;
  final List<EventCategoryDetails> message;
  final int? eventGroupId;
  final String? factorId;
  final bool isCompleted;
  final String? completedAt;
  final bool isSent;
  final String? sentAt;

  const EventContent({
    super.key,
    required this.title,
    required this.device,
    required this.creator,
    required this.timeCreated,
    required this.message,
    this.eventGroupId,
    this.factorId,
    this.isCompleted = false,
    this.completedAt,
    this.isSent = false,
    this.sentAt,
  });

  @override
  Widget build(BuildContext context) {
    final int totalPrice = message.fold(
      0,
      (sum, item) => sum + (item.price ?? 0),
    );

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          //
          // Title
          //
          Row(
            children: [
              Expanded(
                child: Text(
                  "عنوان: $title",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          Column(
            spacing: 2,
            children: [
              //
              // Device
              //
              _InfoRow(
                icon: Icons.heat_pump_rounded,
                label: "دستگاه:  $device",
                context: context,
              ),
              //
              // Author
              //
              _InfoRow(
                icon: Icons.attribution_outlined,
                label: "ایجادکننده:  $creator",
                context: context,
              ),
              //
              // Date
              //
              _InfoRow(
                icon: Icons.date_range,
                label: "زمان ایجاد:  $timeCreated",
                context: context,
              ),
              //
              // Factor ID
              //
              if (factorId != null)
                _InfoRow(
                  icon: Icons.receipt_long_rounded,
                  label: "شماره فاکتور:  $factorId",
                  context: context,
                ),
              //
              // Completion status
              //
              _InfoRow(
                icon: isCompleted ? Icons.check_circle : Icons.pending_outlined,
                label: isCompleted
                    ? "تکمیل شده${completedAt != null ? ':  $completedAt' : ''}"
                    : "در انتظار تکمیل",
                context: context,
                color: isCompleted ? Colors.green : Theme.of(context).hintColor,
              ),
              //
              // Sent status
              //
              _InfoRow(
                icon: isSent ? Icons.send : Icons.schedule_send_outlined,
                label: isSent
                    ? "ارسال شده${sentAt != null ? ':  $sentAt' : ''}"
                    : "ارسال نشده",
                context: context,
                color: isSent ? Colors.blue : Theme.of(context).hintColor,
              ),
            ],
          ),

          //
          // Event (report) Content
          //
          Divider(color: Theme.of(context).hintColor),
          Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: message.map((item) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 3,
                    children: [
                      Icon(Icons.check, color: Colors.green, size: 20),
                      Expanded(
                        child: Text(
                          "${item.category}: ${item.text}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  if (item.price != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 23),
                      child: Text(
                        "مبلغ: ${_formatPrice(item.price!)} ریال",
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              );
            }).toList(),
          ),

          //
          // Total Price
          //
          if (totalPrice > 0) ...[
            Divider(color: Theme.of(context).hintColor),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "جمع کل:",
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  "${_formatPrice(totalPrice)} ریال",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
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
      spacing: 3,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color ?? Theme.of(ctx).hintColor),
        Expanded(child: Text(label, style: Theme.of(ctx).textTheme.labelSmall)),
      ],
    );
  }
}
