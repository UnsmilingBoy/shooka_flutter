import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/providers/event_provider.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/utils/dropdowns/dropdown_with_label.dart';
import 'package:shooka_flutter/utils/dropdowns/dropdownitem.dart';
import 'package:shooka_flutter/utils/switches/my_switch.dart';
import 'package:shooka_flutter/utils/textfields/outline_textformfield.dart';
import 'package:shooka_flutter/utils/toastifications/toasts.dart';

class AddEventModal extends StatefulWidget {
  const AddEventModal({super.key});

  @override
  State<AddEventModal> createState() => _AddEventModalState();
}

class _AddEventModalState extends State<AddEventModal> {
  // List of prompts with controller and switch state
  final List<Map<String, dynamic>> addEventPrompts = [];

  String? selectedDevice;
  String? selectedEventTitle;

  @override
  void initState() {
    super.initState();
    // Load event categories from GeneralProvider in initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final generalProvider = context.read<GeneralProvider>();
      final eventCategories = generalProvider.filters?["event_category"] ?? [];

      setState(() {
        addEventPrompts.clear();
        for (var category in eventCategories) {
          addEventPrompts.add({
            "label": category["name"].toString(),
            "controller": TextEditingController(),
            "switchValue": false,
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final generalProvider = context.watch<GeneralProvider>();
    final eventProvider = context.watch<EventProvider>();

    return BottomModalTemplate(
      title: "رویداد جدید",
      isLongList: true,
      children: [
        DropdownWithLabel(
          initialValue: selectedDevice,
          iconOnPressed: () => setState(() {
            selectedDevice = null;
          }),
          items: generalProvider.filters?["devices"]
              .map<DropdownMenuItem<String>>(
                (device) => myDropDownItem(
                  value: device["name"].toString(), // ensure it's a String
                  label: device["name"].toString(),
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
          iconOnPressed: () => setState(() {
            selectedEventTitle = null;
          }),
          onChanged: (value) {
            setState(() {
              selectedEventTitle = value;
            });
          },
          items: generalProvider.filters?["event_title"]
              .map<DropdownMenuItem<String>>(
                (eventTitle) => myDropDownItem(
                  value: eventTitle, // ensure it's a String
                  label: eventTitle,
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
                addEventPrompts[index]["controller"] as TextEditingController,
            switchValue: addEventPrompts[index]["switchValue"] as bool,
            onSwitchChanged: (value) {
              setState(() {
                addEventPrompts[index]["switchValue"] = value;
              });
            },
          ),
        ),

        //
        // Buttons
        //
        ModalBottomButtons(
          saveText: "افزودن گزارش",
          loading: eventProvider.addLoading,
          onSave: () async {
            // Checking if atleast one of the switches is selected.
            final allFalse = addEventPrompts.every(
              (item) => item["switchValue"] == false,
            );

            // Ensure every required parameter is selected and provided.
            if (selectedDevice == null) {
              flatErrorToast(title: "موتورخانه ای انتخاب نشده است.");
            } else if (selectedEventTitle == null) {
              flatErrorToast(title: "عنوانی انتخاب نشده است.");
            } else if (allFalse) {
              flatErrorToast(
                title: "حداقل یکی از گزینه های گزارش را انتخاب کنید.",
              );
            } else {
              //
              // Reading and adding events
              //
              List eventsList = [];
              for (var event in addEventPrompts) {
                if (event["switchValue"] == true) {
                  eventsList.add({
                    "category": event["label"],
                    "is_checked": true,
                    "text": event["controller"].text,
                  });
                }
              }

              final status = await eventProvider.addEvent(
                device: selectedDevice ?? "",
                title: selectedEventTitle ?? "",
                events: eventsList,
              );

              if (status >= 200 && status < 300) {
                filledSuccessToast(title: 'رویداد با موفقیت اضافه شد.');
              } else {
                filledErrorToast(
                  title: 'خطایی در اضافه کردن رویداد رخ داده است.',
                );
              }
              Navigator.pop(context);
            }
          },
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
  final ValueChanged<bool> onSwitchChanged;
  const AddEventPromptTiles({
    super.key,
    required this.label,
    required this.controller,
    required this.switchValue,
    required this.onSwitchChanged,
  });

  @override
  State<AddEventPromptTiles> createState() => _AddEventPromptTilesState();
}

class _AddEventPromptTilesState extends State<AddEventPromptTiles> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Label and Switch Row
        Row(
          children: [
            Expanded(child: Text(widget.label)),
            MySwitch(
              switchValue: widget.switchValue,
              onChanged: widget.onSwitchChanged,
            ),
          ],
        ),
        // Textformfield if switch is ON
        if (widget.switchValue)
          OutlineTextformfield(
            controller: widget.controller,
            placeholder: "توضیحات...",
          ),
      ],
    );
  }
}
