import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/image_service.dart';
import 'package:shooka_flutter/services/providers/user_provider.dart';
import 'package:shooka_flutter/utils/textfields/outline_textfield_with_label.dart';

class EditProfileModal extends StatefulWidget {
  final String name;
  final String username;
  final String email;
  final String profileHref;
  final String phoneNumber;
  const EditProfileModal({
    super.key,
    required this.name,
    required this.username,
    required this.email,
    required this.profileHref,
    required this.phoneNumber,
  });

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  //
  // Controllers
  //
  TextEditingController name = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController email = TextEditingController();

  //
  // Get Image
  //
  String? _base64Image;
  final _imageService = ImageService();

  Future<void> _pickImage() async {
    final base64 = await _imageService.pickAndConvertToBase64();
    if (base64 != null) {
      setState(() => _base64Image = base64);
    }
  }

  //
  // InitState
  //
  @override
  void initState() {
    name.text = widget.name;
    phoneNumber.text = widget.phoneNumber;
    email.text = widget.email;
    username.text = widget.username;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    final controllerList = [
      {
        "controller": name,
        "label": "نام و نام خانوادگی:",
        "placeholder": "نام",
      },
      {
        "controller": username,
        "label": "نام کاربری:",
        "placeholder": "نام کاربری",
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
        // Picture
        //
        GestureDetector(
          onTap: () => _pickImage(),
          child: Stack(
            children: [
              CircleAvatar(
                backgroundImage: _base64Image != null
                    ? MemoryImage(base64Decode(_base64Image!))
                    : NetworkImage(widget.profileHref),
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
        ),

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
          loading: userProvider.updateUserLoading,
          saveText: "ثبت تغییرات",
          onSave: () async {
            await userProvider.updateUserProfile(
              name: name.text,
              username: username.text,
              email: email.text,
              phoneNumber: phoneNumber.text,
              profilePic: _base64Image,
            );
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
