import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';
import 'package:shooka_flutter/utils/dropdowns/dropdown_with_label.dart';

class FilterUsersModal extends StatefulWidget {
  const FilterUsersModal({super.key});

  @override
  State<FilterUsersModal> createState() => _FilterUsersModalState();
}

class _FilterUsersModalState extends State<FilterUsersModal> {
  @override
  Widget build(BuildContext context) {
    String? provinceInitialValue;
    String? cityInitialValue;

    final filterOptions = [
      {
        "label": "نقش",
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
        "initialValue": provinceInitialValue,
      },
      {
        "label": "وضعیت",
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
        "initialValue": cityInitialValue,
      },
    ];

    return BottomModalTemplate(
      title: "فیلتر کاربران",
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

        SizedBox(height: 15),

        //
        // Buttons
        //
        Column(
          spacing: 7,
          children: [
            //Save button
            ContainerButton(
              color: Theme.of(context).primaryColor,
              fillWidth: true,
              child: Text(
                "اعمال فیلتر",
                style: Theme.of(context).textTheme.labelLarge,
              ),
              onPressed: () => print("save"),
            ),

            //Close button
            ContainerButton(
              color: Theme.of(context).colorScheme.errorContainer,
              fillWidth: true,
              child: Text(
                "بستن",
                style: Theme.of(context).textTheme.labelLarge,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ],
    );
  }
}
