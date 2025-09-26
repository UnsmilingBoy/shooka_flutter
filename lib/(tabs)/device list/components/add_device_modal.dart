import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/utils/dropdowns/dropdown_with_label.dart';
import 'package:shooka_flutter/utils/textfields/outline_textfield_with_label.dart';

class AddDeviceModal extends StatefulWidget {
  const AddDeviceModal({super.key});

  @override
  State<AddDeviceModal> createState() => _AddDeviceModalState();
}

TextEditingController _nameController = TextEditingController();
TextEditingController _serialNumberController = TextEditingController();
TextEditingController locationController = TextEditingController();

class _AddDeviceModalState extends State<AddDeviceModal> {
  @override
  Widget build(BuildContext context) {
    final textfieldList = [
      {"label": "نام موتورخانه", "controller": _nameController},
      {"label": "شماره سریال موتورخانه", "controller": _serialNumberController},
      {"label": "آدرس", "controller": locationController},
    ];

    final dropdownList = [
      {"label": "نام سازمان", "items": []},
      {"label": "ویژگی موتورخانه", "items": []},
      {"label": "شهر و استان", "items": []},
      {"label": "نصاب", "items": []},
    ];

    return BottomModalTemplate(
      title: "افزودن موتورخانه",
      isLongList: true,
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              //
              // Name and serial number textfields
              //
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(0),
                itemCount: textfieldList.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Outlinetextfieldwithlabel(
                    label: textfieldList[index]["label"] as String,
                    controller:
                        textfieldList[index]["controller"]
                            as TextEditingController,
                    placeHolder: "${textfieldList[index]["label"]}",
                  ),
                ),
              ),

              //
              // Dropdowns
              //
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(0),
                itemCount: dropdownList.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: DropdownWithLabel(
                    label: dropdownList[index]["label"] as String,
                    items: [],
                    placeholder: "${dropdownList[index]["label"]}",
                  ),
                ),
              ),

              //
              // Buttons
              //
              ModalBottomButtons(
                saveText: "افزودن دستگاه",
                onSave: () => print("device added"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
