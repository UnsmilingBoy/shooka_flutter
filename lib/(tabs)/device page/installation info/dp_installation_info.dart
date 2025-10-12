import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/utils/expansion%20tile/my_expansion_tile.dart';
import 'package:shooka_flutter/utils/image%20views/image_with_caption.dart';

class InstallationInfo extends StatefulWidget {
  const InstallationInfo({super.key});

  @override
  State<InstallationInfo> createState() => _InstallationInfoState();
}

class _InstallationInfoState extends State<InstallationInfo> {
  @override
  Widget build(BuildContext context) {
    final completeData = context.watch<DeviceProvider>().completeDeviceInfo;

    var installLocationInfoList = [
      {
        "title": 'مدل دستگاه نصب شده',
        "value": completeData?.installedDeviceModel,
      },
      {"title": 'مدل مودم', "value": completeData?.modemModel},
      {"title": 'نوع ارتباط', "value": completeData?.connectionType},
      {"title": 'آیا مودم سیم‌کارت دارد؟', "value": completeData?.hasSimcard},
      {"title": 'تاریخ نصب', "value": completeData?.installationDate},
    ];

    return MyExpansionTile(
      title: "اطلاعات نصب",
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
            networkImagePath: completeData?.deviceSerialNumberImage,
            caption: "عکس شماره سریال دستگاه",
          ),
        ),
      ],
    );
  }
}
