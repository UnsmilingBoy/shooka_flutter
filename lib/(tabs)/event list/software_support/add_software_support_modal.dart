import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/event%20list/software_support/widgets/support_requester_fields.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/services/providers/software_support_provider.dart';
import 'package:shooka_flutter/utils/dropdowns/searchable_dropdown_with_label.dart';
import 'package:shooka_flutter/utils/textfields/outline_textfield_with_label.dart';
import 'package:shooka_flutter/utils/textfields/outline_textformfield.dart';
import 'package:shooka_flutter/utils/toastifications/toasts.dart';

class AddSoftwareSupportModal extends StatefulWidget {
  const AddSoftwareSupportModal({super.key});

  @override
  State<AddSoftwareSupportModal> createState() =>
      _AddSoftwareSupportModalState();
}

class _AddSoftwareSupportModalState extends State<AddSoftwareSupportModal> {
  final titleController = TextEditingController();
  final phoneController = TextEditingController();
  final externalNameController = TextEditingController();
  final textController = TextEditingController();

  String? selectedDevice;
  String requesterPhoneType = 'profile_phone';
  int? selectedUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final supportProvider = context.read<SoftwareSupportProvider>();
      if (supportProvider.users.isEmpty && !supportProvider.usersLoading) {
        supportProvider.fetchUsers();
      }
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    phoneController.dispose();
    externalNameController.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supportProvider = context.watch<SoftwareSupportProvider>();
    final generalProvider = context.watch<GeneralProvider>();

    return BottomModalTemplate(
      title: "رویداد جدید پشتیبانی",
      isLongList: true,
      children: [
        SearchableDropdownWithLabel(
          initialValue: selectedDevice,
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
          onChanged: (value) {
            setState(() {
              selectedDevice = value;
            });
          },
          label: "موتورخانه",
          placeholder: "انتخاب موتورخانه...",
        ),
        Outlinetextfieldwithlabel(
          label: "عنوان",
          controller: titleController,
          placeHolder: "عنوان...",
        ),
        SupportRequesterFields(
          users: supportProvider.users,
          phoneController: phoneController,
          externalNameController: externalNameController,
          onTypeChanged: (value) {
            requesterPhoneType = value;
          },
          onUserIdChanged: (value) {
            selectedUserId = value;
          },
          searchUsers: (filter) => supportProvider.fetchUsers(search: filter),
        ),
        Column(
          spacing: 3,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("توضیحات"),
            OutlineTextformfield(
              controller: textController,
              placeholder: "توضیحات...",
            ),
          ],
        ),
        ModalBottomButtons(
          saveText: "افزودن گزارش",
          loading: supportProvider.addLoading,
          onSave: () async {
            final title = titleController.text.trim();
            final text = textController.text.trim();

            if (selectedDevice == null) {
              flatErrorToast(title: "موتورخانه ای انتخاب نشده است.");
              return;
            }
            if (title.isEmpty) {
              flatErrorToast(title: "عنوان وارد نشده است.");
              return;
            }
            if (requesterPhoneType != 'external' && selectedUserId == null) {
              flatErrorToast(title: "کاربر انتخاب نشده است.");
              return;
            }
            if (requesterPhoneType == 'custom_phone' &&
                phoneController.text.trim().isEmpty) {
              flatErrorToast(title: "شماره تلفن وارد نشده است.");
              return;
            }
            if (requesterPhoneType == 'external' &&
                externalNameController.text.trim().isEmpty) {
              flatErrorToast(title: "نام درخواست‌دهنده وارد نشده است.");
              return;
            }
            if (requesterPhoneType == 'external' &&
                phoneController.text.trim().isEmpty) {
              flatErrorToast(title: "شماره تلفن وارد نشده است.");
              return;
            }
            if (text.isEmpty) {
              flatErrorToast(title: "توضیحات وارد نشده است.");
              return;
            }

            final result = await supportProvider.addEvent(
              projectName: "TESKA-HIRKAN",
              device: int.tryParse(selectedDevice!) ?? -1,
              title: title,
              text: text,
              requesterPhoneType: requesterPhoneType,
              requesterUserId: selectedUserId,
              phoneNumber: phoneController.text.trim(),
              externalRequesterName: externalNameController.text.trim(),
            );

            if (result?['result'] == 'ok') {
              filledSuccessToast(title: 'رویداد با موفقیت اضافه شد.');
              if (context.mounted) Navigator.pop(context);
            } else {
              filledErrorToast(
                title: 'خطایی در اضافه کردن رویداد رخ داده است.',
              );
            }
          },
        ),
      ],
    );
  }
}
