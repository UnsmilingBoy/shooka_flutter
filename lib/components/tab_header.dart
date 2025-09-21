import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shooka_flutter/utils/buttons/my_icon_button.dart';
import 'package:shooka_flutter/utils/textfields/outline_textfield.dart';

class TabHeader extends StatelessWidget {
  final TextEditingController searchController;
  final Widget filterModal;
  final String searchPlaceholder;
  const TabHeader({
    super.key,
    required this.searchController,
    required this.filterModal,
    required this.searchPlaceholder,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: Outlinetextfield(
              controller: searchController,
              placeholder: searchPlaceholder,
            ),
          ),
        ),
        SizedBox(
          height: 50,
          width: 50,
          child: MyIconButton(
            onPressed: () => showMaterialModalBottomSheet(
              enableDrag: false,
              context: context,
              builder: (context) => filterModal,
            ),
            color: Theme.of(context).colorScheme.secondary,
            child: Icon(Icons.filter_alt_rounded),
          ),
        ),
      ],
    );
  }
}
