import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/services/providers/user_provider.dart';
import 'package:shooka_flutter/utils/dropdowns/dropdown_with_label.dart';
import 'package:shooka_flutter/utils/dropdowns/dropdownitem.dart';

class FilterUsersModal extends StatefulWidget {
  const FilterUsersModal({super.key});

  @override
  State<FilterUsersModal> createState() => _FilterUsersModalState();
}

class _FilterUsersModalState extends State<FilterUsersModal> {
  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    // Use provider fields for last selected values (if you add them)
    roleInitialValue = userProvider.lastSelectedRole;
    statusInitialValue = userProvider.lastSelectedStatus;
  }

  String? roleInitialValue;
  String? statusInitialValue;

  @override
  Widget build(BuildContext context) {
    final generalProvider = context.watch<GeneralProvider>();
    final userProvider = context.read<UserProvider>();

    final filterOptions = [
      {
        "label": "نقش",
        "items": (generalProvider.filters?["roles"] ?? [])
            .map<DropdownMenuItem<String>>(
              (role) => myDropDownItem(value: role, label: role),
            )
            .toList(),
        "initialValue": roleInitialValue,
      },
      {
        "label": "وضعیت",
        "items": (generalProvider.filters?["status"] ?? [])
            .map<DropdownMenuItem<String>>(
              (status) => myDropDownItem(
                value: status,
                label: status == "active" ? "فعال" : "غیرفعال",
              ),
            )
            .toList(),
        "initialValue": statusInitialValue,
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
            iconOnPressed: () => setState(() {
              if (filterOptions[index]["label"] == "نقش") {
                roleInitialValue = null;
              } else if (filterOptions[index]["label"] == "وضعیت") {
                statusInitialValue = null;
              }
            }),
            onChanged: (value) => setState(() {
              // Update both the filterOptions and the actual state variables
              filterOptions[index]["initialValue"] = value;

              if (filterOptions[index]["label"] == "نقش") {
                roleInitialValue = value;
              } else if (filterOptions[index]["label"] == "وضعیت") {
                statusInitialValue = value;
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
          onSave: () async {
            Navigator.pop(context);
            await userProvider.fetchUsers(
              page: 1,
              search: userProvider.lastSearchedUser,
              role: roleInitialValue,
              status: statusInitialValue,
            );
          },
        ),
      ],
    );
  }
}
