import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shooka_flutter/utils/buttons/my_icon_button.dart';
import 'package:shooka_flutter/utils/loadings/loading.dart';
import 'package:shooka_flutter/utils/textfields/outline_textfield.dart';

class TabHeader extends StatelessWidget {
  final TextEditingController searchController;
  final Widget? filterModal;
  final String searchPlaceholder;
  final bool? noFilter;
  final Function(String value)? onSubmitted;
  final VoidCallback? onExport;
  final bool exportLoading;
  const TabHeader({
    super.key,
    required this.searchController,
    this.filterModal,
    required this.searchPlaceholder,
    this.noFilter,
    this.onSubmitted,
    this.onExport,
    this.exportLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Row(
      spacing: 10,
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: Outlinetextfield(
              onSubmitted: onSubmitted,
              controller: searchController,
              placeholder: searchPlaceholder,
            ),
          ),
        ),
        // Only show export button on larger screens (width > 800)
        if (onExport != null && MediaQuery.of(context).size.width > 800)
          SizedBox(
            height: 50,
            width: 50,
            child: MyIconButton(
              onPressed: exportLoading ? null : onExport,
              color: Theme.of(context).colorScheme.primary,
              child: exportLoading
                  ? Loading()
                  : Icon(Icons.download_rounded, color: Colors.white),
            ),
          ),
        if (noFilter != true)
          SizedBox(
            height: 50,
            width: 50,
            child: MyIconButton(
              onPressed: () {
                if (isDesktop) {
                  showDialog(
                    context: context,
                    builder: (context) => filterModal ?? SizedBox(),
                  );
                } else {
                  showMaterialModalBottomSheet(
                    enableDrag: false,
                    context: context,
                    builder: (context) => filterModal ?? SizedBox(),
                  );
                }
              },
              color: Theme.of(context).colorScheme.secondary,
              child: Icon(Icons.filter_alt_rounded, color: Colors.white),
            ),
          ),
      ],
    );
  }
}
