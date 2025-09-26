import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/utils/textfields/outline_textfield_with_label.dart';

class AddLocationModal extends StatefulWidget {
  final bool isEdit;
  final String? city;
  final String? province;
  const AddLocationModal({
    super.key,
    required this.isEdit,
    this.city,
    this.province,
  });

  @override
  State<AddLocationModal> createState() => _AddLocationModalState();
}

class _AddLocationModalState extends State<AddLocationModal> {
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
          saveText: widget.isEdit ? "ویرایش مکان" : "افزودن مکان",
          onSave: () => print("add loc"),
        ),
      ],
    );
  }
}
