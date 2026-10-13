import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/providers/event_provider.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/utils/datepickers/date_range_filter_field.dart';
import 'package:shooka_flutter/utils/dropdowns/searchable_dropdown_with_label.dart';
import 'package:shooka_flutter/utils/dropdowns/multi_searchable_dropdown_with_label.dart';

class FilterEventModal extends StatefulWidget {
  const FilterEventModal({super.key});

  @override
  State<FilterEventModal> createState() => _FilterEventModalState();
}

class _FilterEventModalState extends State<FilterEventModal> {
  JalaliRange? dateRange;
  List<String> selectedTitles = [];
  List<String> selectedCreators = [];
  List<String> selectedDevices = [];
  List<String> selectedOrganizations = [];
  List<String> selectedAdministrations = [];
  List<String> selectedProvinces = [];
  List<String> selectedCities = [];
  // Plan stays single-select in events.
  String? selectedPlan;

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
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    // Use provider fields for last selected values (comma-separated -> lists)
    selectedCreators = _split(eventProvider.lastSelectedCreator);
    selectedDevices = _split(eventProvider.lastSelectedDevice);
    selectedTitles = _split(eventProvider.lastSelectedTitle);
    selectedOrganizations = _split(eventProvider.lastSelectedOrganization);
    selectedAdministrations = _split(
      eventProvider.lastSelectedAdministration,
    );
    selectedProvinces = _split(eventProvider.lastSelectedProvince);
    selectedCities = _split(eventProvider.lastSelectedCity);
    selectedPlan = eventProvider.lastSelectedPlan;
    // Restore the previously picked range (was previously dropped on reopen).
    dateRange = tryParseCompactRange(
      eventProvider.lastSelectedStart,
      eventProvider.lastSelectedEnd,
    );
  }

  @override
  Widget build(BuildContext context) {
    final generalProvider = context.watch<GeneralProvider>();
    final eventProvider = context.watch<EventProvider>();

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

    //
    // Body
    //
    return BottomModalTemplate(
      title: "فیلتر رویداد ها",
      children: [
        //
        // Filter options (all multi-select except plan)
        //

        // Title Multi-Select Dropdown
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

        // Creator Multi-Select Dropdown
        MultiSelectSearchableDropdownWithLabel(
          onChanged: (values) => setState(() {
            selectedCreators = values;
          }),
          iconOnPressed: () => setState(() {
            selectedCreators.clear();
          }),
          items: creatorItems,
          label: "ایجاد کننده:",
          placeholder: "انتخاب کنید (چندتایی)",
          initialValues: selectedCreators,
        ),

        // Device Multi-Select Dropdown (comma-separated ids: e.g. 2,3,4)
        MultiSelectSearchableDropdownWithLabel(
          onChanged: (values) => setState(() {
            selectedDevices = values;
          }),
          iconOnPressed: () => setState(() {
            selectedDevices.clear();
          }),
          items: deviceItems,
          label: "دستگاه‌ها:",
          placeholder: "انتخاب کنید (چندتایی)",
          initialValues: selectedDevices,
        ),

        // Organization Multi-Select Dropdown
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

        // Administration Multi-Select Dropdown
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

        // Province Multi-Select Dropdown
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

        // City Multi-Select Dropdown
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

        // Plan Dropdown (single-select, unchanged)
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

        //
        // Date range picker (shared, Jalali)
        //
        DateRangeFilterField(
          label: "بازه زمانی:",
          value: dateRange,
          onChanged: (range) => setState(() {
            dateRange = range;
          }),
        ),

        //
        // Buttons
        //
        ModalBottomButtons(
          saveText: "فیلتر",
          onSave: () {
            eventProvider.loadEvents(
              search: eventProvider.lastSearchedText,
              start: dateRange?.start.formatCompactDate(),
              end: dateRange?.end.formatCompactDate(),
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
