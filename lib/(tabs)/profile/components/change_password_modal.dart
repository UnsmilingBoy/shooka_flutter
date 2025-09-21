import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';
import 'package:shooka_flutter/utils/textfields/outline_textfield_with_label.dart';

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
                child: Outlinetextfieldwithlabel(
                  label: controllerList[index]["label"] as String,
                  controller:
                      controllerList[index]["controller"]
                          as TextEditingController,
                  placeHolder: controllerList[index]["placeholder"] as String,
                ),
              ),
            ),

            //
            // Buttons
            //
            Column(
              spacing: 7,
              children: [
                //Save button
                ContainerButton(
                  color: Theme.of(context).primaryColor,
                  fillWidth: true,
                  child: Text(
                    "ثبت تغییرات",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  onPressed: () => print("save"),
                ),

                //Close button
                ContainerButton(
                  color: Theme.of(context).colorScheme.errorContainer,
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
        ),
      ],
    );
  }
}
