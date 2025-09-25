import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';
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

              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(0),
                itemCount: textfieldList.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: DropdownWithLabel(
                    label: dropdownList[index]["label"] as String,
                    items: [],
                    placeholder: "${dropdownList[index]["label"]}",
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
          ),
        ),
      ],
    );
  }
}
