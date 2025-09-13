import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/components/drawer.dart';
import 'package:shooka_flutter/core/theme/theme_provider.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      //
      // Appbar
      //
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),

      //
      // Drawer
      //
      endDrawer: Drawer(child: MyDrawer()),

      //
      // Body
      //
      body: Center(
        child: IconButton(
          icon: Icon(
            color: Theme.of(context).colorScheme.secondary,
            themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            size: 50,
          ),
          onPressed: () {
            themeProvider.toggleTheme(!themeProvider.isDarkMode);
          },
        ),
      ),
    );
  }
}
