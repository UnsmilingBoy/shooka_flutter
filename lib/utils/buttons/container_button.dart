import 'package:flutter/material.dart';

class ContainerButton extends StatefulWidget {
  final double? borderRadius;
  final Widget child;
  final Color? color;
  final VoidCallback? onPressed;
  final EdgeInsets? padding;
  const ContainerButton({
    super.key,
    this.borderRadius,
    required this.child,
    this.onPressed,
    this.padding,
    this.color,
  });

  @override
  State<ContainerButton> createState() => _ContainerButtonState();
}

class _ContainerButtonState extends State<ContainerButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
        color: widget.color,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
        child: MaterialButton(
          disabledColor: Theme.of(context).primaryColor,
          disabledTextColor: Colors.white,
          padding: widget.padding,
          onPressed: widget.onPressed,
          child: widget.child,
        ),
      ),
    );
  }
}
