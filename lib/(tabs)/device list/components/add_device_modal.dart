import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/device%20list/components/map.dart';
import 'package:shooka_flutter/(tabs)/device%20list/components/safety_parameter_tile.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/services/multiple_image_service.dart';
import 'package:shooka_flutter/utils/buttons/my_icon_button.dart';
import 'package:shooka_flutter/utils/dropdowns/searchable_dropdown_with_label.dart';
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
  String? planInitialValue;

  // Safety Parameters - dynamically managed based on checklist from API
  Map<int, String?> safetyParameterValues = {};
  Map<int, TextEditingController> safetyParameterNotes = {};

  @override
  void dispose() {
    _nameController.dispose();
    _serialNumberController.dispose();
    locationController.dispose();
    // Dispose all safety parameter note controllers
    for (var controller in safetyParameterNotes.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Helper method to check if all checklist items are filled
  bool _hasIncompleteChecklist(GeneralProvider generalProvider) {
    if (generalProvider.filters?["checklist"] == null) return false;

    final checklist = generalProvider.filters!["checklist"] as List;
    for (var item in checklist) {
      final id = item["id"] as int;
      if (!safetyParameterValues.containsKey(id) ||
          safetyParameterValues[id] == null) {
        return true;
      }
    }
    return false;
  }

  // Helper method to check if any rejected parameter lacks a note
  bool _hasRejectedWithoutNote() {
    for (var entry in safetyParameterValues.entries) {
      if (entry.value == 'rejected') {
        final noteController = safetyParameterNotes[entry.key];
        if (noteController == null || noteController.text.isEmpty) {
          return true;
        }
      }
    }
    return false;
  }

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
            .map<DropdownItemModel>(
              (org) => DropdownItemModel(
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
            .map<DropdownItemModel>(
              (feature) => DropdownItemModel(
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
            .map<DropdownItemModel>(
              (loc) => DropdownItemModel(
                value: loc["id"].toString(),
                label: "${loc["location"][0]} - ${loc["location"][1]}",
              ),
            )
            .toList(),
      },
      {
        "label": "پلن*",
        "initialValue": planInitialValue,
        "items": [
          DropdownItemModel(value: "free", label: "آزاد"),
          DropdownItemModel(
            value: "optimized",
            label: "طرح بهینه سازی شرکت گاز",
          ),
        ],
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
              isSerialNumber:
                  textfieldList[index]["controller"] == _serialNumberController,
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
          itemBuilder: (context, index) => SearchableDropdownWithLabel(
            iconOnPressed: () => setState(() {
              final label = dropdownList[index]["label"] as String;
              if (label == "نام سازمان*") orgInitialValue = null;
              if (label == "ویژگی موتورخانه*") {
                featureInitialValue = null;
              }
              if (label == "شهر و استان*") provinceInitialValue = null;
              if (label == "پلن*") planInitialValue = null;
            }),
            onChanged: (value) => setState(() {
              final label = dropdownList[index]["label"] as String;
              if (label == "نام سازمان*") {
                orgInitialValue = value;
              } else if (label == "ویژگی موتورخانه*") {
                featureInitialValue = value;
              } else if (label == "شهر و استان*") {
                provinceInitialValue = value;
              } else if (label == "پلن*") {
                planInitialValue = value;
              }
            }),
            initialValue: dropdownList[index]["initialValue"] as String?,
            label: dropdownList[index]["label"] as String,
            items: dropdownList[index]["items"] as List<DropdownItemModel>,
            placeholder: "انتخاب کنید",
          ),
        ),

        //
        // Preview of selected engine room feature
        //
        if (featureInitialValue != null)
          Builder(
            builder: (context) {
              // Find the selected feature to get the image URL
              final selectedFeature =
                  (generalProvider.filters?["features"] ?? []).firstWhere(
                    (f) => f["main_3d_view"] == featureInitialValue,
                    orElse: () => null,
                  );

              final imageUrl = selectedFeature?["main_3d_view_url"];

              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade700),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "پیش نمایش:",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      SizedBox(height: 8),
                      if (imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: double.infinity,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Container(
                              padding: EdgeInsets.all(20),
                              color: Colors.grey.shade800,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) {
                              return Container(
                                padding: EdgeInsets.all(20),
                                color: Colors.grey.shade800,
                                child: Center(
                                  child: Text(
                                    "تصویر در دسترس نیست",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelSmall,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Container(
                          padding: EdgeInsets.all(20),
                          color: Colors.grey.shade800,
                          child: Center(
                            child: Text(
                              "تصویر در دسترس نیست",
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

        // Safety Parameters Section - dynamically generated from checklist
        if (generalProvider.filters?["checklist"] != null)
          ...List.generate(
            (generalProvider.filters!["checklist"] as List).length,
            (index) {
              final checklistItem =
                  (generalProvider.filters!["checklist"] as List)[index];
              final id = checklistItem["id"] as int;

              // Initialize controller if not exists
              if (!safetyParameterNotes.containsKey(id)) {
                safetyParameterNotes[id] = TextEditingController();
              }

              return SafetyParameterTile(
                label: checklistItem["label"] ?? "",
                description: checklistItem["description"] ?? "",
                selectedValue: safetyParameterValues[id],
                rejectionNoteController: safetyParameterNotes[id],
                onChanged: (value) => setState(() {
                  safetyParameterValues[id] = value;
                  if (value != 'rejected') {
                    safetyParameterNotes[id]?.clear();
                  }
                }),
              );
            },
          ),

        SizedBox(height: 10),

        //
        // LatLong Picker
        //
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
                    if (kDebugMode) {
                      print(
                        'Selected: ${result.latitude}, ${result.longitude}',
                      );
                    }
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

        //
        // Image Picker
        //
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
                provinceInitialValue == null ||
                planInitialValue == null) {
              flatErrorToast(title: "لطفا همه ی اطلاعات را وارد کنید.");
            } else if (!RegExp(
              r'^[0-9A-Fa-f]{4}\.[0-9A-Fa-f]{4}\.[0-9A-Fa-f]{4}\.[0-9A-Fa-f]{4}$',
            ).hasMatch(_serialNumberController.text)) {
              flatErrorToast(
                title: "فرمت شماره سریال اشتباه است.",
                description: "مثال: 1111.2222.AAAA.FFFF",
              );
            } else if (_hasIncompleteChecklist(generalProvider)) {
              flatErrorToast(
                title: "لطفا همه پارامترهای ایمنی را تایید یا رد کنید.",
              );
            } else if (_hasRejectedWithoutNote()) {
              flatErrorToast(
                title: "لطفا برای پارامترهای رد شده، دلیل رد را وارد کنید.",
              );
            } else {
              // Build check_list_items array from the safety parameters
              List<Map<String, dynamic>>? checkListItems;
              if (generalProvider.filters?["checklist"] != null) {
                checkListItems = [];
                final checklist = generalProvider.filters!["checklist"] as List;

                // Ensure all checklist items are filled and valid
                if (checklist.isEmpty) {
                  flatErrorToast(
                    title: "خطا در دریافت چک لیست. لطفا دوباره تلاش کنید.",
                  );
                  return;
                }

                for (var item in checklist) {
                  final id = item["id"] as int;
                  final name = item["name"] as String?;
                  final selectedValue = safetyParameterValues[id];

                  // This should never happen due to validation above, but double-check
                  if (name == null || selectedValue == null) {
                    flatErrorToast(
                      title: "لطفا همه پارامترهای ایمنی را تایید یا رد کنید.",
                    );
                    return;
                  }

                  // For rejected items, ensure note is provided
                  if (selectedValue == 'rejected') {
                    final note = safetyParameterNotes[id]?.text ?? "";
                    if (note.isEmpty) {
                      flatErrorToast(
                        title:
                            "لطفا برای پارامترهای رد شده، دلیل رد را وارد کنید.",
                      );
                      return;
                    }
                  }

                  checkListItems.add({
                    "name": name,
                    "is_approved": selectedValue == 'approved',
                    "note": safetyParameterNotes[id]?.text ?? "",
                  });
                }

                // Final validation: ensure we collected all items
                if (checkListItems.length != checklist.length) {
                  flatErrorToast(
                    title: "لطفا همه پارامترهای ایمنی را تکمیل کنید.",
                  );
                  return;
                }
              }

              final status = await deviceProvider.addDevice(
                name: _nameController.text,
                serialNumber: _serialNumberController.text,
                installationAddress: locationController.text,
                engineRoomFeature: featureInitialValue!,
                location: int.tryParse(provinceInitialValue!)!,
                organization: int.tryParse(orgInitialValue!)!,
                plan: planInitialValue,
                latLong: latLong,
                images: base64Images,
                checkListItems: checkListItems,
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
