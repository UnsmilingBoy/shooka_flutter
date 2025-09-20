import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/layouts/back_scaffold.dart';

class OrganiztionsTab extends StatelessWidget {
  const OrganiztionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const BackScaffold(
      backLabel: "خانه",
      backRoute: "/home",
      label: "سازمان ها",
      body: Text("Organiztions Tab"),
    );
  }
}
