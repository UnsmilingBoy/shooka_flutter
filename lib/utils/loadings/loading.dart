import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final double? size;
  final Color? color;
  const Loading({super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size ?? 20,
      height: size ?? 20,
      child: CircularProgressIndicator(
        color: color ?? Theme.of(context).colorScheme.primary,
        strokeWidth: 2,
      ),
    );
  }
}
