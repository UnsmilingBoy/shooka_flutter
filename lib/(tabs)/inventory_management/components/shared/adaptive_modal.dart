import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

/// Shows [child] as a centered dialog on wide screens and as a bottom
/// sheet on compact screens, so modal flows feel native on both.
Future<T?> showAdaptiveInventoryModal<T>(BuildContext context, Widget child) {
  if (MediaQuery.sizeOf(context).width >= 900) {
    return showDialog<T>(context: context, builder: (_) => child);
  }
  return showMaterialModalBottomSheet<T>(
    context: context,
    enableDrag: false,
    builder: (_) => child,
  );
}
