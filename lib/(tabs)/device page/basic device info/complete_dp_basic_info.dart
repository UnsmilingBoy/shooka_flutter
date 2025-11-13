import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/utils/consts/views_list.dart';
import 'package:shooka_flutter/utils/dropdowns/dropdown_with_label.dart';
import 'package:shooka_flutter/utils/dropdowns/dropdownitem.dart';
import 'package:shooka_flutter/utils/textfields/outline_textfield_with_label.dart';
import 'package:shooka_flutter/utils/toastifications/toasts.dart';

class CompleteDpBasicInfo extends StatefulWidget {
  const CompleteDpBasicInfo({super.key});

  @override
  State<CompleteDpBasicInfo> createState() => _CompleteDpBasicInfoState();
}

class _CompleteDpBasicInfoState extends State<CompleteDpBasicInfo> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _serialNumberController = TextEditingController();
  String? orgInitialValue;
  String? installerInitialValue;
  String? featureInitialValue;

  setInitialValues() {
    final deviceProvider = context.read<DeviceProvider>();
    final generalProvider = context.read<GeneralProvider>();
    final basicData = deviceProvider.device;

    _nameController.text = basicData?.name ?? '';
    _serialNumberController.text = basicData?.serialNumber ?? '';
    orgInitialValue = generalProvider.filters?["organizations"]
        .firstWhere(
          (f) => f['organization'] == basicData?.organization,
          orElse: () => {},
        )['id']
        .toString();

    featureInitialValue = getMain3DViewById(
      features: generalProvider.filters?["features"],
      id: basicData?.engineRoomFeature ?? -1,
      returnNameOnly: true,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setInitialValues();
  }

  @override
  Widget build(BuildContext context) {
    final generalProvider = context.watch<GeneralProvider>();
    final deviceProvider = context.watch<DeviceProvider>();

    final textfieldList = [
      {"label": "نام موتورخانه", "controller": _nameController},
      {
        "label": "آپدیت شماره سریال دستگاه",
        "controller": _serialNumberController,
      },
    ];

    final dropdownList = [
      {
        "label": "نام سازمان",
        "initialValue": orgInitialValue,
        "items": (generalProvider.filters?["organizations"] ?? [])
            .map<DropdownMenuItem<String>>(
              (org) => myDropDownItem(
                value: org["id"].toString(),
                label: org["organization"].toString(),
              ),
            )
            .toList(),
      },
      {
        "label": "ویژگی موتورخانه",
        "initialValue": featureInitialValue,
        "items": (generalProvider.filters?["features"] ?? [])
            .map<DropdownMenuItem<String>>(
              (feature) => myDropDownItem(
                value: feature["main_3d_view"].toString(),
                label: feature["main_3d_view"].toString(),
              ),
            )
            .toList(),
      },
    ];

    return BottomModalTemplate(
      title: "ویرایش اطلاعات موتورخانه",
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(0),
          itemCount: textfieldList.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Outlinetextfieldwithlabel(
              label: textfieldList[index]["label"] as String,
              controller:
                  textfieldList[index]["controller"] as TextEditingController,
              placeHolder: "${textfieldList[index]["label"]}",
            ),
          ),
        ),

        //
        // Dropdowns
        //
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(0),
          itemCount: dropdownList.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: DropdownWithLabel(
              iconOnPressed: () => setState(() {
                final label = dropdownList[index]["label"] as String;
                if (label == "نام سازمان") orgInitialValue = null;
                if (label == "ویژگی موتورخانه") {
                  featureInitialValue = null;
                }
              }),
              onChanged: (value) => setState(() {
                final label = dropdownList[index]["label"] as String;
                if (label == "نام سازمان") {
                  orgInitialValue = value;
                } else if (label == "ویژگی موتورخانه") {
                  featureInitialValue = value;
                }
              }),
              initialValue: dropdownList[index]["initialValue"] as String?,
              label: dropdownList[index]["label"] as String,
              items:
                  dropdownList[index]["items"]
                      as List<DropdownMenuItem<String>>,
              placeholder: "${dropdownList[index]["label"]}",
            ),
          ),
        ),

        ModalBottomButtons(
          saveText: "ثبت اطلاعات",
          loading: deviceProvider.addLoading,
          onSave: () async {
            if (_serialNumberController.text != "" &&
                !RegExp(
                  r'^[0-9A-Fa-f]{4}\.[0-9A-Fa-f]{4}\.[0-9A-Fa-f]{4}\.[0-9A-Fa-f]{4}$',
                ).hasMatch(_serialNumberController.text)) {
              flatErrorToast(
                title: "فرمت شماره سریال اشتباه است.",
                description: "مثال: 1111.2222.AAAA.FFFF",
              );
            } else {
              final status = await deviceProvider.editDevice(
                id: deviceProvider.device?.id ?? -1,
                name: _nameController.text,
                serialNumber: _serialNumberController.text == ""
                    ? null
                    : _serialNumberController.text,
                organization: int.parse(orgInitialValue ?? '-1'),
                engineRoomFeature: featureInitialValue ?? '',
              );

              if (status >= 200 && status < 300) {
                print("status is$status");
                filledSuccessToast(title: "اطلاعات با موفقیت ثبت شد.");
              } else {
                filledErrorToast(title: "خطایی در ثبت اطلاعات رخ داد.");
              }
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}
