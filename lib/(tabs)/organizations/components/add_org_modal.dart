import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';
import 'package:shooka_flutter/utils/textfields/outline_textfield_with_label.dart';

class AddOrgModal extends StatelessWidget {
  const AddOrgModal({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController orgName = TextEditingController();
    TextEditingController orgParent = TextEditingController();

    final controllerList = [
      {
        "controller": orgName,
        "label": "نام سازمان:",
        "placeholder": "نام سازمان",
      },
      {"controller": orgParent, "label": "نهاد:", "placeholder": "نهاد"},
    ];

    //
    //Body
    //

    return BottomModalTemplate(
      title: "سازمان جدید",
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
                  controllerList[index]["controller"] as TextEditingController,
              placeHolder: controllerList[index]["placeholder"] as String,
            ),
          ),
        ),

        SizedBox(height: 15),
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
    );
  }
}
