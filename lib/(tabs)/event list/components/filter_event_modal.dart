import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/utils/buttons/my_icon_button.dart';
import 'package:shooka_flutter/utils/datepickers/my_range_picker.dart';
import 'package:shooka_flutter/utils/dropdowns/dropdown_with_label.dart';

class FilterEventModal extends StatefulWidget {
  const FilterEventModal({super.key});

  @override
  State<FilterEventModal> createState() => _FilterEventModalState();
}

class _FilterEventModalState extends State<FilterEventModal> {
  String? date;

  @override
  Widget build(BuildContext context) {
    String? titlesInitialValue;
    String? createrInitialValue;
    String? deviceInitialValue;

    final filterOptions = [
      {
        "label": "عناوین:",
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
        "initialValue": titlesInitialValue,
      },
      {
        "label": "ایجاد کننده:",
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
        "initialValue": createrInitialValue,
      },
      {
        "label": "دستگاه:",
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
        "initialValue": deviceInitialValue,
      },
    ];

    //
    // Body
    //
    return BottomModalTemplate(
      title: "فیلتر رویداد ها",
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
                      date = date =
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
          onSave: () => print("filter event"),
        ),
      ],
    );
  }
}
