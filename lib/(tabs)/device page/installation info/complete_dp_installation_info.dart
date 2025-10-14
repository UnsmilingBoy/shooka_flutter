import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
// import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/utils/textfields/outline_textfield_with_label.dart';
import 'package:shooka_flutter/utils/toastifications/toasts.dart';

class CompleteDpInstallationInfo extends StatefulWidget {
  const CompleteDpInstallationInfo({super.key});

  @override
  State<CompleteDpInstallationInfo> createState() =>
      _CompleteDpInstallationInfoState();
}

class _CompleteDpInstallationInfoState
    extends State<CompleteDpInstallationInfo> {
  final TextEditingController _linkPerson1Controller = TextEditingController();
  final TextEditingController _linkPerson2Controller = TextEditingController();
  final TextEditingController _buildingMetrageController =
      TextEditingController();
  final TextEditingController _meterSubscriptionNumberController =
      TextEditingController();
  final TextEditingController phoneNumber1Controller = TextEditingController();
  final TextEditingController phoneNumber2Controller = TextEditingController();

  String? _buildingImage;

  setInitialValues() {
    final deviceProvider = context.read<DeviceProvider>();
    // final generalProvider = context.read<GeneralProvider>();
    // final basicData = deviceProvider.device;
    final completeData = deviceProvider.completeDeviceInfo;

    _linkPerson1Controller.text = completeData!.linkerPerson1;
    _linkPerson2Controller.text = completeData.linkerPerson2;
    _buildingMetrageController.text = completeData.buildingMetrage.toString();
    _meterSubscriptionNumberController.text = completeData
        .meterSubscriptionNumber
        .toString();
    phoneNumber1Controller.text = completeData.phoneNumber1;
    phoneNumber2Controller.text = completeData.phoneNumber2;
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
      {"label": "رابط اول", "controller": _linkPerson1Controller},
      {"label": "رابط دوم", "controller": _linkPerson2Controller},
      {"label": "متراژ ساختمان", "controller": _buildingMetrageController},
      // {
      //   "label": "شماره اشتراک کنتور",
      //   "controller": _meterSubscriptionNumberController
      // },
      {"label": "تلفن رابط اول", "controller": phoneNumber1Controller},
      {"label": "تلفن رابط دوم", "controller": phoneNumber2Controller},
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

        ModalBottomButtons(
          saveText: "ثبت اطلاعات",
          loading: deviceProvider.completeInfoLoading,
          onSave: () async {
            final status = await deviceProvider.updateLocationPublicInfo(
              deviceId: deviceProvider.device?.id ?? -1,

              linkerPerson1: _linkPerson1Controller.text,
              linkerPerson2: _linkPerson2Controller.text,
              buildingMetrage: int.tryParse(_buildingMetrageController.text),
              meterSubscriptionNumber: int.tryParse(
                _meterSubscriptionNumberController.text,
              ),
              buildingImage: _buildingImage,
              phoneNumber1: phoneNumber1Controller.text,
              phoneNumber2: phoneNumber2Controller.text,
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
