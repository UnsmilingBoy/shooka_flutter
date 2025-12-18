import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/device%20list/components/safety_parameter_tile.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/utils/toastifications/toasts.dart';

class EditSafetyParameters extends StatefulWidget {
  const EditSafetyParameters({super.key});

  @override
  State<EditSafetyParameters> createState() => _EditSafetyParametersState();
}

class _EditSafetyParametersState extends State<EditSafetyParameters> {
  // Safety Parameters - dynamically managed based on checklist from API
  Map<String, String?> safetyParameterValues = {};
  Map<String, TextEditingController> safetyParameterNotes = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with actual device data from API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deviceProvider = context.read<DeviceProvider>();
      final checklistItems =
          deviceProvider.completeDeviceInfo?.checklistItemsData ?? [];

      for (var item in checklistItems) {
        safetyParameterValues[item.name] = item.isApproved
            ? 'approved'
            : 'rejected';
        if (!item.isApproved && item.notes != null && item.notes!.isNotEmpty) {
          safetyParameterNotes[item.name] = TextEditingController(
            text: item.notes,
          );
        }
      }
      setState(() {});
    });
  }

  // Helper method to check if all checklist items are filled
  bool _hasIncompleteChecklist(GeneralProvider generalProvider) {
    if (generalProvider.filters?["checklist"] == null) return false;

    final checklist = generalProvider.filters!["checklist"] as List;
    for (var item in checklist) {
      final name = item["name"] as String;
      if (!safetyParameterValues.containsKey(name) ||
          safetyParameterValues[name] == null) {
        return true;
      }
    }
    return false;
  }

  // Helper method to check if any rejected parameter lacks a note
  bool _hasRejectedWithoutNote() {
    for (var entry in safetyParameterValues.entries) {
      if (entry.value == 'rejected') {
        final noteController = safetyParameterNotes[entry.key];
        if (noteController == null || noteController.text.isEmpty) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final generalProvider = context.watch<GeneralProvider>();

    return BottomModalTemplate(
      title: "ویرایش پارامترهای ایمنی",
      isLongList: true,
      children: [
        // Safety Parameters Section - dynamically generated from checklist
        if (generalProvider.filters?["checklist"] != null)
          ...List.generate(
            (generalProvider.filters!["checklist"] as List).length,
            (index) {
              final checklistItem =
                  (generalProvider.filters!["checklist"] as List)[index];
              final name = checklistItem["name"] as String;

              // Initialize controller if not exists
              if (!safetyParameterNotes.containsKey(name)) {
                safetyParameterNotes[name] = TextEditingController();
              }

              return SafetyParameterTile(
                label: checklistItem["label"] ?? "",
                description: checklistItem["description"] ?? "",
                selectedValue: safetyParameterValues[name],
                rejectionNoteController: safetyParameterNotes[name],
                onChanged: (value) => setState(() {
                  safetyParameterValues[name] = value;
                  if (value != 'rejected') {
                    safetyParameterNotes[name]?.clear();
                  }
                }),
              );
            },
          ),
        SizedBox(height: 10),
        ModalBottomButtons(
          loading: _isLoading,
          saveText: "ذخیره تغییرات",
          onSave: () async {
            if (_hasIncompleteChecklist(generalProvider)) {
              flatErrorToast(
                title: "لطفا همه پارامترهای ایمنی را تایید یا رد کنید.",
              );
            } else if (_hasRejectedWithoutNote()) {
              flatErrorToast(
                title: "لطفا برای پارامترهای رد شده، دلیل رد را وارد کنید.",
              );
            } else {
              setState(() => _isLoading = true);

              final deviceProvider = context.read<DeviceProvider>();
              final deviceId = deviceProvider.device?.id;

              if (deviceId == null) {
                flatErrorToast(title: "خطا: شناسه دستگاه یافت نشد");
                setState(() => _isLoading = false);
                return;
              }

              // Prepare checklist items for API
              final checklistItems = safetyParameterValues.entries.map((entry) {
                return {
                  "name": entry.key,
                  "is_approved": entry.value == 'approved',
                  "note": entry.value == 'rejected'
                      ? (safetyParameterNotes[entry.key]?.text ?? '')
                      : '',
                };
              }).toList();

              final status = await deviceProvider.updateSafetyParameters(
                deviceId: deviceId,
                checkListItems: checklistItems,
              );

              setState(() => _isLoading = false);

              if (status == 200) {
                filledSuccessToast(title: "پارامترهای ایمنی با موفقیت ثبت شد");
                if (context.mounted) {
                  Navigator.pop(context);
                }
              } else {
                flatErrorToast(title: "خطا در ذخیره اطلاعات");
              }
            }
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Dispose all safety parameter note controllers
    for (var controller in safetyParameterNotes.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
