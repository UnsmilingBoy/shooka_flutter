import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';

class FilterEventModal extends StatelessWidget {
  const FilterEventModal({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomModalTemplate(
      title: "فیلتر رویداد ها",
      children: [Text("filter event")],
    );
  }
}
