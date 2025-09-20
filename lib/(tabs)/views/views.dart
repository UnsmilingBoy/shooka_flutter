import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/layouts/back_scaffold.dart';

class ViewsTab extends StatelessWidget {
  const ViewsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BackScaffold(
      label: "نما ها",
      backLabel: "خانه",
      backRoute: "/home",
      body: Text("ViewsTab"),
    );
  }
}
