import 'package:flutter/material.dart';

/// Shared visual language for inventory forms. It intentionally relies on the
/// app theme's Vazirmatn text styles so these modal flows match the device tab.
class InventoryFormHeader extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color? color;
  final bool showRequiredHint;

  const InventoryFormHeader({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.color,
    this.showRequiredHint = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = color ?? scheme.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: .18)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (showRequiredHint)
            Text(
              '* الزامی',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

class InventoryFormSection extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const InventoryFormSection({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline.withValues(alpha: .4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 19, color: scheme.primary),
              const SizedBox(width: 8),
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
                      description,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(
              height: 1,
              thickness: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class InventoryFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final bool required;
  final bool readOnly;
  final int maxLines;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;

  const InventoryFormField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.hint = '',
    this.required = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.keyboardType,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    readOnly: readOnly,
    onTap: onTap,
    maxLines: maxLines,
    keyboardType: keyboardType,
    style: Theme.of(context).textTheme.bodyMedium,
    decoration: inventoryInputDecoration(
      context,
      label: required ? '$label*' : label,
      hint: hint,
      icon: icon,
    ),
  );
}

class InventoryFormPair extends StatelessWidget {
  final Widget first;
  final Widget second;

  const InventoryFormPair({
    super.key,
    required this.first,
    required this.second,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 500) {
        return Column(children: [first, const SizedBox(height: 12), second]);
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: first),
          const SizedBox(width: 12),
          Expanded(child: second),
        ],
      );
    },
  );
}

class InventoryAddRowButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const InventoryAddRowButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
      label: Text(label),
      style: TextButton.styleFrom(
        textStyle: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
  );
}

InputDecoration inventoryInputDecoration(
  BuildContext context, {
  required String label,
  required IconData icon,
  String hint = '',
}) {
  final scheme = Theme.of(context).colorScheme;
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(9),
    borderSide: BorderSide(color: scheme.outline.withValues(alpha: .5)),
  );
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon, size: 19),
    isDense: true,
    filled: true,
    fillColor: scheme.surfaceContainerLow,
    labelStyle: Theme.of(context).textTheme.labelSmall,
    hintStyle: Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: BorderSide(color: scheme.primary, width: 1.3),
    ),
  );
}

class InventoryEmptyItems extends StatelessWidget {
  final String message;

  const InventoryEmptyItems({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
