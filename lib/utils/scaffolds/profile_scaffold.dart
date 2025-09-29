import 'package:flutter/material.dart';
import 'package:shooka_flutter/components/drawer.dart';
import 'package:shooka_flutter/components/appbar_with_profile.dart';

class ProfileScaffold extends StatefulWidget {
  final Widget body;
  final String username;
  final String name;
  final String image;
  const ProfileScaffold({
    super.key,
    required this.body,
    required this.username,
    required this.name,
    required this.image,
  });

  @override
  State<ProfileScaffold> createState() => _ProfileScaffoldState();
}

class _ProfileScaffoldState extends State<ProfileScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ProfileAppbar(
        image: widget.image,
        name: widget.name,
        username: widget.username,
      ),
      endDrawer: MyDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: widget.body,
        ),
      ),
    );
  }
}
