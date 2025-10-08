import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/utils/dropdowns/dropdown_with_label.dart';

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
              (installer) => DropdownMenuItem<String>(
                value: installer["id"].toString(),
                alignment: AlignmentDirectional.centerEnd,
                child: Text(installer["installer"].toString()),
              ),
            )
            .toList(),
        "initialValue": installerInitialValue,
      },
      {
        "label": "سازمان",
        "items": (generalProvider.filters?["organizations"] ?? [])
            .map<DropdownMenuItem<String>>(
              (organization) => DropdownMenuItem<String>(
                value: organization["organization"].toString(),
                alignment: AlignmentDirectional.centerEnd,
                child: Text(organization["organization"].toString()),
              ),
            )
            .toList(),
        "initialValue": orgInitialValue,
      },
      {
        "label": "وزارت‌خانه",
        "items": (generalProvider.filters?["administration"] ?? [])
            .map<DropdownMenuItem<String>>(
              (administration) => DropdownMenuItem<String>(
                value: administration["administration"].toString(),
                alignment: AlignmentDirectional.centerEnd,
                child: Text(administration["administration"].toString()),
              ),
            )
            .toList(),
        "initialValue": parentInitialValue,
      },
      {
        "label": "استان",
        "items": (generalProvider.filters?["locations"] ?? [])
            .map<DropdownMenuItem<String>>(
              (location) => DropdownMenuItem<String>(
                value: location["location"][0].toString(),
                alignment: AlignmentDirectional.centerEnd,
                child: Text(location["location"][0].toString()),
              ),
            )
            .toList(),
        "initialValue": provinceInitialValue,
      },
      {
        "label": "شهر",
        "items": (generalProvider.filters?["locations"] ?? [])
            .map<DropdownMenuItem<String>>(
              (location) => DropdownMenuItem<String>(
                value: location["location"][1].toString(),
                alignment: AlignmentDirectional.centerEnd,
                child: Text(location["location"][1].toString()),
              ),
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
              all: true,
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
