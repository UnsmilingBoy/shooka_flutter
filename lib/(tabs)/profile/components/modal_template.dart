import 'package:flutter/material.dart';

class BottomModalTemplate extends StatefulWidget {
  final String title;
  final List<Widget> children;
  const BottomModalTemplate({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  State<BottomModalTemplate> createState() => _BottomModalTemplateState();
}

class _BottomModalTemplateState extends State<BottomModalTemplate> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(
            bottom: 30.0,
            left: 15,
            right: 15,
            top: 5,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Column(children: widget.children),
            ],
          ),
        ),
      ),
    );
  }
}
