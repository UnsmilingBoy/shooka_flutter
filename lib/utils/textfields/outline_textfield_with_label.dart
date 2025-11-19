import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/textfields/outline_textfield.dart';

class Outlinetextfieldwithlabel extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String placeHolder;
  final bool? isPassword;
  final bool? isSerialNumber;
  const Outlinetextfieldwithlabel({
    super.key,
    required this.label,
    required this.controller,
    required this.placeHolder,
    this.isPassword,
    this.isSerialNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 3,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Outlinetextfield(
          isSerialNumber: isSerialNumber,
          placeholder: placeHolder,
          controller: controller,
          isPassword: isPassword,
        ),
      ],
    );
  }
}
