import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/utils/textfields/outline_textfield_with_label.dart';

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
        //
        // List of TextFields
        //
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
                  controllerList[index]["controller"] as TextEditingController,
              placeHolder: controllerList[index]["placeholder"] as String,
            ),
          ),
        ),

        //
        // Buttons
        //
        ModalBottomButtons(
          saveText: "ثبت تغییرات",
          onSave: () => print("edit prof save"),
        ),
      ],
    );
  }
}
