import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/layouts/back_scaffold.dart';

class UsersTab extends StatelessWidget {
  const UsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BackScaffold(
      backLabel: "خانه",
      backRoute: "/home",
      label: "کاربران",
      body: Text("Users Tab"),
    );
  }
}
