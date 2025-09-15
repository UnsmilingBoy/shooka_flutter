import 'package:flutter/material.dart';

class MainmenuContainer extends StatefulWidget {
  final Widget child;
  // final EdgeInsets? padding;
  final double? borderRadius;
  const MainmenuContainer({
    super.key,
    required this.child,
    // this.padding,
    this.borderRadius,
  });

  @override
  State<MainmenuContainer> createState() => _MainmenuContainerState();
}

class _MainmenuContainerState extends State<MainmenuContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 20),
      ),

      child: widget.child,
    );
  }
}
