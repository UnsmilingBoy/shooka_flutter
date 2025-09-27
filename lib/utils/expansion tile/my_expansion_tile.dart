import 'package:flutter/material.dart';

class MyExpansionTile extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool? initiallyExpanded;
  const MyExpansionTile({
    super.key,
    required this.title,
    required this.children,
    this.initiallyExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(5),
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded == true,
        tilePadding: EdgeInsets.symmetric(horizontal: 5),
        childrenPadding: EdgeInsets.only(bottom: 10),
        iconColor: Theme.of(context).colorScheme.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide.none,
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide.none,
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
        children: children,
      ),
    );
  }
}
