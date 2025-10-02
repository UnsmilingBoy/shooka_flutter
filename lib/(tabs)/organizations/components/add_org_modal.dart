import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/utils/textfields/outline_textfield_with_label.dart';
import 'package:shooka_flutter/utils/toastifications/toasts.dart';

class AddOrgModal extends StatefulWidget {
  final bool isEdit;
  final int? id;
  final String? name;
  final String? parent;
  const AddOrgModal({
    super.key,
    required this.isEdit,
    this.name,
    this.parent,
    this.id,
  });

  @override
  State<AddOrgModal> createState() => _AddOrgModalState();
}

class _AddOrgModalState extends State<AddOrgModal> {
  onPressedAdd(generalProvider) async {
    if (orgName.text == "" || orgParent.text == "") {
      flatErrorToast(title: "لطفا همه ی مقادیر را وارد کنید.");
    } else {
      final status = await generalProvider.addAndEditOrganization(
        administration: orgParent.text,
        name: orgName.text,
      );

      if (status >= 200 && status < 300) {
        filledSuccessToast(title: "سازمان با موفقیت اضافه شد.");
      } else {
        filledErrorToast(title: "خطایی در افزودن سازمان رخ داد.");
      }
      Navigator.pop(context);
    }
  }

  onPressedEdit(GeneralProvider generalProvider) async {
    final status = await generalProvider.addAndEditOrganization(
      id: widget.id ?? -1,
      administration: orgParent.text,
      name: orgName.text,
    );

    if (status >= 200 && status < 300) {
      filledSuccessToast(title: "سازمان با موفقیت ویرایش شد.");
    } else {
      filledErrorToast(title: "خطایی در ویرایش سازمان رخ داد.");
    }
    Navigator.pop(context);
  }

  TextEditingController orgName = TextEditingController();
  TextEditingController orgParent = TextEditingController();

  @override
  void initState() {
    if (widget.isEdit) {
      orgName.text = widget.name ?? "";
      orgParent.text = widget.parent ?? "";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final generalProvider = context.watch<GeneralProvider>();

    final controllerList = [
      {
        "controller": orgName,
        "label": "نام سازمان:",
        "placeholder": "نام سازمان",
      },
      {"controller": orgParent, "label": "نهاد:", "placeholder": "نهاد"},
    ];

    //
    //Body
    //
    return BottomModalTemplate(
      title: widget.isEdit ? "ویرایش سازمان" : "سازمان جدید",
      children: [
        //
        // TextFields
        //
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: controllerList.length,
          shrinkWrap: true,
          itemBuilder: (context, index) => Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Outlinetextfieldwithlabel(
              label: controllerList[index]["label"] as String,
              controller:
                  controllerList[index]["controller"] as TextEditingController,
              placeHolder: controllerList[index]["placeholder"] as String,
            ),
          ),
        ),

        //
        // Buttons
        //
        ModalBottomButtons(
          saveText: widget.isEdit ? "ویرایش سازمان" : "افزودن سازمان",
          loading: generalProvider.editOrganizationLoading,
          onSave: widget.isEdit
              ? () => onPressedEdit(generalProvider)
              : () => onPressedAdd(generalProvider),
        ),
      ],
    );
  }
}
