import 'package:flutter/material.dart';

class OutlineTextformfield extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  const OutlineTextformfield({
    super.key,
    required this.controller,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.multiline,
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: Theme.of(context).textTheme.labelSmall,
        contentPadding: EdgeInsets.symmetric(vertical: 13, horizontal: 5),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1,
          ), // default border
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey.shade700,
            width: 1,
          ), // default border
        ),
      ),
    );
  }
}
