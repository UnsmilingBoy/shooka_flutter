import 'package:flutter/material.dart';

class DropdownWithLabel extends StatelessWidget {
  final String label;
  final String placeholder;
  final String? initialValue;
  final List<DropdownMenuItem<String>> items;
  final void Function(String?)? onChanged;

  const DropdownWithLabel({
    super.key,
    this.initialValue,
    required this.items,
    this.onChanged,
    required this.label,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 3,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Container(
          margin: EdgeInsets.only(bottom: 10),
          child: DropdownButtonFormField<String>(
            initialValue: initialValue,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey.shade700,
                  width: 1,
                ), // default border
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey.shade700,
                  width: 1,
                ), // default border
              ),
              contentPadding: EdgeInsets.all(13),
            ),
            items: items,
            onChanged: onChanged,
            hint: Text(placeholder),
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      ],
    );
  }
}
