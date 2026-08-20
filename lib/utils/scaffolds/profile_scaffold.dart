import 'package:flutter/material.dart';
import 'package:shooka_flutter/components/drawer.dart';
import 'package:shooka_flutter/components/appbar_with_profile.dart';
import 'package:shooka_flutter/models/user_data_class.dart';
import 'package:shooka_flutter/utils/constants.dart';

class ProfileScaffold extends StatefulWidget {
  final Widget body;
  final String username;
  final String name;
  final String? image;
  final User? user;
  final Future<void> Function()? onRefresh;
  const ProfileScaffold({
    super.key,
    required this.body,
    required this.username,
    required this.name,
    this.image,
    this.user,
    this.onRefresh,
  });

  @override
  State<ProfileScaffold> createState() => _ProfileScaffoldState();
}

class _ProfileScaffoldState extends State<ProfileScaffold> {
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;

    final appBar = PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: kMaxContentWidth),
          child: ProfileAppbar(
            image: widget.image,
            name: widget.name,
            username: widget.username,
            user: widget.user,
          ),
        ),
      ),
    );

    final body = RefreshIndicator(
      onRefresh: widget.onRefresh ?? () async {},
      notificationPredicate: (_) => widget.onRefresh != null,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(15),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: kMaxContentWidth),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: widget.body,
            ),
          ),
        ),
      ),
    );

    if (isDesktop) {
      return Scaffold(
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MyDrawer(sidebar: true),
              Expanded(
                child: Column(
                  children: [
                    appBar,
                    Expanded(child: body),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      endDrawer: const MyDrawer(),
      body: body,
    );
  }
}
