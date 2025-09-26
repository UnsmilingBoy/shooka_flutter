import 'package:flutter/material.dart';

class BottomModalTemplate extends StatefulWidget {
  final String title;
  final bool? isLongList;
  final List<Widget> children;
  const BottomModalTemplate({
    super.key,
    required this.title,
    required this.children,
    this.isLongList,
  });

  @override
  State<BottomModalTemplate> createState() => _BottomModalTemplateState();
}

class _BottomModalTemplateState extends State<BottomModalTemplate> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 30.0,
            left: 15,
            right: 15,
            // top: widget.isLongList == true ? 15 : 0,
          ),
          child: SingleChildScrollView(
            // This ensures the scroll view resizes when the keyboard appears
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
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
      ),
    );
  }
}
