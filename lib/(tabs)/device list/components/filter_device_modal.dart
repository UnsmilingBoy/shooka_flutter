import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/utils/dropdowns/dropdown_with_label.dart';

class FilterDeviceModal extends StatefulWidget {
  const FilterDeviceModal({super.key});

  @override
  State<FilterDeviceModal> createState() => _FilterDeviceModalState();
}

class _FilterDeviceModalState extends State<FilterDeviceModal> {
  @override
  Widget build(BuildContext context) {
    // Dropdown Initial values
    String? orgInitialValue;
    String? installerInitialValue;
    String? parentInitialValue;
    String? provinceInitialValue;
    String? cityInitialValue;

    final filterOptions = [
      {
        "label": "نصاب",
        "items": [
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
        "initialValue": installerInitialValue,
      },
      {
        "label": "سازمان",
        "items": [
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
        "initialValue": orgInitialValue,
      },
      {
        "label": "وزارت‌خانه",
        "items": [
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
        "initialValue": parentInitialValue,
      },
      {
        "label": "استان",
        "items": [
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
        "initialValue": provinceInitialValue,
      },
      {
        "label": "شهر",
        "items": [
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
        "initialValue": cityInitialValue,
      },
    ];

    //
    // Body
    //
    return BottomModalTemplate(
      title: "فیلتر موتورخانه ها",
      children: [
        //
        // Filter options
        //
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(0),
          itemCount: filterOptions.length,
          itemBuilder: (context, index) => DropdownWithLabel(
            onChanged: (value) => setState(() {
              filterOptions[index]["initialValue"] = value;
            }),
            items:
                filterOptions[index]["items"] as List<DropdownMenuItem<String>>,
            label: filterOptions[index]["label"] as String,
            placeholder: "انتخاب کنید",
            initialValue: filterOptions[index]["initialValue"] as String?,
          ),
        ),

        //
        // Buttons
        //
        ModalBottomButtons(
          saveText: "فیلتر",
          onSave: () => print("device filter"),
        ),
      ],
    );
  }
}
