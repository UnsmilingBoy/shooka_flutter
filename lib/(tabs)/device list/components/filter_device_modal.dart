import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/utils/dropdowns/dropdown_with_label.dart';
import 'package:shooka_flutter/utils/dropdowns/dropdownitem.dart';

class FilterDeviceModal extends StatefulWidget {
  const FilterDeviceModal({super.key});

  @override
  State<FilterDeviceModal> createState() => _FilterDeviceModalState();
}

class _FilterDeviceModalState extends State<FilterDeviceModal> {
  // Dropdown Initial values
  String? orgInitialValue;
  String? installerInitialValue;
  String? parentInitialValue;
  String? provinceInitialValue;
  String? cityInitialValue;

  @override
  void initState() {
    super.initState();
    final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
    // Use provider fields for last selected values (if you add them)
    orgInitialValue = deviceProvider.lastSelectedOrg;
    installerInitialValue = deviceProvider.lastSelectedInstaller?.toString();
    parentInitialValue = deviceProvider.lastSelectedAdmin;
    provinceInitialValue = deviceProvider.lastSelectedProvince;
    cityInitialValue = deviceProvider.lastSelectedCity;
  }

  @override
  Widget build(BuildContext context) {
    final generalProvider = context.watch<GeneralProvider>();
    final deviceProvider = context.watch<DeviceProvider>();

    final filterOptions = [
      {
        "label": "نصاب",
        "items": (generalProvider.filters?["installers"] ?? [])
            .map<DropdownMenuItem<String>>(
              (installer) => myDropDownItem(
                value: installer["id"].toString(),
                label: installer["installer"].toString(),
              ),
            )
            .toList(),
        "initialValue": installerInitialValue,
      },
      {
        "label": "سازمان",
        "items": (generalProvider.filters?["organizations"] ?? [])
            .map<DropdownMenuItem<String>>(
              (organization) => myDropDownItem(
                value: organization["organization"].toString(),
                label: organization["organization"].toString(),
              ),
            )
            .toList(),
        "initialValue": orgInitialValue,
      },
      {
        "label": "وزارت‌خانه",
        "items": (generalProvider.filters?["administration"] ?? [])
            .map<DropdownMenuItem<String>>(
              (administration) => myDropDownItem(
                value: administration["administration"].toString(),
                label: administration["administration"].toString(),
              ),
            )
            .toList(),
        "initialValue": parentInitialValue,
      },
      {
        "label": "استان",
        // map to province strings, convert to Set to remove duplicates, then build items
        "items": (generalProvider.filters?["locations"] ?? [])
            .map((location) => location["location"][0].toString())
            .toSet()
            .map<DropdownMenuItem<String>>(
              (province) => myDropDownItem(value: province, label: province),
            )
            .toList(),
        "initialValue": provinceInitialValue,
      },
      {
        "label": "شهر",
        // map to city strings, convert to Set to remove duplicates, then build items
        "items": (generalProvider.filters?["locations"] ?? [])
            .map((location) => location["location"][1].toString())
            .toSet()
            .map<DropdownMenuItem<String>>(
              (city) => myDropDownItem(value: city, label: city),
            )
            .toList(),
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
            iconOnPressed: () => setState(() {
              final label = filterOptions[index]["label"] as String;
              if (label == "نصاب") installerInitialValue = null;
              if (label == "سازمان") orgInitialValue = null;
              if (label == "وزارت‌خانه") parentInitialValue = null;
              if (label == "استان") provinceInitialValue = null;
              if (label == "شهر") cityInitialValue = null;
            }),
            onChanged: (value) => setState(() {
              final label = filterOptions[index]["label"] as String;
              if (label == "نصاب") {
                installerInitialValue = value;
              } else if (label == "سازمان") {
                orgInitialValue = value;
              } else if (label == "وزارت‌خانه") {
                parentInitialValue = value;
              } else if (label == "استان") {
                provinceInitialValue = value;
              } else if (label == "شهر") {
                cityInitialValue = value;
              }
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
          onSave: () {
            log("installer is: $installerInitialValue");

            deviceProvider.loadDevices(
              all: false,
              page: 1,
              search: deviceProvider.lastSearchedText,
              installer: installerInitialValue != null
                  ? int.tryParse(installerInitialValue ?? "-1")
                  : null,
              administration: parentInitialValue,
              city: cityInitialValue,
              organization: orgInitialValue,
              province: provinceInitialValue,
            );

            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
