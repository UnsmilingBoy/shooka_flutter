import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';

class FilterDeviceModal extends StatelessWidget {
  const FilterDeviceModal({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomModalTemplate(
      title: "فیلتر موتورخانه ها",
      children: [Text("filter")],
    );
  }
}
