import 'package:flutter/material.dart';

class MainmenuContainer extends StatefulWidget {
  final Widget child;
  final double? height;
  final EdgeInsets? padding;
  final double? borderRadius;
  const MainmenuContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.height,
  });

  @override
  State<MainmenuContainer> createState() => _MainmenuContainerState();
}

class _MainmenuContainerState extends State<MainmenuContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      padding: widget.padding ?? EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
      ),

      child: widget.child,
    );
  }
}
