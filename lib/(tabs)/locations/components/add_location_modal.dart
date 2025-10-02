import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/utils/textfields/outline_textfield_with_label.dart';
import 'package:shooka_flutter/utils/toastifications/toasts.dart';

class AddLocationModal extends StatefulWidget {
  final bool isEdit;
  final int? id;
  final String? city;
  final String? province;
  const AddLocationModal({
    super.key,
    required this.isEdit,
    this.city,
    this.province,
    this.id,
  });

  @override
  State<AddLocationModal> createState() => _AddLocationModalState();
}

class _AddLocationModalState extends State<AddLocationModal> {
  onPressedAdd(GeneralProvider generalProvider) async {
    if (city.text == "" || province.text == "") {
      flatErrorToast(title: "لطفا همه ی مقادیر را وارد کنید.");
    } else {
      final status = await generalProvider.addAndEditLocation(
        city: city.text,
        province: province.text,
      );

      if (status >= 200 && status < 300) {
        filledSuccessToast(title: "مکان با موفقیت اضافه شد.");
      } else {
        filledErrorToast(title: "خطایی در افزودن مکان رخ داد.");
      }
      Navigator.pop(context);
    }
  }

  onPressedEdit(GeneralProvider generalProvider) async {
    final status = await generalProvider.addAndEditLocation(
      id: widget.id ?? -1,
      city: city.text,
      province: province.text,
    );

    if (status >= 200 && status < 300) {
      filledSuccessToast(title: "مکان با موفقیت ویرایش شد.");
    } else {
      filledErrorToast(title: "خطایی در ویرایش مکان رخ داد.");
    }
    Navigator.pop(context);
  }

  TextEditingController city = TextEditingController();
  TextEditingController province = TextEditingController();

  @override
  void initState() {
    if (widget.isEdit) {
      city.text = widget.city ?? "";
      province.text = widget.province ?? "";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final generalProvider = context.watch<GeneralProvider>();

    final controllerList = [
      {"controller": city, "label": "شهر:", "placeholder": "شهر"},
      {"controller": province, "label": "استان:", "placeholder": "استان"},
    ];

    //
    //Body
    //
    return BottomModalTemplate(
      title: widget.isEdit ? "ویرایش مکان" : "مکان جدید",
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
          loading: generalProvider.editLocationLoading,
          saveText: widget.isEdit ? "ویرایش مکان" : "افزودن مکان",
          onSave: widget.isEdit
              ? () => onPressedEdit(generalProvider)
              : () => onPressedAdd(generalProvider),
        ),
      ],
    );
  }
}
