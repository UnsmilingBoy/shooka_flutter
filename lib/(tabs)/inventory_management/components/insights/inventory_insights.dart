import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/insights/inventory_stats_tiles.dart';
import 'package:shooka_flutter/models/inventory_form_data_class.dart';
import 'package:shooka_flutter/services/providers/inventory_provider.dart';

class InventoryInsights extends StatelessWidget {
  const InventoryInsights({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();
    final forms = provider.forms;
    final metrics = _InventoryMetrics.fromForms(forms);

    if (provider.fetchLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const InventoryStatsTiles(),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final charts = [
                _DestinationChart(destinations: metrics.destinations),
                _CompositionChart(metrics: metrics),
              ];
              if (constraints.maxWidth >= 760) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: charts[0]),
                    const SizedBox(width: 16),
                    Expanded(child: charts[1]),
                  ],
                );
              }
              return Column(
                children: [charts[0], const SizedBox(height: 16), charts[1]],
              );
            },
          ),
          const SizedBox(height: 18),
          _MetricsTable(metrics: metrics),
        ],
      ),
    );
  }
}

class _InventoryMetrics {
  final int forms;
  final int devices;
  final int installItems;
  final Map<String, int> destinations;

  const _InventoryMetrics({
    required this.forms,
    required this.devices,
    required this.installItems,
    required this.destinations,
  });

  factory _InventoryMetrics.fromForms(List<InventoryFormItem> forms) {
    final destinations = <String, int>{};
    var devices = 0;
    var installItems = 0;
    for (final form in forms) {
      devices += form.deviceCount;
      installItems += form.installItems.fold(
        0,
        (total, item) => total + item.quantity,
      );
      final destination = form.destination.trim().isEmpty
          ? 'بدون مقصد'
          : form.destination.trim();
      destinations.update(destination, (count) => count + 1, ifAbsent: () => 1);
    }
    return _InventoryMetrics(
      forms: forms.length,
      devices: devices,
      installItems: installItems,
      destinations: destinations,
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _InsightCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outline.withValues(alpha: .4)),
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
                  color: scheme.primary.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 18, color: scheme.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _DestinationChart extends StatelessWidget {
  final Map<String, int> destinations;

  const _DestinationChart({required this.destinations});

  @override
  Widget build(BuildContext context) {
    final ordered = destinations.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final shown = ordered.take(4).toList();
    final maximum = shown.fold<int>(
      1,
      (maxValue, entry) => math.max(maxValue, entry.value),
    );
    final scheme = Theme.of(context).colorScheme;

    return _InsightCard(
      title: 'مقصدهای پرتکرار',
      subtitle: 'براساس فرم‌های بارگذاری‌شده',
      icon: Icons.location_on_outlined,
      child: shown.isEmpty
          ? const _ChartEmptyState()
          : Column(
              children: [
                for (final entry in shown) ...[
                  Row(
                    children: [
                      SizedBox(
                        width: 94,
                        child: Text(
                          entry.key,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: entry.value / maximum,
                            minHeight: 9,
                            backgroundColor: scheme.primary.withValues(
                              alpha: .1,
                            ),
                            valueColor: AlwaysStoppedAnimation(scheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${entry.value}',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  if (entry != shown.last) const SizedBox(height: 15),
                ],
              ],
            ),
    );
  }
}

class _CompositionChart extends StatelessWidget {
  final _InventoryMetrics metrics;

  const _CompositionChart({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final total = metrics.forms + metrics.devices + metrics.installItems;
    final scheme = Theme.of(context).colorScheme;
    final segments = [
      _ChartSegment('فرم‌ها', metrics.forms, scheme.primary),
      _ChartSegment('دستگاه‌ها', metrics.devices, scheme.tertiary),
      _ChartSegment('اقلام نصب', metrics.installItems, scheme.error),
    ];
    return _InsightCard(
      title: 'ترکیب گردش انبار',
      subtitle: 'نمایی از داده‌های بارگذاری‌شده',
      icon: Icons.pie_chart_outline_rounded,
      child: total == 0
          ? const _ChartEmptyState()
          : Row(
              children: [
                SizedBox(
                  width: 118,
                  height: 118,
                  child: CustomPaint(
                    painter: _DonutPainter(
                      segments: segments,
                      total: total,
                      trackColor: scheme.surfaceContainerHighest,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$total',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            'مجموع',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final segment in segments) ...[
                        _LegendItem(segment: segment),
                        if (segment != segments.last)
                          const SizedBox(height: 11),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _ChartSegment {
  final String label;
  final int value;
  final Color color;

  const _ChartSegment(this.label, this.value, this.color);
}

class _LegendItem extends StatelessWidget {
  final _ChartSegment segment;

  const _LegendItem({required this.segment});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: segment.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            segment.label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        Text(
          '${segment.value}',
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<_ChartSegment> segments;
  final int total;
  final Color trackColor;

  const _DonutPainter({
    required this.segments,
    required this.total,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    canvas.drawCircle(center, radius, track);

    var startAngle = -math.pi / 2;
    for (final segment in segments) {
      if (segment.value == 0) continue;
      final sweep = (segment.value / total) * (math.pi * 2);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..color = segment.color;
      canvas.drawArc(rect, startAngle, math.max(0, sweep - .05), false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.total != total ||
      oldDelegate.segments != segments ||
      oldDelegate.trackColor != trackColor;
}

class _MetricsTable extends StatelessWidget {
  final _InventoryMetrics metrics;

  const _MetricsTable({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rows = [
      ('فرم‌های بارگذاری‌شده', metrics.forms, Icons.description_outlined),
      ('دستگاه‌های ثبت‌شده', metrics.devices, Icons.inventory_2_outlined),
      ('اقلام نصب ثبت‌شده', metrics.installItems, Icons.handyman_outlined),
      ('مقصدهای فعال', metrics.destinations.length, Icons.location_on_outlined),
    ];
    return _InsightCard(
      title: 'جدول خلاصه',
      subtitle: 'جمع‌بندی وضعیت موجودی در این نما',
      icon: Icons.table_chart_outlined,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: scheme.outline.withValues(alpha: .35)),
        ),
        child: Column(
          children: [
            for (var index = 0; index < rows.length; index++) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(rows[index].$3, size: 18, color: scheme.primary),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        rows[index].$1,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                    Text(
                      '${rows[index].$2}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (index < rows.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: scheme.outlineVariant.withValues(alpha: 0.7),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChartEmptyState extends StatelessWidget {
  const _ChartEmptyState();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 118,
    child: Center(
      child: Text(
        'داده‌ای برای نمایش وجود ندارد',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ),
  );
}
