import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/services/providers/software_support_provider.dart';
import 'package:shooka_flutter/utils/buttons/my_icon_button.dart';
import 'package:shooka_flutter/utils/datepickers/my_range_picker.dart';
import 'package:shooka_flutter/utils/dropdowns/searchable_dropdown_with_label.dart';

class FilterSoftwareSupportModal extends StatefulWidget {
  const FilterSoftwareSupportModal({super.key});

  @override
  State<FilterSoftwareSupportModal> createState() =>
      _FilterSoftwareSupportModalState();
}

class _FilterSoftwareSupportModalState
    extends State<FilterSoftwareSupportModal> {
  String? date;
  String? selectedTitle;
  String? selectedCreator;
  String? selectedDevice;
  String? selectedOrganization;
  String? selectedAdministration;
  String? selectedProvince;
  String? selectedCity;
  String? selectedPlan;
  String? startDate;
  String? endDate;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SoftwareSupportProvider>(
      context,
      listen: false,
    );
    selectedCreator = provider.lastSelectedCreator?.toString();
    selectedDevice = provider.lastSelectedDevice?.toString();
    selectedTitle = provider.lastSelectedTitle;
    selectedOrganization = provider.lastSelectedOrganization;
    selectedAdministration = provider.lastSelectedAdministration;
    selectedProvince = provider.lastSelectedProvince;
    selectedCity = provider.lastSelectedCity;
    selectedPlan = provider.lastSelectedPlan;
  }

  @override
  Widget build(BuildContext context) {
    final generalProvider = context.watch<GeneralProvider>();
    final supportProvider = context.watch<SoftwareSupportProvider>();

    return BottomModalTemplate(
      title: "فیلتر رویداد ها",
      children: [
        SearchableDropdownWithLabel(
          onChanged: (value) => setState(() {
            selectedTitle = value;
          }),
          iconOnPressed: () => setState(() {
            selectedTitle = null;
          }),
          items: (generalProvider.filters?["event_title"] ?? [])
              .map<DropdownItemModel>(
                (title) => DropdownItemModel(value: title, label: title),
              )
              .toList(),
          label: "عناوین:",
          placeholder: "انتخاب کنید",
          initialValue: selectedTitle,
        ),
        SearchableDropdownWithLabel(
          onChanged: (value) => setState(() {
            selectedCreator = value;
          }),
          items: (generalProvider.filters?["installers"] ?? [])
              .map<DropdownItemModel>(
                (creator) => DropdownItemModel(
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
        SearchableDropdownWithLabel(
          onChanged: (value) => setState(() {
            selectedDevice = value;
          }),
          iconOnPressed: () => setState(() {
            selectedDevice = null;
          }),
          items: (generalProvider.filters?["devices"] ?? [])
              .map<DropdownItemModel>(
                (device) => DropdownItemModel(
                  value: device["id"].toString(),
                  label: device["name"].toString(),
                ),
              )
              .toList(),
          label: "دستگاه:",
          placeholder: "انتخاب کنید",
          initialValue: selectedDevice,
        ),
        SearchableDropdownWithLabel(
          onChanged: (value) => setState(() {
            selectedOrganization = value;
          }),
          iconOnPressed: () => setState(() {
            selectedOrganization = null;
          }),
          items: (generalProvider.filters?["organizations"] ?? [])
              .map<DropdownItemModel>(
                (organization) => DropdownItemModel(
                  value: organization["organization"].toString(),
                  label: organization["organization"].toString(),
                ),
              )
              .toList(),
          label: "سازمان:",
          placeholder: "انتخاب کنید",
          initialValue: selectedOrganization,
        ),
        SearchableDropdownWithLabel(
          onChanged: (value) => setState(() {
            selectedAdministration = value;
          }),
          iconOnPressed: () => setState(() {
            selectedAdministration = null;
          }),
          items: (generalProvider.filters?["administration"] ?? [])
              .map<DropdownItemModel>(
                (administration) => DropdownItemModel(
                  value: administration["administration"].toString(),
                  label: administration["administration"].toString(),
                ),
              )
              .toList(),
          label: "وزارت‌خانه:",
          placeholder: "انتخاب کنید",
          initialValue: selectedAdministration,
        ),
        SearchableDropdownWithLabel(
          onChanged: (value) => setState(() {
            selectedProvince = value;
          }),
          iconOnPressed: () => setState(() {
            selectedProvince = null;
          }),
          items: (generalProvider.filters?["locations"] ?? [])
              .map((location) => location["location"][0].toString())
              .toSet()
              .map<DropdownItemModel>(
                (province) =>
                    DropdownItemModel(value: province, label: province),
              )
              .toList(),
          label: "استان:",
          placeholder: "انتخاب کنید",
          initialValue: selectedProvince,
        ),
        SearchableDropdownWithLabel(
          onChanged: (value) => setState(() {
            selectedCity = value;
          }),
          iconOnPressed: () => setState(() {
            selectedCity = null;
          }),
          items: (generalProvider.filters?["locations"] ?? [])
              .where(
                (location) =>
                    selectedProvince == null ||
                    location["location"][0].toString() == selectedProvince,
              )
              .map((location) => location["location"][1].toString())
              .toSet()
              .map<DropdownItemModel>(
                (city) => DropdownItemModel(value: city, label: city),
              )
              .toList(),
          label: "شهر:",
          placeholder: "انتخاب کنید",
          initialValue: selectedCity,
        ),
        SearchableDropdownWithLabel(
          onChanged: (value) => setState(() {
            selectedPlan = value;
          }),
          iconOnPressed: () => setState(() {
            selectedPlan = null;
          }),
          items: [
            DropdownItemModel(value: "optimized", label: "طرح بهینه سازی"),
            DropdownItemModel(value: "free", label: "رایگان"),
          ],
          label: "پلن:",
          placeholder: "انتخاب کنید",
          initialValue: selectedPlan,
        ),
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
                onPressed: () async {
                  final picked = await myRangePicker(context);

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
        ModalBottomButtons(
          saveText: "فیلتر",
          onSave: () {
            supportProvider.loadEvents(
              search: supportProvider.lastSearchedText,
              start: startDate,
              end: endDate,
              title: selectedTitle,
              creator: selectedCreator != null
                  ? int.tryParse(selectedCreator ?? "-1")
                  : null,
              device: selectedDevice != null
                  ? int.tryParse(selectedDevice ?? "-1")
                  : null,
              organization: selectedOrganization,
              administration: selectedAdministration,
              province: selectedProvince,
              city: selectedCity,
              plan: selectedPlan,
            );

            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}