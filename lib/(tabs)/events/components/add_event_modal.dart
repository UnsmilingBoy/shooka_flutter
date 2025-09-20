import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';

class AddEventModal extends StatelessWidget {
  const AddEventModal({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomModalTemplate(
      title: "رویداد جدید",
      children: [Text("add even")],
    );
  }
}
