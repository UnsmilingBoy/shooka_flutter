import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class AddFloatingButton extends StatelessWidget {
  final Widget addModal;
  const AddFloatingButton({super.key, required this.addModal});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return InkWell(
      borderRadius: BorderRadius.circular(1000),
      onTap: () {
        if (isDesktop) {
          showDialog(context: context, builder: (context) => addModal);
        } else {
          showMaterialModalBottomSheet(
            enableDrag: false,
            context: context,
            builder: (context) => addModal,
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).primaryColor,
        ),
        padding: EdgeInsets.all(20),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
