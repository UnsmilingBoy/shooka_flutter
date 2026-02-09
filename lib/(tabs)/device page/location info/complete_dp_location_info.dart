import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/device%20list/components/map.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/image_service.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/utils/buttons/my_icon_button.dart';
import 'package:shooka_flutter/utils/dropdowns/searchable_dropdown_with_label.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/utils/textfields/outline_textfield_with_label.dart';
import 'package:shooka_flutter/utils/toastifications/toasts.dart';

class CompleteDpInstallationLocationInfo extends StatefulWidget {
  const CompleteDpInstallationLocationInfo({super.key});

  @override
  State<CompleteDpInstallationLocationInfo> createState() =>
      _CompleteDpInstallationLocationInfoState();
}

class _CompleteDpInstallationLocationInfoState
    extends State<CompleteDpInstallationLocationInfo> {
  final TextEditingController _linkPerson1Controller = TextEditingController();
  final TextEditingController _linkPerson2Controller = TextEditingController();
  final TextEditingController _buildingMetrageController =
      TextEditingController();
  final TextEditingController _meterSubscriptionNumberController =
      TextEditingController();
  final TextEditingController phoneNumber1Controller = TextEditingController();
  final TextEditingController phoneNumber2Controller = TextEditingController();
  final TextEditingController installationAddress = TextEditingController();

  String? _buildingImage;

  String? location;
  String? latLong;

  final _imageService = ImageService();

  Future<void> _pickImage() async {
    final base64 = await _imageService.pickAndConvertToBase64();
    if (base64 != null) {
      setState(() => _buildingImage = base64);
    }
  }

  setInitialValues() {
    final deviceProvider = context.read<DeviceProvider>();
    final generalProvider = context.read<GeneralProvider>();
    final basicData = deviceProvider.device;
    final completeData = deviceProvider.completeDeviceInfo;

    _linkPerson1Controller.text = completeData!.linkerPerson1;
    _linkPerson2Controller.text = completeData.linkerPerson2;
    _buildingMetrageController.text = completeData.buildingMetrage.toString();
    _meterSubscriptionNumberController.text = completeData
        .meterSubscriptionNumber
        .toString();
    phoneNumber1Controller.text = completeData.phoneNumber1;
    phoneNumber2Controller.text = completeData.phoneNumber2;

    installationAddress.text = basicData?.address ?? "-";

    location = generalProvider.filters?["locations"]
        .firstWhere(
          (f) => f['id'] == basicData?.location,
          orElse: () => {},
        )['id']
        .toString();
  }

  @override
  void initState() {
    super.initState();
    setInitialValues();
  }

  @override
  Widget build(BuildContext context) {
    final generalProvider = context.watch<GeneralProvider>();
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
      {"label": "آدرس:", "controller": installationAddress},
    ];

    return BottomModalTemplate(
      title: "ویرایش اطلاعات محل نصب",
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

        SearchableDropdownWithLabel(
          iconOnPressed: () => setState(() {
            location = null;
          }),
          onChanged: (value) => setState(() {
            location = value;
          }),
          initialValue: location,
          label: "شهر و استان",
          items: (generalProvider.filters?["locations"] ?? [])
              .map<DropdownItemModel>(
                (loc) => DropdownItemModel(
                  value: loc["id"].toString(),
                  label: "${loc["location"][0]} - ${loc["location"][1]}",
                ),
              )
              .toList(),
          placeholder: "انتخاب کنید",
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            spacing: 10,
            children: [
              Text("عکس ساختمان: "),
              if (_buildingImage != null)
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
                  if (_buildingImage != null)
                    MyIconButton(
                      onPressed: () async {
                        setState(() {
                          _buildingImage = null;
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
                    onPressed: () => _pickImage(),
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
                        if (_buildingImage == null)
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

        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            spacing: 10,
            children: [
              Text("مختصات: "),
              if (latLong != null)
                Expanded(
                  child: Text(
                    latLong!,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.apply(color: Colors.white),
                  ),
                ),
              MyIconButton(
                onPressed: () async {
                  final isDesktop = MediaQuery.of(context).size.width > 900;
                  final result = isDesktop
                      ? await showDialog<LatLng>(
                          context: context,
                          builder: (context) => const MapPickerModal(),
                        )
                      : await showMaterialModalBottomSheet<LatLng>(
                          context: context,
                          enableDrag: false,
                          builder: (context) => const MapPickerModal(),
                        );

                  if (result != null) {
                    if (kDebugMode) {
                      print(
                        'Selected: ${result.latitude}, ${result.longitude}',
                      );
                    }
                    setState(() {
                      latLong = "${result.latitude}, ${result.longitude}";
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
                      Icons.map,
                      size: 15,
                      color: Theme.of(context).hintColor,
                    ),
                    if (latLong == null)
                      Text(
                        "انتخاب مختصات",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        ModalBottomButtons(
          saveText: "ثبت اطلاعات",
          loading: deviceProvider.updateCompleteInfoLoading,
          onSave: () async {
            final status = await deviceProvider.updateLocationPublicInfo(
              deviceId: deviceProvider.device?.id ?? -1,
              linkerPerson1: _linkPerson1Controller.text,
              linkerPerson2: _linkPerson2Controller.text,

              buildingMetrage: int.tryParse(_buildingMetrageController.text),
              meterSubscriptionNumber: int.tryParse(
                _meterSubscriptionNumberController.text,
              ),
              address: installationAddress.text,
              buildingImage: _buildingImage,
              phoneNumber1: phoneNumber1Controller.text,
              phoneNumber2: phoneNumber2Controller.text,
              location: location != null ? int.tryParse(location!) : null,
              latLong: latLong,
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
