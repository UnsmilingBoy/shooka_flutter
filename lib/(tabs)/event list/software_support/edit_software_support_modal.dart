import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/event%20list/software_support/widgets/support_requester_fields.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/providers/software_support_provider.dart';
import 'package:shooka_flutter/utils/textfields/outline_textfield_with_label.dart';
import 'package:shooka_flutter/utils/textfields/outline_textformfield.dart';
import 'package:shooka_flutter/utils/toastifications/toasts.dart';

class EditSoftwareSupportModal extends StatefulWidget {
  final int? eventGroupId;
  final int? eventId;
  final String title;
  final String text;
  final dynamic registeredRequester;
  final String? externalRequester;
  final String? requesterPhoneNumber;

  const EditSoftwareSupportModal({
    super.key,
    required this.eventGroupId,
    required this.eventId,
    required this.title,
    required this.text,
    this.registeredRequester,
    this.externalRequester,
    this.requesterPhoneNumber,
  });

  @override
  State<EditSoftwareSupportModal> createState() =>
      _EditSoftwareSupportModalState();
}

class _EditSoftwareSupportModalState extends State<EditSoftwareSupportModal> {
  late final TextEditingController titleController;
  late final TextEditingController phoneController;
  late final TextEditingController externalNameController;
  late final TextEditingController textController;

  String requesterPhoneType = 'profile_phone';
  int? selectedUserId;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.title);
    phoneController = TextEditingController(
      text: widget.requesterPhoneNumber ?? '',
    );
    externalNameController = TextEditingController(
      text: widget.externalRequester ?? '',
    );
    textController = TextEditingController(text: widget.text);

    final hasExternal = widget.externalRequester != null &&
        widget.externalRequester!.isNotEmpty;
    if (hasExternal) {
      requesterPhoneType = 'external';
    }
    selectedUserId = _extractUserId(widget.registeredRequester);
  }

  @override
  void dispose() {
    titleController.dispose();
    phoneController.dispose();
    externalNameController.dispose();
    textController.dispose();
    super.dispose();
  }

  int? _extractUserId(dynamic registeredRequester) {
    if (registeredRequester is Map<String, dynamic>) {
      return int.tryParse(registeredRequester['id'].toString());
    }
    if (registeredRequester is int) return registeredRequester;
    if (registeredRequester is num) return registeredRequester.toInt();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final supportProvider = context.watch<SoftwareSupportProvider>();

    return BottomModalTemplate(
      title: "ویرایش رویداد پشتیبانی",
      isLongList: true,
      children: [
        Outlinetextfieldwithlabel(
          label: "عنوان",
          controller: titleController,
          placeHolder: "عنوان...",
        ),
        SupportRequesterFields(
          initialType: requesterPhoneType,
          initialUserId: selectedUserId,
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
          saveText: "ویرایش گزارش",
          loading: supportProvider.editLoading,
          onSave: () async {
            final title = titleController.text.trim();
            final text = textController.text.trim();

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

            final result = await supportProvider.editEvent(
              eventGroupId: widget.eventGroupId,
              eventId: widget.eventId,
              title: title,
              text: text,
              requesterPhoneType: requesterPhoneType,
              requesterUserId: selectedUserId,
              phoneNumber: phoneController.text.trim(),
              externalRequesterName: externalNameController.text.trim(),
            );

            if (result?['result'] == 'ok') {
              filledSuccessToast(title: 'رویداد با موفقیت ویرایش شد.');
              if (context.mounted) Navigator.pop(context);
            } else {
              filledErrorToast(
                title: 'خطایی در ویرایش رویداد رخ داده است.',
              );
            }
          },
        ),
      ],
    );
  }
}
