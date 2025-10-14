import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/providers/event_provider.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/utils/buttons/my_icon_button.dart';
import 'package:shooka_flutter/utils/datepickers/my_range_picker.dart';
import 'package:shooka_flutter/utils/dropdowns/dropdown_with_label.dart';
import 'package:shooka_flutter/utils/dropdowns/dropdownitem.dart';

class FilterEventModal extends StatefulWidget {
  const FilterEventModal({super.key});

  @override
  State<FilterEventModal> createState() => _FilterEventModalState();
}

class _FilterEventModalState extends State<FilterEventModal> {
  String? date;
  String? selectedTitle;
  String? selectedCreator;
  String? selectedDevice;
  String? startDate;
  String? endDate;

  @override
  void initState() {
    super.initState();
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    // Use provider fields for last selected values (if you add them)
    selectedCreator = eventProvider.lastSelectedCreator?.toString();
    selectedDevice = eventProvider.lastSelectedDevice?.toString();
    selectedTitle = eventProvider.lastSelectedTitle;
  }

  @override
  Widget build(BuildContext context) {
    final generalProvider = context.watch<GeneralProvider>();
    final eventProvider = context.watch<EventProvider>();

    //
    // Body
    //
    return BottomModalTemplate(
      title: "فیلتر رویداد ها",
      children: [
        //
        // Filter options
        //

        // Title Dropdown
        DropdownWithLabel(
          onChanged: (value) => setState(() {
            selectedTitle = value;
          }),
          iconOnPressed: () => setState(() {
            selectedTitle = null;
          }),
          items: (generalProvider.filters?["event_title"] ?? [])
              .map<DropdownMenuItem<String>>(
                (title) => myDropDownItem(value: title, label: title),
              )
              .toList(),
          label: "عناوین:",
          placeholder: "انتخاب کنید",
          initialValue: selectedTitle,
        ),

        // Creator Dropdown
        DropdownWithLabel(
          onChanged: (value) => setState(() {
            selectedCreator = value;
          }),
          items: (generalProvider.filters?["installers"] ?? [])
              .map<DropdownMenuItem<String>>(
                (creator) => myDropDownItem(
                  value: creator["id"].toString(),
                  label: creator["installer"].toString(),
                ),
              )
              .toList(),
          label: "ایجاد کننده:",
          placeholder: "انتخاب کنید",
          iconOnPressed: () => setState(() {
            selectedCreator = null;
          }),
          initialValue: selectedCreator,
        ),

        // Device Dropdown
        DropdownWithLabel(
          onChanged: (value) => setState(() {
            selectedDevice = value;
          }),
          iconOnPressed: () => setState(() {
            selectedDevice = null;
          }),
          items: (generalProvider.filters?["devices"] ?? [])
              .map<DropdownMenuItem<String>>(
                (device) => myDropDownItem(
                  value: device["id"].toString(),
                  label: device["name"].toString(),
                ),
              )
              .toList(),
          label: "دستگاه:",
          placeholder: "انتخاب کنید",
          initialValue: selectedDevice,
        ),

        //
        // Date range picker
        //
        Padding(
          padding: const EdgeInsets.only(top: 5.0, bottom: 10),
          child: Row(
            spacing: 10,
            children: [
              Text("بازه زمانی:"),
              if (date != null)
                Expanded(
                  child: Text(
                    date.toString(),
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.apply(color: Colors.white),
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
        ),

        //
        // Buttons
        //
        ModalBottomButtons(
          saveText: "فیلتر",
          onSave: () {
            eventProvider.loadEvents(
              all: true,
              search: eventProvider.lastSearchedText,
              start: startDate,
              end: endDate,
              title: selectedTitle,
              creator: selectedCreator != null
                  ? int.tryParse(selectedCreator ?? "-1")
                  : null,
              device: selectedDevice != null
                  ? int.tryParse(selectedDevice ?? "-1")
                  : null,
            );

            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
