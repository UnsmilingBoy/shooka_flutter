import 'package:flutter/material.dart';

class Outlinetextfield extends StatefulWidget {
  final TextEditingController controller;
  const Outlinetextfield({super.key, required this.controller});

  @override
  State<Outlinetextfield> createState() => _OutlinetextfieldState();
}

class _OutlinetextfieldState extends State<Outlinetextfield> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.all(13),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
            width: 1,
          ), // default border
        ),
      ),
      controller: widget.controller,
    );
  }
}
