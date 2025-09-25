import 'package:flutter/material.dart';

class MySwitch extends StatefulWidget {
  final bool switchValue;
  final ValueChanged<bool>? onChanged;
  const MySwitch({super.key, required this.switchValue, this.onChanged});

  @override
  State<MySwitch> createState() => _MySwitchState();
}

class _MySwitchState extends State<MySwitch> {
  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.70,
      child: Switch(
        activeThumbColor: Colors.white,
        activeTrackColor: Theme.of(context).colorScheme.primary,
        value: widget.switchValue,
        onChanged: widget.onChanged,
      ),
    );
  }
}
