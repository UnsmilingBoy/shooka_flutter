import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';
import 'package:shooka_flutter/utils/textfields/OutlineTextfield.dart';

class EditProfileModal extends StatelessWidget {
  const EditProfileModal({super.key});

  @override
  Widget build(BuildContext context) {
    //
    // Controllers
    //
    TextEditingController name = TextEditingController();
    TextEditingController phoneNumber = TextEditingController();
    TextEditingController email = TextEditingController();

    final controllerList = [
      {
        "controller": name,
        "label": "نام و نام خانوادگی:",
        "placeholder": "نام",
      },
      {
        "controller": phoneNumber,
        "label": "شماره همراه:",
        "placeholder": "شماره همراه",
      },
      {"controller": email, "label": "ایمیل:", "placeholder": "ایمیل"},
    ];

    //
    // Body
    //
    return BottomModalTemplate(
      title: "ویرایش حساب کاربری",
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

        //
        // Buttons
        //
        Column(
          spacing: 10,
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
