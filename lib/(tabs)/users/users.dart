import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/layouts/profile_scaffold.dart';

class UsersTab extends StatelessWidget {
  const UsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileScaffold(body: Text("Users Tab"));
  }
}
