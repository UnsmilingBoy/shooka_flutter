import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/services/providers/software_support_provider.dart';
import 'package:shooka_flutter/utils/buttons/my_icon_button.dart';
import 'package:shooka_flutter/utils/datepickers/my_range_picker.dart';
import 'package:shooka_flutter/utils/dropdowns/multi_searchable_dropdown_with_label.dart';
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
  List<String> selectedTitles = [];
  List<String> selectedCreators = [];
  List<String> selectedDevices = [];
  List<String> selectedOrganizations = [];
  List<String> selectedAdministrations = [];
  List<String> selectedProvinces = [];
  List<String> selectedCities = [];
  // Plan stays single-select.
  String? selectedPlan;
  String? startDate;
  String? endDate;

  List<String> _split(String? value) {
    if (value == null || value.trim().isEmpty) return [];
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String? _join(List<String> values) {
    if (values.isEmpty) return null;
    return values.join(',');
  }

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SoftwareSupportProvider>(
      context,
      listen: false,
    );
    selectedCreators = _split(provider.lastSelectedCreator);
    selectedDevices = _split(provider.lastSelectedDevice);
    selectedTitles = _split(provider.lastSelectedTitle);
    selectedOrganizations = _split(provider.lastSelectedOrganization);
    selectedAdministrations = _split(provider.lastSelectedAdministration);
    selectedProvinces = _split(provider.lastSelectedProvince);
    selectedCities = _split(provider.lastSelectedCity);
    selectedPlan = provider.lastSelectedPlan;
  }

  @override
  Widget build(BuildContext context) {
    final generalProvider = context.watch<GeneralProvider>();
    final supportProvider = context.watch<SoftwareSupportProvider>();

    final titleItems = (generalProvider.filters?["event_title"] ?? [])
        .map<DropdownItemModel>(
          (title) => DropdownItemModel(
            value: title.toString(),
            label: title.toString(),
          ),
        )
        .toList();

    final creatorItems = (generalProvider.filters?["installers"] ?? [])
        .map<DropdownItemModel>(
          (creator) => DropdownItemModel(
            value: creator["id"].toString(),
            label: creator["installer"].toString(),
          ),
        )
        .toList();

    final deviceItems = (generalProvider.filters?["devices"] ?? [])
        .map<DropdownItemModel>(
          (device) => DropdownItemModel(
            value: device["id"].toString(),
            label: device["name"].toString(),
          ),
        )
        .toList();

    final orgItems = (generalProvider.filters?["organizations"] ?? [])
        .map<DropdownItemModel>(
          (organization) => DropdownItemModel(
            value: organization["organization"].toString(),
            label: organization["organization"].toString(),
          ),
        )
        .toList();

    final adminItems = (generalProvider.filters?["administration"] ?? [])
        .map<DropdownItemModel>(
          (administration) => DropdownItemModel(
            value: administration["administration"].toString(),
            label: administration["administration"].toString(),
          ),
        )
        .toList();

    final provinceItems = (generalProvider.filters?["locations"] ?? [])
        .map((location) => location["location"][0].toString())
        .toSet()
        .map<DropdownItemModel>(
          (province) =>
              DropdownItemModel(value: province, label: province),
        )
        .toList();

    final cityItems = (generalProvider.filters?["locations"] ?? [])
        .where(
          (location) =>
              selectedProvinces.isEmpty ||
              selectedProvinces.contains(
                location["location"][0].toString(),
              ),
        )
        .map((location) => location["location"][1].toString())
        .toSet()
        .map<DropdownItemModel>(
          (city) => DropdownItemModel(value: city, label: city),
        )
        .toList();

    return BottomModalTemplate(
      title: "فیلتر رویداد ها",
      children: [
        MultiSelectSearchableDropdownWithLabel(
          onChanged: (values) => setState(() {
            selectedTitles = values;
          }),
          iconOnPressed: () => setState(() {
            selectedTitles.clear();
          }),
          items: titleItems,
          label: "عناوین:",
          placeholder: "انتخاب کنید (چندتایی)",
          initialValues: selectedTitles,
        ),
        MultiSelectSearchableDropdownWithLabel(
          onChanged: (values) => setState(() {
            selectedCreators = values;
          }),
          items: creatorItems,
          label: "ایجاد کننده:",
          placeholder: "انتخاب کنید (چندتایی)",
          iconOnPressed: () => setState(() {
            selectedCreators.clear();
          }),
          initialValues: selectedCreators,
        ),
        MultiSelectSearchableDropdownWithLabel(
          onChanged: (values) => setState(() {
            selectedDevices = values;
          }),
          iconOnPressed: () => setState(() {
            selectedDevices.clear();
          }),
          items: deviceItems,
          label: "دستگاه:",
          placeholder: "انتخاب کنید (چندتایی)",
          initialValues: selectedDevices,
        ),
        MultiSelectSearchableDropdownWithLabel(
          onChanged: (values) => setState(() {
            selectedOrganizations = values;
          }),
          iconOnPressed: () => setState(() {
            selectedOrganizations.clear();
          }),
          items: orgItems,
          label: "سازمان:",
          placeholder: "انتخاب کنید (چندتایی)",
          initialValues: selectedOrganizations,
        ),
        MultiSelectSearchableDropdownWithLabel(
          onChanged: (values) => setState(() {
            selectedAdministrations = values;
          }),
          iconOnPressed: () => setState(() {
            selectedAdministrations.clear();
          }),
          items: adminItems,
          label: "وزارت‌خانه:",
          placeholder: "انتخاب کنید (چندتایی)",
          initialValues: selectedAdministrations,
        ),
        MultiSelectSearchableDropdownWithLabel(
          onChanged: (values) => setState(() {
            selectedProvinces = values;
            // Drop cities that are no longer visible
            selectedCities = selectedCities
                .where(
                  (city) => cityItems.any((item) => item.value == city),
                )
                .toList();
          }),
          iconOnPressed: () => setState(() {
            selectedProvinces.clear();
            selectedCities = selectedCities
                .where(
                  (city) => cityItems.any((item) => item.value == city),
                )
                .toList();
          }),
          items: provinceItems,
          label: "استان:",
          placeholder: "انتخاب کنید (چندتایی)",
          initialValues: selectedProvinces,
        ),
        MultiSelectSearchableDropdownWithLabel(
          onChanged: (values) => setState(() {
            selectedCities = values;
          }),
          iconOnPressed: () => setState(() {
            selectedCities.clear();
          }),
          items: cityItems,
          label: "شهر:",
          placeholder: "انتخاب کنید (چندتایی)",
          initialValues: selectedCities,
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
              title: _join(selectedTitles),
              creator: _join(selectedCreators),
              device: _join(selectedDevices),
              organization: _join(selectedOrganizations),
              administration: _join(selectedAdministrations),
              province: _join(selectedProvinces),
              city: _join(selectedCities),
              plan: selectedPlan,
            );

            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }
}
