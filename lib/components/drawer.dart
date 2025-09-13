import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/tabs_list.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/icons/romak-logo.png'),
                ),
                Text(
                  'پنل شوکا',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: tabsList.map<Widget>((tab) {
                return ListTile(
                  title: Text(tab["label"] ?? ''),
                  onTap: () {
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
