import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/device%20list/components/map.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/services/multiple_image_service.dart';
import 'package:shooka_flutter/utils/buttons/my_icon_button.dart';
import 'package:shooka_flutter/utils/dropdowns/dropdown_with_label.dart';
import 'package:shooka_flutter/utils/dropdowns/dropdownitem.dart';
import 'package:shooka_flutter/utils/textfields/outline_textfield_with_label.dart';
import 'package:shooka_flutter/utils/toastifications/toasts.dart';

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
  String? latLong;
  // Holds base64-encoded images selected by the user
  List<String> base64Images = [];

  // Dropdown Initial values
  String? orgInitialValue;
  // String? installerInitialValue;
  String? featureInitialValue;
  String? provinceInitialValue;

  @override
  Widget build(BuildContext context) {
    final generalProvider = context.watch<GeneralProvider>();
    final deviceProvider = context.watch<DeviceProvider>();

    final textfieldList = [
      {"label": "نام موتورخانه*", "controller": _nameController},
      {
        "label": "شماره سریال موتورخانه*",
        "controller": _serialNumberController,
      },
      {"label": "آدرس*", "controller": locationController},
    ];

    final dropdownList = [
      {
        "label": "نام سازمان*",
        "initialValue": orgInitialValue,
        "items": (generalProvider.filters?["organizations"] ?? [])
            .map<DropdownMenuItem<String>>(
              (org) => myDropDownItem(
                value: org["id"].toString(),
                label: org["organization"].toString(),
              ),
            )
            .toList(),
      },
      {
        "label": "ویژگی موتورخانه*",
        "initialValue": featureInitialValue,
        "items": (generalProvider.filters?["features"] ?? [])
            .map<DropdownMenuItem<String>>(
              (feature) => myDropDownItem(
                value: feature["main_3d_view"].toString(),
                label: feature["main_3d_view"].toString(),
              ),
            )
            .toList(),
      },
      {
        "label": "شهر و استان*",
        "initialValue": provinceInitialValue,
        "items": (generalProvider.filters?["locations"] ?? [])
            .map<DropdownMenuItem<String>>(
              (loc) => myDropDownItem(
                value: loc["id"].toString(),
                label: "${loc["location"][0]} - ${loc["location"][1]}",
              ),
            )
            .toList(),
      },
      // {
      //   "label": "نصاب",
      //   "initialValue": installerInitialValue,
      //   "items": (generalProvider.filters?["installers"] ?? [])
      //       .map<DropdownMenuItem<String>>(
      //         (installer) => myDropDownItem(
      //           value: installer["id"].toString(),
      //           label: installer["installer"],
      //         ),
      //       )
      //       .toList(),
      // },
    ];

    return BottomModalTemplate(
      title: "افزودن موتورخانه",
      isLongList: true,
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
                  textfieldList[index]["controller"] as TextEditingController,
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
              iconOnPressed: () => setState(() {
                final label = dropdownList[index]["label"] as String;
                if (label == "نام سازمان*") orgInitialValue = null;
                if (label == "ویژگی موتورخانه*") {
                  featureInitialValue = null;
                }
                if (label == "شهر و استان*") provinceInitialValue = null;
              }),
              onChanged: (value) => setState(() {
                final label = dropdownList[index]["label"] as String;
                if (label == "نام سازمان*") {
                  orgInitialValue = value;
                } else if (label == "ویژگی موتورخانه*") {
                  featureInitialValue = value;
                } else if (label == "شهر و استان*") {
                  provinceInitialValue = value;
                }
              }),
              initialValue: dropdownList[index]["initialValue"] as String?,
              label: dropdownList[index]["label"] as String,
              items:
                  dropdownList[index]["items"]
                      as List<DropdownMenuItem<String>>,
              placeholder: "${dropdownList[index]["label"]}",
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            spacing: 10,
            children: [
              Text("مختصات: "),
              if (latLong != null)
                Expanded(
                  child: Text(
                    latLong!,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.apply(color: Colors.white),
                  ),
                ),
              MyIconButton(
                onPressed: () async {
                  final result = await showMaterialModalBottomSheet<LatLng>(
                    context: context,
                    enableDrag: false,
                    builder: (context) => const MapPickerModal(),
                  );

                  if (result != null) {
                    print('Selected: ${result.latitude}, ${result.longitude}');
                    setState(() {
                      latLong = "${result.latitude}, ${result.longitude}";
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
                      Icons.map,
                      size: 15,
                      color: Theme.of(context).hintColor,
                    ),
                    if (latLong == null)
                      Text(
                        "انتخاب مختصات",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            spacing: 10,
            children: [
              Text("تصاویر موتورخانه: "),
              if (base64Images.isNotEmpty)
                Expanded(
                  child: Text(
                    "${base64Images.length} تصویر انتخاب شد.",
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.apply(color: Colors.white),
                  ),
                ),
              Row(
                spacing: 5,
                children: [
                  if (base64Images.isNotEmpty)
                    MyIconButton(
                      onPressed: () async {
                        setState(() {
                          base64Images.clear();
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
                    onPressed: () async {
                      // pick multiple images and store as base64 strings
                      final imageService = ImageService();
                      final images = await imageService.pickMultipleImages();
                      if (images.isNotEmpty) {
                        setState(() {
                          base64Images = images;
                        });
                      }
                      log(base64Images.length.toString());
                    },
                    border: Border.all(color: Colors.grey.shade700),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Row(
                      spacing: 5,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_camera_back_outlined,
                          size: 15,
                          color: Theme.of(context).hintColor,
                        ),
                        if (base64Images.isEmpty)
                          Text(
                            "انتخاب تصاویر",
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
          loading: deviceProvider.addLoading,
          saveText: "افزودن دستگاه",
          onSave: () async {
            if (_nameController.text == "" ||
                _serialNumberController.text == "" ||
                locationController.text == "" ||
                orgInitialValue == null ||
                featureInitialValue == null ||
                provinceInitialValue == null) {
              flatErrorToast(title: "لطفا همه ی اطلاعات را وارد کنید.");
            } else if (!RegExp(
              r'^[0-9A-F]{4}\.[0-9A-F]{4}\.[0-9A-F]{4}\.[0-9A-F]{4}$',
            ).hasMatch(_serialNumberController.text)) {
              flatErrorToast(
                title: "فرمت شماره سریال اشتباه است.",
                description: "مثال: 1111.2222.AAAA.FFFF",
              );
            } else {
              final status = await deviceProvider.addDevice(
                name: _nameController.text,
                serialNumber: _serialNumberController.text,
                installationAddress: locationController.text,
                engineRoomFeature: featureInitialValue!,
                location: int.tryParse(provinceInitialValue!)!,
                organization: int.tryParse(orgInitialValue!)!,
                latLong: latLong,
                images: base64Images,
              );

              if (status >= 200 && status < 300) {
                filledSuccessToast(title: "دستگاه با موفقیت اضافه شد");
                Navigator.pop(context);
              } else if (status == 409) {
                flatErrorToast(title: "نام یا سریال دستگاه از قبل وجود دارد.");
              } else {
                flatErrorToast(title: "خطایی رخ داد.");
              }
            }
          },
        ),
      ],
    );
  }
}
