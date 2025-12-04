import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/models/device_filter_state.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/utils/buttons/my_icon_button.dart';
import 'package:shooka_flutter/utils/datepickers/my_range_picker.dart';
import 'package:shooka_flutter/utils/dropdowns/searchable_dropdown_with_label.dart';

class FilterDeviceModal extends StatefulWidget {
  final DeviceListMode mode;

  const FilterDeviceModal({super.key, this.mode = DeviceListMode.all});

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
  String? planInitialValue;
  String? date;
  String? startDate;
  String? endDate;

  @override
  void initState() {
    super.initState();
    final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
    final filterState = deviceProvider.getFilterState(widget.mode);

    // Use filter state from the current mode
    orgInitialValue = filterState.selectedOrg;
    installerInitialValue = filterState.selectedInstaller?.toString();
    parentInitialValue = filterState.selectedAdmin;
    provinceInitialValue = filterState.selectedProvince;
    cityInitialValue = filterState.selectedCity;
    planInitialValue = filterState.selectedPlan;
    startDate = filterState.startDate;
    endDate = filterState.endDate;

    // Reconstruct date display string if dates are saved
    if (startDate != null && endDate != null) {
      try {
        // Parse the compact date format (YYYY-MM-DD) with dashes
        final startParts = startDate!.split('/');
        final endParts = endDate!.split('/');

        final start = Jalali(
          int.parse(startParts[0]),
          int.parse(startParts[1]),
          int.parse(startParts[2]),
        );
        final end = Jalali(
          int.parse(endParts[0]),
          int.parse(endParts[1]),
          int.parse(endParts[2]),
        );

        date = "${start.formatFullDate()} تا ${end.formatFullDate()}";
      } catch (e) {
        log("Error parsing saved dates: $e");
        date = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final generalProvider = context.watch<GeneralProvider>();
    final deviceProvider = context.watch<DeviceProvider>();

    final filterOptions = [
      {
        "label": "نصاب",
        "items": (generalProvider.filters?["installers"] ?? [])
            .map<DropdownItemModel>(
              (installer) => DropdownItemModel(
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
            .map<DropdownItemModel>(
              (organization) => DropdownItemModel(
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
            .map<DropdownItemModel>(
              (administration) => DropdownItemModel(
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
            .map<DropdownItemModel>(
              (province) => DropdownItemModel(value: province, label: province),
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
            .map<DropdownItemModel>(
              (city) => DropdownItemModel(value: city, label: city),
            )
            .toList(),
        "initialValue": cityInitialValue,
      },
      {
        "label": "پلن",
        "items": [
          DropdownItemModel(value: "free", label: "آزاد"),
          DropdownItemModel(
            value: "optimized",
            label: "طرح بهینه سازی شرکت گاز",
          ),
        ],
        "initialValue": planInitialValue,
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
          itemBuilder: (context, index) => SearchableDropdownWithLabel(
            iconOnPressed: () => setState(() {
              final label = filterOptions[index]["label"] as String;
              if (label == "نصاب") installerInitialValue = null;
              if (label == "سازمان") orgInitialValue = null;
              if (label == "وزارت‌خانه") parentInitialValue = null;
              if (label == "استان") provinceInitialValue = null;
              if (label == "شهر") cityInitialValue = null;
              if (label == "پلن") planInitialValue = null;
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
              } else if (label == "پلن") {
                planInitialValue = value;
              }
            }),
            items: filterOptions[index]["items"] as List<DropdownItemModel>,
            label: filterOptions[index]["label"] as String,
            placeholder: "انتخاب کنید",
            initialValue: filterOptions[index]["initialValue"] as String?,
          ),
        ),

        //
        // Date range picker
        //
        Padding(
          padding: const EdgeInsets.only(top: 5.0, bottom: 10),
          child: Row(
            spacing: 10,
            children: [
              Text("بازه زمانی نصب:"),
              if (date != null)
                Expanded(
                  child: Text(
                    date.toString(),
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.apply(color: Colors.white),
                  ),
                ),
              Row(
                spacing: 5,
                children: [
                  if (date != null)
                    MyIconButton(
                      onPressed: () {
                        setState(() {
                          date = null;
                          startDate = null;
                          endDate = null;
                        });
                      },
                      border: Border.all(color: Colors.grey.shade700),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: Icon(
                        Icons.clear,
                        size: 15,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  MyIconButton(
                    //
                    // Date Range Picker
                    //
                    onPressed: () async {
                      var picked = await myRangePicker(context);

                      if (picked != null) {
                        setState(() {
                          startDate = picked.start.formatCompactDate();
                          endDate = picked.end.formatCompactDate();
                          date =
                              "${picked.start.formatFullDate()} تا ${picked.end.formatFullDate()}";
                        });
                      }
                    },
                    border: Border.all(color: Colors.grey.shade700),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Row(
                      spacing: 5,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.date_range_rounded,
                          size: 15,
                          color: Theme.of(context).hintColor,
                        ),
                        if (date == null)
                          Text(
                            "انتخاب بازه",
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        //
        // Buttons
        //
        ModalBottomButtons(
          saveText: "فیلتر",
          onSave: () {
            log("installer is: $installerInitialValue");
            final filterState = deviceProvider.getFilterState(widget.mode);

            deviceProvider.loadDevicesForMode(
              mode: widget.mode,
              all: false,
              page: 1,
              search: filterState.searchedText,
              installer: installerInitialValue != null
                  ? int.tryParse(installerInitialValue ?? "-1")
                  : null,
              administration: parentInitialValue,
              city: cityInitialValue,
              organization: orgInitialValue,
              province: provinceInitialValue,
              plan: planInitialValue,
              start: startDate,
              end: endDate,
            );

            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
