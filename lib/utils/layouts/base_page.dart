import 'package:flutter/material.dart';
import 'package:shooka_flutter/components/drawer.dart';
import 'package:shooka_flutter/components/my_appbar.dart';

class BasePage extends StatefulWidget {
  final Widget body;
  const BasePage({super.key, required this.body});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(),
      endDrawer: MyDrawer(),
      body: SingleChildScrollView(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: widget.body,
        ),
      ),
    );
  }
}
