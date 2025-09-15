import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/tabs_list.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    String? routeName = ModalRoute.of(context)?.settings.name;

    return Drawer(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            //
            // Drawer Header
            //
            SizedBox(height: 60),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 5,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 27,
                    child: Image.asset(
                      'assets/icons/romak-logo-blue.png',
                      color: Colors.blue,
                      colorBlendMode: BlendMode.srcATop, // Blend mode
                    ),
                    // backgroundImage: AssetImage(
                    //   'assets/icons/romak-logo-blue.png',
                    // ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'پنل شوکا',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'نسخه 1.0.0',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            //
            // Drawer Items
            //
            Expanded(
              child: ListView(
                children: tabsList.map<Widget>((tab) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ContainerButton(
                      color: routeName == tab["href"]
                          ? Theme.of(context).primaryColor
                          : null,
                      borderRadius: 10,
                      padding: EdgeInsets.all(17),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(
                          context,
                        ).pushReplacementNamed(tab["href"] as String);
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 5,
                        children: [
                          Icon(tab["icon"] as IconData, size: 22),
                          Text(
                            tab["label"] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: routeName == tab["href"]
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
