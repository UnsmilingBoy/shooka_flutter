import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';
import 'package:shooka_flutter/utils/textfields/OutlineTextfield.dart';

class ChangePasswordModal extends StatelessWidget {
  const ChangePasswordModal({super.key});

  @override
  Widget build(BuildContext context) {
    //
    // Controllers
    //
    TextEditingController prevPassword = TextEditingController();
    TextEditingController newPassword = TextEditingController();
    TextEditingController repeatNewPassword = TextEditingController();

    final controllerList = [
      {
        "controller": prevPassword,
        "label": "رمزعبور قبلی:",
        "placeholder": "رمزعبور قبلی",
      },
      {
        "controller": newPassword,
        "label": "رمزعبور جدید:",
        "placeholder": "رمزعبور جدید",
      },
      {
        "controller": repeatNewPassword,
        "label": "تکرار رمزعبور جدید:",
        "placeholder": "تکرار رمزعبور جدید",
      },
    ];

    return BottomModalTemplate(
      title: "تغییر رمز عبور",
      children: [
        Column(
          spacing: 10,
          children: [
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: controllerList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) => Container(
                margin: EdgeInsets.only(bottom: 10),
                child: Column(
                  spacing: 3,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(controllerList[index]["label"] as String),
                    Outlinetextfield(
                      controller:
                          controllerList[index]["controller"]
                              as TextEditingController,
                    ),
                  ],
                ),
              ),
            ),

            //Save button
            ContainerButton(
              color: Theme.of(context).primaryColor,
              fillWidth: true,
              child: Text("ثبت", style: Theme.of(context).textTheme.labelLarge),
              onPressed: () => print("save"),
            ),

            //Close button
            ContainerButton(
              color: Theme.of(context).hintColor,
              fillWidth: true,
              child: Text(
                "بستن",
                style: Theme.of(context).textTheme.labelLarge,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ],
    );
  }
}
