import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/models/app_panel.dart';
import 'package:shooka_flutter/models/device_filter_state.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/services/providers/user_provider.dart';
import 'package:shooka_flutter/utils/datepickers/date_range_filter_field.dart';
import 'package:shooka_flutter/utils/dropdowns/multi_searchable_dropdown_with_label.dart';
import 'package:shooka_flutter/utils/dropdowns/searchable_dropdown_with_label.dart';

class FilterDeviceModal extends StatefulWidget {
  final DeviceListMode mode;

  const FilterDeviceModal({super.key, this.mode = DeviceListMode.all});

  @override
  State<FilterDeviceModal> createState() => _FilterDeviceModalState();
}

class _FilterDeviceModalState extends State<FilterDeviceModal> {
  // Multi-select values (lists of DropdownItemModel values)
  List<String> selectedInstallers = [];
  List<String> selectedOrgs = [];
  List<String> selectedAdmins = [];
  List<String> selectedProvinces = [];
  List<String> selectedCities = [];
  List<String> selectedPlans = [];
  List<String> selectedFlowcharts = [];
  JalaliRange? dateRange;

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
    final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
    final filterState = deviceProvider.getFilterState(widget.mode);

    // Use filter state from the current mode (comma-separated -> lists)
    selectedInstallers = _split(filterState.selectedInstaller);
    selectedOrgs = _split(filterState.selectedOrg);
    selectedAdmins = _split(filterState.selectedAdmin);
    selectedProvinces = _split(filterState.selectedProvince);
    selectedCities = _split(filterState.selectedCity);
    selectedPlans = _split(filterState.selectedPlan);
    selectedFlowcharts = _split(filterState.selectedFlowchart);
    dateRange = tryParseCompactRange(filterState.startDate, filterState.endDate);
  }

  @override
  Widget build(BuildContext context) {
    final generalProvider = context.watch<GeneralProvider>();
    final deviceProvider = context.watch<DeviceProvider>();
    final canSeeFlowchart = context
        .watch<UserProvider>()
        .accessControl
        .hasAccessTo(AppPanel.flowchart);

    final installerItems = (generalProvider.filters?["installers"] ?? [])
        .map<DropdownItemModel>(
          (installer) => DropdownItemModel(
            value: installer["id"].toString(),
            label: installer["installer"].toString(),
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
          (province) => DropdownItemModel(value: province, label: province),
        )
        .toList();

    final cityItems = (generalProvider.filters?["locations"] ?? [])
        .where(
          (location) =>
              selectedProvinces.isEmpty ||
              selectedProvinces.contains(location["location"][0].toString()),
        )
        .map((location) => location["location"][1].toString())
        .toSet()
        .map<DropdownItemModel>(
          (city) => DropdownItemModel(value: city, label: city),
        )
        .toList();

    final planItems = [
      DropdownItemModel(value: "free", label: "آزاد"),
      DropdownItemModel(value: "optimized", label: "طرح بهینه سازی شرکت گاز"),
    ];

    final flowchartItems = (generalProvider.filters?["flowchart"] ?? [])
        .map<DropdownItemModel>(
          (flowchart) => DropdownItemModel(
            value: flowchart["label"].toString(),
            label: flowchart["label"].toString(),
          ),
        )
        .toList();

    // Migrate any previously-saved flowchart ids to labels, since the
    // filter now sends label text instead of ids.
    final flowchartLabelById = {
      for (final flowchart in (generalProvider.filters?["flowchart"] ?? []))
        flowchart["id"].toString(): flowchart["label"].toString(),
    };
    final effectiveSelectedFlowcharts = flowchartItems.isEmpty
        ? selectedFlowcharts
        : selectedFlowcharts
              .map((v) => flowchartLabelById[v] ?? v)
              .where((v) => flowchartItems.any((item) => item.value == v))
              .toList();

    //
    // Body
    //
    return BottomModalTemplate(
      title: "فیلتر موتورخانه ها",
      children: [
        //
        // Filter options (all multi-select)
        //
        MultiSelectSearchableDropdownWithLabel(
          iconOnPressed: () => setState(() {
            selectedInstallers.clear();
          }),
          onChanged: (values) => setState(() {
            selectedInstallers = values;
          }),
          items: installerItems,
          label: "نصاب",
          placeholder: "انتخاب کنید (چندتایی)",
          initialValues: selectedInstallers,
        ),
        MultiSelectSearchableDropdownWithLabel(
          iconOnPressed: () => setState(() {
            selectedOrgs.clear();
          }),
          onChanged: (values) => setState(() {
            selectedOrgs = values;
          }),
          items: orgItems,
          label: "سازمان",
          placeholder: "انتخاب کنید (چندتایی)",
          initialValues: selectedOrgs,
        ),
        MultiSelectSearchableDropdownWithLabel(
          iconOnPressed: () => setState(() {
            selectedAdmins.clear();
          }),
          onChanged: (values) => setState(() {
            selectedAdmins = values;
          }),
          items: adminItems,
          label: "وزارت‌خانه",
          placeholder: "انتخاب کنید (چندتایی)",
          initialValues: selectedAdmins,
        ),
        MultiSelectSearchableDropdownWithLabel(
          iconOnPressed: () => setState(() {
            selectedProvinces.clear();
            // Clear cities that no longer belong to selected provinces
            selectedCities = selectedCities
                .where((city) => cityItems.any((item) => item.value == city))
                .toList();
          }),
          onChanged: (values) => setState(() {
            selectedProvinces = values;
            // Drop cities that are no longer visible
            selectedCities = selectedCities
                .where((city) => cityItems.any((item) => item.value == city))
                .toList();
          }),
          items: provinceItems,
          label: "استان",
          placeholder: "انتخاب کنید (چندتایی)",
          initialValues: selectedProvinces,
        ),
        MultiSelectSearchableDropdownWithLabel(
          iconOnPressed: () => setState(() {
            selectedCities.clear();
          }),
          onChanged: (values) => setState(() {
            selectedCities = values;
          }),
          items: cityItems,
          label: "شهر",
          placeholder: "انتخاب کنید (چندتایی)",
          initialValues: selectedCities,
        ),
        MultiSelectSearchableDropdownWithLabel(
          iconOnPressed: () => setState(() {
            selectedPlans.clear();
          }),
          onChanged: (values) => setState(() {
            selectedPlans = values;
          }),
          items: planItems,
          label: "پلن",
          placeholder: "انتخاب کنید (چندتایی)",
          initialValues: selectedPlans,
        ),
        if (canSeeFlowchart)
          MultiSelectSearchableDropdownWithLabel(
            iconOnPressed: () => setState(() {
              selectedFlowcharts.clear();
            }),
            onChanged: (values) => setState(() {
              selectedFlowcharts = values;
            }),
            items: flowchartItems,
            label: "وضعیت دستگاه",
            placeholder: "انتخاب کنید (چندتایی)",
            initialValues: effectiveSelectedFlowcharts,
          ),

        //
        // Date range picker (shared, Jalali)
        //
        DateRangeFilterField(
          label: "بازه زمانی نصب:",
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
            log("installers are: $selectedInstallers");
            final filterState = deviceProvider.getFilterState(widget.mode);

            // Resolve to label text (migrating any stale saved ids).
            final flowchartToSend = canSeeFlowchart
                ? _join(
                    selectedFlowcharts
                        .map((v) => flowchartLabelById[v] ?? v)
                        .where(
                          (v) =>
                              flowchartItems.isEmpty ||
                              flowchartItems.any((item) => item.value == v),
                        )
                        .toList(),
                  )
                : filterState.selectedFlowchart;

            deviceProvider.loadDevicesForMode(
              mode: widget.mode,
              all: false,
              page: 1,
              search: filterState.searchedText,
              installer: _join(selectedInstallers),
              administration: _join(selectedAdmins),
              city: _join(selectedCities),
              organization: _join(selectedOrgs),
              province: _join(selectedProvinces),
              plan: _join(selectedPlans),
              flowchart: flowchartToSend,
              start: dateRange?.start.formatCompactDate(),
              end: dateRange?.end.formatCompactDate(),
            );

            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }
}
