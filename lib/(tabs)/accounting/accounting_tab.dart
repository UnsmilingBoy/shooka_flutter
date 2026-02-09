import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/scaffolds/back_scaffold.dart';

class AccountingTab extends StatelessWidget {
  const AccountingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BackScaffold(
      body: Container(),
      label: "حسابداری",
      backRoute: "/home",
      backLabel: "خانه",
    );
  }
}
