import 'package:flutter/material.dart';
import 'package:shooka_flutter/components/drawer.dart';

class BackScaffold extends StatefulWidget {
  final Widget body;
  final String label;
  final String backRoute;
  final String backLabel;
  final Widget? floatingActionButton;
  const BackScaffold({
    super.key,
    required this.body,
    required this.label,
    required this.backRoute,
    required this.backLabel,
    this.floatingActionButton,
  });

  @override
  State<BackScaffold> createState() => _BackScaffoldState();
}

class _BackScaffoldState extends State<BackScaffold> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: widget.floatingActionButton,
        //
        // Appbar
        //
        appBar: AppBar(
          title: Text(widget.label),
          centerTitle: true,
          actions: [
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () =>
                  Navigator.of(context).pushReplacementNamed(widget.backRoute),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 5,
                  children: [
                    Text(
                      widget.backLabel,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
            SizedBox(width: 5),
          ],
        ),

        //
        // Drawer
        //
        drawer: MyDrawer(),

        //
        // Body
        //
        body: Padding(
          padding: EdgeInsets.all(15),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: widget.body,
          ),
        ),
      ),
    );
  }
}
