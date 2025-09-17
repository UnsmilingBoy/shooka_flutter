import 'package:flutter/material.dart';
import 'package:shooka_flutter/components/drawer.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        //
        // Appbar
        //
        appBar: AppBar(
          title: Text("حساب کاربری"),
          centerTitle: true,
          actions: [
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => Navigator.of(context).pushNamed("/home"),
              child: Container(
                // margin: EdgeInsets.only(left: 5),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 5,
                  children: [
                    Text("خانه", style: TextStyle(fontWeight: FontWeight.bold)),
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
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 15,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage("assets/images/profile.jpg"),
                    radius: 60,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
