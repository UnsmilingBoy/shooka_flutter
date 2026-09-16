import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/services/providers/inventory_provider.dart';

class InventoryStatsTiles extends StatelessWidget {
  const InventoryStatsTiles({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();
    final scheme = Theme.of(context).colorScheme;
    final borderColor = scheme.outline.withValues(alpha: 0.45);
    final tiles = [
      _InventoryStat(
        label: 'فرم‌های ثبت‌شده',
        value: '${provider.totalCount}',
        icon: Icons.inventory_2_outlined,
        color: scheme.primary,
      ),
      _InventoryStat(
        label: 'دستگاه‌های ثبت‌شده',
        value:
            '${provider.forms.fold(0, (sum, form) => sum + form.deviceCount)}',
        icon: Icons.handyman_outlined,
        color: scheme.tertiary,
      ),
      _InventoryStat(
        label: 'اقلام نصب ثبت‌شده',
        value:
            '${provider.forms.fold(0, (sum, form) => sum + form.installItems.fold(0, (itemSum, item) => itemSum + item.quantity))}',
        icon: Icons.assignment_return_outlined,
        color: scheme.error,
      ),
      _InventoryStat(
        label: 'مقصدهای فعال',
        value:
            '${provider.forms.map((form) => form.destination.trim()).where((destination) => destination.isNotEmpty).toSet().length}',
        icon: Icons.location_on_outlined,
        color: scheme.primary,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 800;
        if (wide) {
          return Row(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(stat: tiles[i], borderColor: borderColor),
                ),
              ],
            ],
          );
        }

        final width = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final tile in tiles)
              SizedBox(
                width: width,
                child: _StatCard(stat: tile, borderColor: borderColor),
              ),
          ],
        );
      },
    );
  }
}

class _InventoryStat {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InventoryStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _StatCard extends StatelessWidget {
  final _InventoryStat stat;
  final Color borderColor;

  const _StatCard({required this.stat, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(stat.icon, color: stat.color, size: 19),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.value,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
