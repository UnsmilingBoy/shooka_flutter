import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final double? size;
  const Loading({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size ?? 20,
      height: size ?? 20,
      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
    );
  }
}
