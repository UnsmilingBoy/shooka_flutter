import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';

class FilterLocationsModal extends StatelessWidget {
  const FilterLocationsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomModalTemplate(
      title: "فیلتر مکان",
      children: [Text("Location Filter")],
    );
  }
}
