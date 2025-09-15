import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/layouts/base_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: Column(
        spacing: 15,
        children: [
          Row(
            children: [
              Text(
                "پروفایل کاربری",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
