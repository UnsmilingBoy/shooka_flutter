import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/containers/mainmenu_container.dart';
import 'package:shooka_flutter/utils/layouts/base_page.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            spacing: 15,
            children: [
              Row(
                children: [
                  Text(
                    "خوش آمدید سپنتا شفیع زاده!",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              // TODO: Brief Device List and Add Device Button
              MainmenuContainer(child: Text("لیست موتورخانه ها")),

              // TODO: Brief Organization List and Add Organization Button
            ],
          ),
        ),
      ),
    );
  }
}
