import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';

class AddDeviceModal extends StatelessWidget {
  const AddDeviceModal({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomModalTemplate(
      title: "افزودن موتورخانه",
      children: [Text("Add device")],
    );
  }
}
