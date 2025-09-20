import 'package:flutter/material.dart';

class MyIconButton extends StatelessWidget {
  final Widget child;
  final GestureTapCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? color;
  const MyIconButton({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderRadius,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(borderRadius ?? 5),
      onLongPress: () => print("Filter"),
      child: Ink(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius ?? 5),
        ),
        padding: padding ?? EdgeInsets.all(10),
        child: child,
      ),
    );
  }
}
