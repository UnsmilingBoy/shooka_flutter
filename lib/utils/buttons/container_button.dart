import 'package:flutter/material.dart';

class ContainerButton extends StatefulWidget {
  final double? borderRadius;
  final EdgeInsets? margin;
  final Widget child;
  final Color? color;
  final VoidCallback? onPressed;
  final bool? fillWidth;
  final EdgeInsets? padding;
  const ContainerButton({
    super.key,
    this.borderRadius,
    required this.child,
    this.onPressed,
    this.padding,
    this.color,
    this.fillWidth,
    this.margin,
  });

  @override
  State<ContainerButton> createState() => _ContainerButtonState();
}

class _ContainerButtonState extends State<ContainerButton> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(0),
      margin: widget.margin,
      width: widget.fillWidth == true ? double.infinity : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
        color: widget.color,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
        child: MaterialButton(
          disabledColor: Theme.of(context).primaryColor,
          disabledTextColor: Colors.white,
          // Default hover is black/white at 4% — invisible on light
          // surfaces. A primary tint stays subtle but visible in both
          // modes and matches the selection/tab accents.
          hoverColor: isDark
              ? scheme.primary.withValues(alpha: 0.16)
              : scheme.primary.withValues(alpha: 0.08),
          padding: widget.padding,
          onPressed: widget.onPressed,
          child: widget.child,
        ),
      ),
    );
  }
}
