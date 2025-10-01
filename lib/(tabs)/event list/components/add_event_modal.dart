import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/utils/dropdowns/dropdown_with_label.dart';
import 'package:shooka_flutter/utils/switches/my_switch.dart';
import 'package:shooka_flutter/utils/textfields/outline_textformfield.dart';

class AddEventModal extends StatefulWidget {
  const AddEventModal({super.key});

  @override
  State<AddEventModal> createState() => _AddEventModalState();
}

class _AddEventModalState extends State<AddEventModal> {
  //List of TextEditingControllers
  TextEditingController sensorChangeController = TextEditingController();
  TextEditingController deviceRepairController = TextEditingController();
  TextEditingController wiringIssueController = TextEditingController();
  TextEditingController communicationIssueController = TextEditingController();
  TextEditingController sensorConnectionCheckController =
      TextEditingController();
  TextEditingController sensorRewiringController = TextEditingController();
  TextEditingController generalInspectionController = TextEditingController();

  //List of switches
  bool sensorChangeSwitch = false;
  bool deviceRepairSwitch = false;
  bool wiringIssueSwitch = false;
  bool communicationIssueSwitch = false;
  bool sensorConnectionCheckSwitch = false;
  bool sensorRewiringSwitch = false;
  bool generalInspectionSwitch = false;

  String? selectedDevice;
  String? selectedEventTitle;

  @override
  Widget build(BuildContext context) {
    final generalProvider = context.watch<GeneralProvider>();
    print(generalProvider.filters?["devices"]);
    final addEventPrompts = [
      {
        "label": "تعویض سنسور",
        "controller": sensorChangeController,
        "switchValue": sensorRewiringSwitch,
      },
      {
        "label": "تعمیر دستگاه",
        "controller": deviceRepairController,
        "switchValue": deviceRepairSwitch,
      },
      {
        "label": "برطرف کردن مشکل سیم‌کشی تابلو",
        "controller": wiringIssueController,
        "switchValue": wiringIssueSwitch,
      },
      {
        "label": "برطرف کردن مشکل ارتباطی",
        "controller": communicationIssueController,
        "switchValue": communicationIssueSwitch,
      },
      {
        "label": "چک کردن اتصال سنسور به لوله‌ها",
        "controller": sensorConnectionCheckController,
        "switchValue": sensorConnectionCheckSwitch,
      },
      {
        "label": "سیم‌کشی مجدد سنسور",
        "controller": sensorRewiringController,
        "switchValue": sensorRewiringSwitch,
      },
      {
        "label": "بازدید کلی",
        "controller": generalInspectionController,
        "switchValue": generalInspectionSwitch,
      },
    ];

    return BottomModalTemplate(
      title: "رویداد جدید",
      isLongList: true,
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              //
              // Select Device Dropdown
              //
              DropdownWithLabel(
                initialValue: selectedDevice,
                items: generalProvider.filters?["devices"]
                    .map<DropdownMenuItem<String>>(
                      (device) => DropdownMenuItem<String>(
                        value: device["id"].toString(), // ensure it's a String
                        alignment: AlignmentDirectional.centerEnd,
                        child: Text(device["name"].toString()),
                      ),
                    )
                    .toList(),

                onChanged: (value) {
                  setState(() {
                    selectedDevice = value;
                  });
                },
                label: "موتورخانه",
                placeholder: "انتخاب موتورخانه...",
              ),

              //
              // Select Title Dropdown
              //
              DropdownWithLabel(
                initialValue: selectedEventTitle,
                onChanged: (value) {
                  setState(() {
                    selectedEventTitle = value;
                  });
                },
                items: generalProvider.filters?["event_title"]
                    .map<DropdownMenuItem<String>>(
                      (eventTitle) => DropdownMenuItem<String>(
                        value: eventTitle["id"]
                            .toString(), // ensure it's a String
                        alignment: AlignmentDirectional.centerEnd,
                        child: Text(eventTitle["title"].toString()),
                      ),
                    )
                    .toList(),
                label: "عنوان",
                placeholder: "انتخاب عنوان...",
              ),

              //
              // List of Other prompts
              //
              ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: 5),
                physics: NeverScrollableScrollPhysics(),
                itemCount: addEventPrompts.length,
                itemBuilder: (context, index) => AddEventPromptTiles(
                  label: addEventPrompts[index]["label"] as String,
                  controller:
                      addEventPrompts[index]["controller"]
                          as TextEditingController,
                  switchValue: addEventPrompts[index]["switchValue"] as bool,
                ),
              ),

              //
              // Buttons
              //
              ModalBottomButtons(
                saveText: "افزودن گزارش",
                onSave: () => print("add event"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

//
//  Add Event Prompt Tile
//
class AddEventPromptTiles extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool switchValue;
  const AddEventPromptTiles({
    super.key,
    required this.label,
    required this.controller,
    required this.switchValue,
  });

  @override
  State<AddEventPromptTiles> createState() => _AddEventPromptTilesState();
}

class _AddEventPromptTilesState extends State<AddEventPromptTiles> {
  late bool _switchValue;

  @override
  void initState() {
    super.initState();
    _switchValue = widget.switchValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //
        // Label and Switch Row
        //
        Row(
          children: [
            Expanded(child: Text(widget.label)),
            MySwitch(
              switchValue: _switchValue,
              onChanged: (value) {
                setState(() {
                  _switchValue = value;
                });
              },
            ),
          ],
        ),

        //
        // Textformfield if switch is ON
        //
        if (_switchValue)
          OutlineTextformfield(
            controller: widget.controller,
            placeholder: "توضیحات...",
          ),
      ],
    );
  }
}
