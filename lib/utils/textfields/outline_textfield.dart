import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/buttons/my_icon_button.dart';

class Outlinetextfield extends StatefulWidget {
  final TextEditingController controller;
  final String? placeholder;
  final double? height;
  final bool? isPassword;
  final Function(String value)? onSubmitted;
  const Outlinetextfield({
    super.key,
    required this.controller,
    this.placeholder,
    this.height,
    this.isPassword,
    this.onSubmitted,
  });

  @override
  State<Outlinetextfield> createState() => _OutlinetextfieldState();
}

class _OutlinetextfieldState extends State<Outlinetextfield> {
  bool? isPassword;

  @override
  void initState() {
    isPassword = widget.isPassword;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      onSubmitted: widget.onSubmitted,
      style: Theme.of(context).textTheme.labelMedium,
      obscureText: isPassword == true,
      decoration: InputDecoration(
        hintStyle: Theme.of(context).textTheme.labelSmall,
        hintText: widget.placeholder,
        suffixIcon: widget.isPassword == true
            ? MyIconButton(
                onPressed: () => setState(() {
                  isPassword = !isPassword!;
                }),
                child: Icon(Icons.remove_red_eye_rounded, size: 17),
              )
            : null,
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
