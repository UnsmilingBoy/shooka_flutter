import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/buttons/my_icon_button.dart';

class DropdownWithLabel extends StatefulWidget {
  final String label;
  final String placeholder;
  final String? initialValue;
  final List<DropdownMenuItem<String>> items;
  final void Function(String?)? onChanged;
  final GestureTapCallback? iconOnPressed;

  const DropdownWithLabel({
    super.key,
    this.initialValue,
    required this.items,
    this.onChanged,

    required this.label,
    required this.placeholder,
    this.iconOnPressed,
  });

  @override
  State<DropdownWithLabel> createState() => _DropdownWithLabelState();
}

class _DropdownWithLabelState extends State<DropdownWithLabel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 3,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label),
        Row(
          spacing: 5,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                child: DropdownButtonFormField<String>(
                  initialValue: widget.initialValue,
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
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 13,
                      horizontal: 5,
                    ),
                  ),
                  items: widget.items,
                  onChanged: widget.onChanged,
                  hint: Text(
                    widget.placeholder,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ),
            if (widget.initialValue != null)
              MyIconButton(
                onPressed: widget.iconOnPressed,
                padding: EdgeInsets.all(5),
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
