import 'package:flutter/material.dart';

class Outlinetextfield extends StatefulWidget {
  final TextEditingController controller;
  final String? placeholder;
  final double? height;
  const Outlinetextfield({
    super.key,
    required this.controller,
    this.placeholder,
    this.height,
  });

  @override
  State<Outlinetextfield> createState() => _OutlinetextfieldState();
}

class _OutlinetextfieldState extends State<Outlinetextfield> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      style: Theme.of(context).textTheme.labelMedium,
      decoration: InputDecoration(
        hintStyle: Theme.of(context).textTheme.labelSmall,
        hintText: widget.placeholder,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        contentPadding: EdgeInsets.symmetric(vertical: 13, horizontal: 5),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey.shade700,
            width: 1,
          ), // default border
        ),
      ),
      controller: widget.controller,
    );
  }
}
