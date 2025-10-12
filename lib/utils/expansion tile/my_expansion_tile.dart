import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/buttons/my_icon_button.dart';

class MyExpansionTile extends StatelessWidget {
  final String title;
  final VoidCallback? completeOnPressed;
  final List<Widget> children;
  final bool? initiallyExpanded;
  final EdgeInsets? padding;
  const MyExpansionTile({
    super.key,
    required this.title,
    required this.children,
    this.initiallyExpanded,
    this.padding,
    this.completeOnPressed,
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
        childrenPadding:
            padding ?? EdgeInsets.only(bottom: 10, left: 15, right: 15),
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
          child: Row(
            spacing: 5,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              if (completeOnPressed != null)
                MyIconButton(
                  padding: EdgeInsets.all(7),
                  onPressed: completeOnPressed,
                  child: Icon(
                    Icons.edit_document,
                    size: 18,
                    color: Theme.of(context).hintColor,
                  ),
                ),
            ],
          ),
        ),
        children: children,
      ),
    );
  }
}
