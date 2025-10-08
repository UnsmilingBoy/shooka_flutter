import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/utils/dropdowns/dropdown_with_label.dart';
import 'package:shooka_flutter/utils/textfields/outline_textfield_with_label.dart';

class AddDeviceModal extends StatefulWidget {
  const AddDeviceModal({super.key});

  @override
  State<AddDeviceModal> createState() => _AddDeviceModalState();
}

class _AddDeviceModalState extends State<AddDeviceModal> {
  // TextFields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _serialNumberController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  // Dropdown Initial values
  String? orgInitialValue;
  String? installerInitialValue;
  String? parentInitialValue;
  String? provinceInitialValue;

  @override
  Widget build(BuildContext context) {
    final generalProvider = context.watch<GeneralProvider>();

    final textfieldList = [
      {"label": "نام موتورخانه", "controller": _nameController},
      {"label": "شماره سریال موتورخانه", "controller": _serialNumberController},
      {"label": "آدرس", "controller": locationController},
    ];

    final dropdownList = [
      {
        "label": "نام سازمان",
        "items": (generalProvider.filters?["installers"] ?? [])
            .map<DropdownMenuItem<String>>(
              (installer) => DropdownMenuItem<String>(
                value: installer["id"].toString(),
                alignment: AlignmentDirectional.centerEnd,
                child: Text(installer["installer"].toString()),
              ),
            )
            .toList(),
      },
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
