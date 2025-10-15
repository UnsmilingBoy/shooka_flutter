import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/utils/dropdowns/dropdown_with_label.dart';
import 'package:shooka_flutter/utils/dropdowns/dropdownitem.dart';
import 'package:shooka_flutter/utils/switches/my_switch.dart';
// import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/utils/textfields/outline_textfield_with_label.dart';
import 'package:shooka_flutter/utils/toastifications/toasts.dart';

class CompleteDpUsageInfo extends StatefulWidget {
  const CompleteDpUsageInfo({super.key});

  @override
  State<CompleteDpUsageInfo> createState() => _CompleteDpUsageInfoState();
}

class _CompleteDpUsageInfoState extends State<CompleteDpUsageInfo> {
  final TextEditingController _numberOfBoilersController =
      TextEditingController();
  final TextEditingController _numberOfCirculatingPumpsController =
      TextEditingController();
  final TextEditingController _numberOfCoilSourcesController =
      TextEditingController();
  final TextEditingController _numberOfCoilSourcesPumpsController =
      TextEditingController();
  final TextEditingController _numberOfFloorHeatingExchangersController =
      TextEditingController();
  final TextEditingController _numberOfHotWaterPumpsController =
      TextEditingController();
  final TextEditingController _numberOfJaccuziExchangersController =
      TextEditingController();
  final TextEditingController _numberOfPoolExchangersController =
      TextEditingController();

  bool _hasExchanger = false;
  String? _usage;

  setInitialValues() {
    final deviceProvider = context.read<DeviceProvider>();
    // final generalProvider = context.read<GeneralProvider>();
    // final basicData = deviceProvider.device;
    final completeData = deviceProvider.completeDeviceInfo;

    _usage = completeData?.usage; //TODO: FIX THIS TOO

    _hasExchanger = completeData?.hasExchanger ?? false;
    _numberOfBoilersController.text =
        completeData?.numberOfBoilers.toString() ?? "";
    _numberOfCirculatingPumpsController.text =
        completeData?.numberOfCirculatingPumps.toString() ?? "";
    _numberOfCoilSourcesController.text =
        completeData?.numberOfCoilSources.toString() ?? "";
    _numberOfCoilSourcesPumpsController.text =
        completeData?.numberOfCoilSourcesPumps.toString() ?? "";
    _numberOfFloorHeatingExchangersController.text =
        completeData?.numberOfFloorHeatingExchangers.toString() ?? "";
    _numberOfHotWaterPumpsController.text =
        completeData?.numberOfHotWaterPumps.toString() ?? "";
    _numberOfJaccuziExchangersController.text =
        completeData?.numberOfJaccuziExchangers.toString() ?? "";
    _numberOfPoolExchangersController.text =
        completeData?.numberOfPoolExchangers.toString() ?? "";
  }

  @override
  void initState() {
    super.initState();
    setInitialValues();
  }

  @override
  Widget build(BuildContext context) {
    // final generalProvider = context.watch<GeneralProvider>();
    final deviceProvider = context.watch<DeviceProvider>();

    final textfieldList = [
      {"label": "تعداد دیگ ها", "controller": _numberOfBoilersController},
      {
        "label": "تعداد پمپ های سیرکوله",
        "controller": _numberOfCirculatingPumpsController,
      },
      {
        "label": "تعداد منابع کوئلی",
        "controller": _numberOfCoilSourcesController,
      },
      {
        "label": "تعداد پمپ های منابع کوئلی",
        "controller": _numberOfCoilSourcesPumpsController,
      },

      {
        "label": "تعداد پمپ های آبگرم مصرفی",
        "controller": _numberOfHotWaterPumpsController,
      },
      if (_hasExchanger)
        {
          "label": "تعداد مبدل های گرمایش از کف",
          "controller": _numberOfFloorHeatingExchangersController,
        },
      if (_hasExchanger)
        {
          "label": "تعداد مبدل های جکوزی",
          "controller": _numberOfJaccuziExchangersController,
        },
      if (_hasExchanger)
        {
          "label": "تعداد مبدل آب استخر",
          "controller": _numberOfPoolExchangersController,
        },
    ];

    return BottomModalTemplate(
      title: "ویرایش اطلاعات موتورخانه",
      children: [
        DropdownWithLabel(
          iconOnPressed: () => setState(() {
            _usage = null;
          }),
          onChanged: (value) => setState(() => _usage = value),
          initialValue: _usage,
          items: [
            myDropDownItem(value: "heating", label: "گرمایشی"),
            myDropDownItem(
              value: "heatingx",
              label: "آب گرم بهداشتی",
            ), //TODO: VALUE????
            myDropDownItem(value: "both", label: "هر دو"),
          ],
          label: "کاربری موتورخانه",
          placeholder: "کاربری موتورخانه",
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            children: [
              Expanded(
                child: Text("آیا مبدل استخر / جکوزی / گرمایش از کف دارد؟"),
              ),
              MySwitch(
                switchValue: _hasExchanger,
                onChanged: (value) => setState(() => _hasExchanger = value),
              ),
            ],
          ),
        ),

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

        ModalBottomButtons(
          saveText: "ثبت اطلاعات",
          loading: deviceProvider.updateCompleteInfoLoading,
          onSave: () async {
            final status = await deviceProvider.updateEngineRoomPublicInfo(
              deviceId: deviceProvider.device?.id ?? -1,
              hasExchanger: _hasExchanger,
              numberOfBoilers: int.tryParse(_numberOfBoilersController.text),
              numberOfCirculatingPumps: int.tryParse(
                _numberOfCirculatingPumpsController.text,
              ),
              numberOfCoilSources: int.tryParse(
                _numberOfCoilSourcesController.text,
              ),
              numberOfCoilSourcesPumps: int.tryParse(
                _numberOfCoilSourcesPumpsController.text,
              ),
              numberOfFloorHeatingExchangers: int.tryParse(
                _numberOfFloorHeatingExchangersController.text,
              ),
              numberOfHotWaterPumps: int.tryParse(
                _numberOfHotWaterPumpsController.text,
              ),
              numberOfJaccuziExchangers: int.tryParse(
                _numberOfJaccuziExchangersController.text,
              ),
              numberOfPoolExchangers: int.tryParse(
                _numberOfPoolExchangersController.text,
              ),
              usage: _usage,
            );

            if (status >= 200 && status < 300) {
              filledSuccessToast(title: "اطلاعات با موفقیت ثبت شد.");
            } else {
              filledErrorToast(title: "خطایی در ثبت اطلاعات رخ داد.");
            }
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
