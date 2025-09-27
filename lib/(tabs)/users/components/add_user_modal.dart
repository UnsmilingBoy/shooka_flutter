import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/utils/dropdowns/dropdown_with_label.dart';
import 'package:shooka_flutter/utils/textfields/outline_textfield_with_label.dart';

class AddUserModal extends StatefulWidget {
  final bool? editMode;
  final String? imageHref;
  final String? userName;
  final String? password;
  final String? repeatPassword;
  final String? role;
  final String? email;
  final String? phoneNumber;
  final String? name;
  const AddUserModal({
    super.key,
    this.editMode,
    this.imageHref,
    this.userName,
    this.password,
    this.repeatPassword,
    this.role,
    this.email,
    this.phoneNumber,
    this.name,
  });

  @override
  State<AddUserModal> createState() => _AddUserModalState();
}

class _AddUserModalState extends State<AddUserModal> {
  //
  // Controllers
  //
  TextEditingController nameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController repeatPasswordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  String? selectedRole;

  //
  // InitState for edit mode
  //
  @override
  void initState() {
    if (widget.editMode == true) {
      userNameController.text = widget.userName ?? "";
      passwordController.text = widget.password ?? "";
      repeatPasswordController.text = widget.repeatPassword ?? "";
      emailController.text = widget.email ?? "";
      phoneNumberController.text = widget.phoneNumber ?? "";
      nameController.text = widget.name ?? "";
      selectedRole = widget.role;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controllerList = [
      {
        "controller": userNameController,
        "label": "نام و نام خانوادگی:",
        "placeholder": "نام و نام خانوادگی",
      },
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
      {
        "controller": emailController,
        "label": "ایمیل:",
        "placeholder": "ایمیل",
      },
      {
        "controller": phoneNumberController,
        "label": "شماره همراه:",
        "placeholder": "شماره همراه",
      },
    ];

    //
    //Body
    //
    return BottomModalTemplate(
      title: widget.editMode == true ? "ویرایش کاربر" : "کاربر جدید",
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
              isPassword: (controllerList[index]["label"] as String).contains(
                "رمزعبور",
              ),
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

        //
        // Buttons
        //
        ModalBottomButtons(
          saveText: widget.editMode == true ? "ویرایش کاربر" : "افزودن کاربر",
          onSave: () => print("add user"),
        ),
      ],
    );
  }
}
