import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/expansion%20tile/my_expansion_tile.dart';

class DpEvents extends StatelessWidget {
  const DpEvents({super.key});

  @override
  Widget build(BuildContext context) {
    return MyExpansionTile(title: "رخدادها", children: [Text("cat")]);
  }
}
