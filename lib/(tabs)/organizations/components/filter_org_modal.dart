import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';

class FilterOrgModal extends StatelessWidget {
  const FilterOrgModal({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomModalTemplate(
      title: "فیلتر سازمان",
      children: [Text("Org Filter")],
    );
  }
}
