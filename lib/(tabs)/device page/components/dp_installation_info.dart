import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/expansion%20tile/my_expansion_tile.dart';

class InstallationInfo extends StatelessWidget {
  const InstallationInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return MyExpansionTile(title: "اطلاعات نصب", children: [Text("cat")]);
  }
}
