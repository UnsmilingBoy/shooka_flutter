import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';

class FilterUsersModal extends StatelessWidget {
  const FilterUsersModal({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomModalTemplate(
      title: "فیلتر کاربران",
      children: [Text("User Filter")],
    );
  }
}
