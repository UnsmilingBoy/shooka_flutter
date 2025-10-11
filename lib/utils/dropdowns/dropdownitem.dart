import 'package:flutter/material.dart';

DropdownMenuItem<String> myDropDownItem({
  required String value,
  required String label,
}) {
  return DropdownMenuItem<String>(
    value: value,
    alignment: AlignmentDirectional.centerEnd,
    child: Row(
      children: [Expanded(child: Text(label, textAlign: TextAlign.right))],
    ),
  );
}
