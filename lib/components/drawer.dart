import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/tabs_list.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    String? routeName = ModalRoute.of(context)?.settings.name ?? "";

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
              margin: const EdgeInsets.only(right: 10, left: 10),
              padding: const EdgeInsets.only(
                left: 5,
                right: 5,
                bottom: 20,
                top: 5,
              ),
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
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'پنل شوکا',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'نسخه 1.0.0',
                        style: Theme.of(context).textTheme.labelSmall,
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
                padding: EdgeInsets.zero,
                children: tabsList.map<Widget>((tab) {
                  final hrefs = (tab["href"] as List<dynamic>?)?.cast<String>();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ContainerButton(
                      color: (hrefs?.contains(routeName) ?? false)
                          ? Theme.of(context).primaryColor
                          : null,
                      borderRadius: 10,
                      padding: EdgeInsets.all(15),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushNamed(hrefs!.first);
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 5,
                        children: [
                          Icon(tab["icon"] as IconData, size: 22),
                          Text(
                            tab["label"] as String,
                            style: Theme.of(context).textTheme.labelLarge,
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
