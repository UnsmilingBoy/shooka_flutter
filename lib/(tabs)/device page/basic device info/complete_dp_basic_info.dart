import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';

class CompleteDpBasicInfo extends StatefulWidget {
  const CompleteDpBasicInfo({super.key});

  @override
  State<CompleteDpBasicInfo> createState() => _CompleteDpBasicInfoState();
}

class _CompleteDpBasicInfoState extends State<CompleteDpBasicInfo> {
  @override
  Widget build(BuildContext context) {
    return BottomModalTemplate(
      title: "ویرایش اطلاعات موتورخانه",
      children: [Container()],
    );
  }
}
