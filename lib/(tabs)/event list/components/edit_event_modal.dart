import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/models/event_data_class.dart';
import 'package:shooka_flutter/services/providers/event_provider.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/utils/dropdowns/searchable_dropdown_with_label.dart';
import 'package:shooka_flutter/utils/switches/my_switch.dart';
import 'package:shooka_flutter/utils/textfields/outline_textformfield.dart';
import 'package:shooka_flutter/utils/toastifications/toasts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EditEventModal extends StatefulWidget {
  final String deviceName;
  final String title;
  final String timestamp;
  final List<EventCategoryDetails> eventCategoryDetails;

  const EditEventModal({
    super.key,
    required this.deviceName,
    required this.title,
    required this.timestamp,
    required this.eventCategoryDetails,
  });

  @override
  State<EditEventModal> createState() => _EditEventModalState();
}

class _EditEventModalState extends State<EditEventModal> {
  // List of prompts with controller and switch state
  final List<Map<String, dynamic>> editEventPrompts = [];
  final storage = FlutterSecureStorage();

  String? selectedDevice;
  String? selectedEventTitle;

  @override
  void initState() {
    super.initState();
    // Initialize with existing event data
    selectedDevice = widget.deviceName;
    selectedEventTitle = widget.title;

    // Load event categories from GeneralProvider in initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final generalProvider = context.read<GeneralProvider>();
      final eventCategories = generalProvider.filters?["event_category"] ?? [];

      setState(() {
        editEventPrompts.clear();
        for (var category in eventCategories) {
          final categoryName = category["name"].toString();

          // Find if this category exists in the current event
          final existingEvent = widget.eventCategoryDetails.firstWhere(
            (detail) => detail.category == categoryName,
            orElse: () => EventCategoryDetails(
              eventId: 0,
              category: categoryName,
              isChecked: false,
              text: '',
            ),
          );

          editEventPrompts.add({
            "label": categoryName,
            "controller": TextEditingController(text: existingEvent.text),
            "switchValue": existingEvent.isChecked,
            "eventId": existingEvent.eventId,
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
      title: "ویرایش رویداد",
      isLongList: true,
      children: [
        SearchableDropdownWithLabel(
          initialValue: selectedDevice,
          iconOnPressed: () => setState(() {
            selectedDevice = null;
          }),
          items: (generalProvider.filters?["devices"] ?? [])
              .map<DropdownItemModel>(
                (device) => DropdownItemModel(
                  value: device["name"].toString(),
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
        SearchableDropdownWithLabel(
          initialValue: selectedEventTitle,
          iconOnPressed: () => setState(() {
            selectedEventTitle = null;
          }),
          onChanged: (value) {
            setState(() {
              selectedEventTitle = value;
            });
          },
          items: (generalProvider.filters?["event_title"] ?? [])
              .map<DropdownItemModel>(
                (eventTitle) =>
                    DropdownItemModel(value: eventTitle, label: eventTitle),
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
          itemCount: editEventPrompts.length,
          itemBuilder: (context, index) => EditEventPromptTiles(
            label: editEventPrompts[index]["label"] as String,
            controller:
                editEventPrompts[index]["controller"] as TextEditingController,
            switchValue: editEventPrompts[index]["switchValue"] as bool,
            onSwitchChanged: (value) {
              setState(() {
                editEventPrompts[index]["switchValue"] = value;
              });
            },
          ),
        ),

        //
        // Buttons
        //
        ModalBottomButtons(
          saveText: "ویرایش گزارش",
          loading: eventProvider.addLoading,
          onSave: () async {
            // Checking if atleast one of the switches is selected.
            final allFalse = editEventPrompts.every(
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
              for (var event in editEventPrompts) {
                if (event["switchValue"] == true) {
                  eventsList.add({
                    "category": event["label"],
                    "is_checked": true,
                    "text": event["controller"].text,
                    "price": null,
                    "factor_id": null,
                  });
                }
              }

              // Get user ID from storage
              final userIdString = await storage.read(key: 'userId');
              final userId = int.tryParse(userIdString ?? '1') ?? 1;

              final status = await eventProvider.editEvent(
                deviceName: selectedDevice ?? "",
                title: selectedEventTitle ?? "",
                timestamp: widget.timestamp,
                userId: userId,
                events: eventsList,
              );

              if (status >= 200 && status < 300) {
                filledSuccessToast(title: 'رویداد با موفقیت ویرایش شد.');
              } else {
                filledErrorToast(title: 'خطایی در ویرایش رویداد رخ داده است.');
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
//  Edit Event Prompt Tile
//
class EditEventPromptTiles extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool switchValue;
  final ValueChanged<bool> onSwitchChanged;
  const EditEventPromptTiles({
    super.key,
    required this.label,
    required this.controller,
    required this.switchValue,
    required this.onSwitchChanged,
  });

  @override
  State<EditEventPromptTiles> createState() => _EditEventPromptTilesState();
}

class _EditEventPromptTilesState extends State<EditEventPromptTiles> {
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
