import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';
import 'package:shooka_flutter/utils/dropdowns/dropdown_with_label.dart';
import 'package:shooka_flutter/utils/textfields/outline_textfield_with_label.dart';

class AddUserModal extends StatefulWidget {
  const AddUserModal({super.key});

  @override
  State<AddUserModal> createState() => _AddUserModalState();
}

class _AddUserModalState extends State<AddUserModal> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController repeatPasswordController = TextEditingController();

  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    final controllerList = [
      {
        "controller": userNameController,
        "label": "نام کاربری:",
        "placeholder": "نام کاربری",
      },
      {
        "controller": passwordController,
        "label": "رمزعبور:",
        "placeholder": "رمزعبور",
      },
      {
        "controller": repeatPasswordController,
        "label": "تکرار رمزعبور:",
        "placeholder": "تکرار رمزعبور",
      },
    ];

    //
    //Body
    //
    return BottomModalTemplate(
      title: "کاربر جدید",
      children: [
        //
        //  Profile Picture
        //
        Stack(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage("assets/images/black_profile.webp"),
              radius: 50,
            ),
            Positioned(
              bottom: 2,
              left: 4,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  border: BoxBorder.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                child: Icon(Icons.edit, size: 15),
              ),
            ),
          ],
        ),

        //
        // List of users
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
        // Dropdown for role
        //
        DropdownWithLabel(
          placeholder: "انتخاب نقش",
          label: "نقش کاربر:",
          initialValue: selectedRole,
          items: [
            DropdownMenuItem(
              value: "سرپرست",
              alignment: AlignmentDirectional.centerEnd,
              child: Text("سرپرست"),
            ),
            DropdownMenuItem(
              value: "نصاب",
              alignment: AlignmentDirectional.centerEnd,
              child: Text("نصاب"),
            ),
          ],
          onChanged: (value) {
            setState(() {
              selectedRole = value;
            });
          },
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
