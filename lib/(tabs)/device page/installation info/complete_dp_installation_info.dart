import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/image_service.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/utils/buttons/my_icon_button.dart';
import 'package:shooka_flutter/utils/datepickers/my_date_picker.dart';
import 'package:shooka_flutter/utils/datepickers/my_range_picker.dart';
import 'package:shooka_flutter/utils/dropdowns/dropdown_with_label.dart';
import 'package:shooka_flutter/utils/dropdowns/dropdownitem.dart';
import 'package:shooka_flutter/utils/switches/my_switch.dart';
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
  final TextEditingController _modemModel = TextEditingController();
  final TextEditingController _modemSimcardNumber = TextEditingController();

  String? _deviceModel;
  String? _connectionType;
  bool hasSimcard = false;
  String? installationDateLabel;
  String? installationDate;
  String? deviceSerialNumberImage;
  String? modemSimcardSerialNumberImage;

  final _imageService = ImageService();

  Future<void> _pickSerialNumberImage() async {
    final base64 = await _imageService.pickAndConvertToBase64();
    if (base64 != null) {
      setState(() => deviceSerialNumberImage = base64);
    }
  }

  Future<void> _pickModemSimcardSerialNumberImage() async {
    final base64 = await _imageService.pickAndConvertToBase64();
    if (base64 != null) {
      setState(() => modemSimcardSerialNumberImage = base64);
    }
  }

  setInitialValues() {
    final deviceProvider = context.read<DeviceProvider>();
    // final generalProvider = context.read<GeneralProvider>();
    // final basicData = deviceProvider.device;
    final completeData = deviceProvider.completeDeviceInfo;

    _deviceModel = completeData?.installedDeviceModel;
    _connectionType = completeData?.connectionType;
    _modemModel.text = completeData?.modemModel ?? "";
    hasSimcard = completeData?.hasSimcard ?? false;
    installationDateLabel = completeData?.installationDate;
    _modemSimcardNumber.text = completeData?.modemSimcardNumber ?? "";
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
      {"label": "مدل مودم", "controller": _modemModel},
    ];

    return BottomModalTemplate(
      title: "ویرایش اطلاعات موتورخانه",
      children: [
        DropdownWithLabel(
          iconOnPressed: () => setState(() {
            _deviceModel = null;
          }),
          onChanged: (value) => setState(() => _deviceModel = value),
          initialValue: _deviceModel,
          items: [
            myDropDownItem(value: "8relays", label: "8 رله‌ای"),
            myDropDownItem(value: "12relays", label: "12 رله‌ای"),
            myDropDownItem(value: "16relays", label: "16 رله‌ای"),
          ],
          label: "مدل دستگاه نصب شده",
          placeholder: "انتخاب مدل دستگاه نصب شده",
        ),

        DropdownWithLabel(
          iconOnPressed: () => setState(() {
            _connectionType = null;
          }),
          onChanged: (value) => setState(() => _connectionType = value),
          initialValue: _connectionType,
          items: [
            myDropDownItem(value: "internet", label: "اینترنت"),
            myDropDownItem(value: "interanet", label: "اینترانت"),
            myDropDownItem(value: "ethernet", label: "اترنت"),
          ],
          label: "نوع ارتباط",
          placeholder: "انتخاب نوع ارتباط",
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

        //
        // Installation Date Picker
        //
        Padding(
          padding: const EdgeInsets.only(top: 5.0, bottom: 10),
          child: Row(
            spacing: 10,
            children: [
              Text("تاریخ نصب:"),
              if (installationDateLabel != null)
                Expanded(
                  child: Text(
                    installationDateLabel.toString(),
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.apply(color: Colors.white),
                  ),
                ),
              MyIconButton(
                //
                // Date Range Picker
                //
                onPressed: () async {
                  var pickedDate = await myDatePicker(context);

                  if (pickedDate != null) {
                    setState(() {
                      installationDateLabel = pickedDate.formatFullDate();
                      installationDate = pickedDate.formatCompactDate();
                      print(installationDate);
                    });
                  }
                },
                border: Border.all(color: Colors.grey.shade700),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
                  spacing: 5,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.date_range_rounded,
                      size: 15,
                      color: Theme.of(context).hintColor,
                    ),
                    if (installationDateLabel == null)
                      Text(
                        "انتخاب تاریخ نصب",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        //
        // Device Serial Number Image Upload
        //
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            spacing: 10,
            children: [
              Text("عکس شماره سریال دستگاه: "),
              if (deviceSerialNumberImage != null)
                Expanded(
                  child: Text(
                    "تصویر انتخاب شد.",
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.apply(color: Colors.white),
                  ),
                ),
              Row(
                spacing: 5,
                children: [
                  if (deviceSerialNumberImage != null)
                    MyIconButton(
                      onPressed: () async {
                        setState(() {
                          deviceSerialNumberImage = null;
                        });
                      },
                      border: Border.all(color: Colors.grey.shade700),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: Icon(
                        Icons.clear,
                        size: 15,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  MyIconButton(
                    onPressed: () => _pickSerialNumberImage(),
                    border: Border.all(color: Colors.grey.shade700),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Row(
                      spacing: 5,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_camera_back_outlined,
                          size: 15,
                          color: Theme.of(context).hintColor,
                        ),
                        if (deviceSerialNumberImage == null)
                          Text(
                            "انتخاب عکس",
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        //
        // Simcard Switch
        //
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            children: [
              Expanded(child: Text("آیا سیم کارت دارد؟")),
              MySwitch(
                switchValue: hasSimcard,
                onChanged: (value) => setState(() => hasSimcard = value),
              ),
            ],
          ),
        ),

        if (hasSimcard)
          Outlinetextfieldwithlabel(
            label: "شماره سیم کارت مودم",
            controller: _modemSimcardNumber,
            placeHolder: "شماره سیم کارت مودم",
          ),

        SizedBox(height: 15),

        //
        // Modem Simcard Serial Number Image Upload
        //
        if (hasSimcard)
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              spacing: 10,
              children: [
                Text("عکس شماره سریال سیم‌کارت: "),
                if (modemSimcardSerialNumberImage != null)
                  Expanded(
                    child: Text(
                      "تصویر انتخاب شد.",
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.apply(color: Colors.white),
                    ),
                  ),
                Row(
                  spacing: 5,
                  children: [
                    if (modemSimcardSerialNumberImage != null)
                      MyIconButton(
                        onPressed: () async {
                          setState(() {
                            modemSimcardSerialNumberImage = null;
                          });
                        },
                        border: Border.all(color: Colors.grey.shade700),
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: Icon(
                          Icons.clear,
                          size: 15,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    MyIconButton(
                      onPressed: () => _pickModemSimcardSerialNumberImage(),
                      border: Border.all(color: Colors.grey.shade700),
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      child: Row(
                        spacing: 5,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_camera_back_outlined,
                            size: 15,
                            color: Theme.of(context).hintColor,
                          ),
                          if (modemSimcardSerialNumberImage == null)
                            Text(
                              "انتخاب عکس",
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        //
        // Submit Buttons
        //
        ModalBottomButtons(
          saveText: "ثبت اطلاعات",
          loading: deviceProvider.updateCompleteInfoLoading,
          onSave: () async {
            final status = await deviceProvider.updateInstallationInfo(
              deviceId: deviceProvider.device?.id ?? -1,
              installedDeviceModel: _deviceModel,
              connectionType: _connectionType,
              modemModel: _modemModel.text,
              hasSimcard: hasSimcard,
              installationDate: installationDate,
              modemSimcardNumber: _modemSimcardNumber.text,
              deviceSerialNumberImage: deviceSerialNumberImage,
              modemSimcardSerialNumberImage: modemSimcardSerialNumberImage,
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
