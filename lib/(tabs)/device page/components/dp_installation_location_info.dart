import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/utils/expansion%20tile/my_expansion_tile.dart';
import 'package:shooka_flutter/utils/image%20views/image_with_caption.dart';

class InstallationLocationInfo extends StatefulWidget {
  const InstallationLocationInfo({super.key});

  @override
  State<InstallationLocationInfo> createState() =>
      _InstallationLocationInfoState();
}

class _InstallationLocationInfoState extends State<InstallationLocationInfo> {
  @override
  Widget build(BuildContext context) {
    final completeData = context.watch<DeviceProvider>().completeDeviceInfo;
    final basicData = context.watch<DeviceProvider>().device;

    final installLocationInfoList = [
      {"title": 'رابط اول', "value": completeData?.linkerPerson1},
      {"title": 'تلفن رابط اول', "value": completeData?.phoneNumber1},
      {"title": 'رابط دوم', "value": completeData?.linkerPerson2},
      {"title": 'تلفن رابط دوم', "value": completeData?.phoneNumber2},
      {"title": 'متراژ ساختمان', "value": completeData?.buildingMetrage},
      {"title": 'آدرس', "value": basicData?.address},
      {"title": 'استان', "value": basicData?.province},
      {"title": 'شهر', "value": basicData?.city},
    ];
    return MyExpansionTile(
      title: "اطلاعات محل نصب",
      children: [
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: installLocationInfoList.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              children: [
                Text(
                  "${installLocationInfoList[index]["title"]}: ",
                  style: Theme.of(context).textTheme.labelMedium?.apply(
                    color: Theme.of(context).hintColor,
                  ),
                ),
                Expanded(
                  child: Text(
                    "${installLocationInfoList[index]["value"]}",
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: 200,
          child: ImageWithCaption(
            networkImagePath: completeData?.buildingImage,
            localImagepath:
                "assets/images/views/Hirkan_1Boiler_1Pump_2Coil.png",
            caption: "عکس ساختمان",
          ),
        ),
      ],
    );
  }
}
