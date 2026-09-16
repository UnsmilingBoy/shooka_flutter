import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/forms/pack_form_modal.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/forms/parts_form_modal.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/forms/returned_form_modal.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/shared/adaptive_modal.dart';

class InventoryActionButtons extends StatelessWidget {
  const InventoryActionButtons({super.key});

  void _openForm(BuildContext context, Widget formModal) {
    showAdaptiveInventoryModal(context, formModal);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final actions = [
      _InventoryAction(
        title: 'فرم ارسال پک دستگاه',
        description: 'ثبت دستگاه‌های جدید',
        icon: Icons.inventory_2_outlined,
        color: scheme.primary,
        form: const PackFormModal(),
      ),
      _InventoryAction(
        title: 'فرم ارسال قطعات',
        description: 'ثبت قطعات و اقلام مصرفی',
        icon: Icons.handyman_outlined,
        color: scheme.tertiary,
        form: const PartsFormModal(),
      ),
      _InventoryAction(
        title: 'فرم برگشتی',
        description: 'ثبت اقلام برگشت‌خورده',
        icon: Icons.assignment_return_outlined,
        color: scheme.error,
        form: const ReturnedFormModal(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 10),
          child: Row(
            children: [
              Icon(
                Icons.post_add_outlined,
                size: 17,
                color: scheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'ثبت فرم جدید',
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 800;
            if (wide) {
              return Row(
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(
                      child: _ActionCard(
                        action: actions[i],
                        onTap: () => _openForm(context, actions[i].form),
                      ),
                    ),
                  ],
                ],
              );
            }

            final itemWidth = constraints.maxWidth >= 520
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final action in actions)
                  SizedBox(
                    width: itemWidth,
                    child: _ActionCard(
                      action: action,
                      onTap: () => _openForm(context, action.form),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _InventoryAction {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Widget form;

  const _InventoryAction({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.form,
  });
}

class _ActionCard extends StatelessWidget {
  final _InventoryAction action;
  final VoidCallback onTap;

  const _ActionCard({required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    // Tinted surface card: the accent hue shows in the icon tile, border
    // and chevron while text stays on-surface — calm in light mode,
    // luminous in dark mode (no muddy solid fills).
    return Material(
      color: action.color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: action.color.withValues(alpha: 0.28),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(action.icon, color: action.color, size: 22),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      action.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelLarge?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      action.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_left_rounded,
                size: 22,
                color: action.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
