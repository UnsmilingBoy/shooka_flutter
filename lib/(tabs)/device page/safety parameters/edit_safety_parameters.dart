import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/device%20list/components/safety_parameter_tile.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/utils/toastifications/toasts.dart';

class EditSafetyParameters extends StatefulWidget {
  const EditSafetyParameters({super.key});

  @override
  State<EditSafetyParameters> createState() => _EditSafetyParametersState();
}

class _EditSafetyParametersState extends State<EditSafetyParameters> {
  // Safety Parameters - dynamically managed based on checklist from API
  Map<int, String?> safetyParameterValues = {};
  Map<int, TextEditingController> safetyParameterNotes = {};

  @override
  void initState() {
    super.initState();
    // Initialize with mock data - replace with actual device data when backend supports it
    // For example: id 3 and 6 are rejected
    safetyParameterValues[3] = 'rejected';
    safetyParameterNotes[3] = TextEditingController(
      text: 'نیاز به نصب سرج ارستر',
    );
    safetyParameterValues[6] = 'rejected';
    safetyParameterNotes[6] = TextEditingController(
      text: 'نقشه سیم کشی موجود نیست',
    );

    // Others are approved (will be set to approved when user interacts)
    safetyParameterValues[1] = 'approved';
    safetyParameterValues[2] = 'approved';
    safetyParameterValues[4] = 'approved';
    safetyParameterValues[5] = 'approved';
  }

  // Helper method to check if all checklist items are filled
  bool _hasIncompleteChecklist(GeneralProvider generalProvider) {
    if (generalProvider.filters?["checklist"] == null) return false;

    final checklist = generalProvider.filters!["checklist"] as List;
    for (var item in checklist) {
      final id = item["id"] as int;
      if (!safetyParameterValues.containsKey(id) ||
          safetyParameterValues[id] == null) {
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
              final id = checklistItem["id"] as int;

              // Initialize controller if not exists
              if (!safetyParameterNotes.containsKey(id)) {
                safetyParameterNotes[id] = TextEditingController();
              }

              return SafetyParameterTile(
                label: checklistItem["label"] ?? "",
                description: checklistItem["description"] ?? "",
                selectedValue: safetyParameterValues[id],
                rejectionNoteController: safetyParameterNotes[id],
                onChanged: (value) => setState(() {
                  safetyParameterValues[id] = value;
                  if (value != 'rejected') {
                    safetyParameterNotes[id]?.clear();
                  }
                }),
              );
            },
          ),
        SizedBox(height: 10),
        ModalBottomButtons(
          loading: false, // deviceProvider.editLoading when backend is ready
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
              // TODO: Call API to update safety parameters when backend is ready
              // final status = await deviceProvider.updateSafetyParameters(...)

              // For now, just show success message
              filledSuccessToast(title: "پارامترهای ایمنی با موفقیت ثبت شد");
              Navigator.pop(context);
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
