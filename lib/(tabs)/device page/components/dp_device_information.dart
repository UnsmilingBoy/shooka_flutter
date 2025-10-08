import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/expansion%20tile/my_expansion_tile.dart';
import 'package:shooka_flutter/utils/image%20views/image_with_caption.dart';
import 'package:shooka_flutter/utils/sample_datas.dart';

class DeviceInformation extends StatefulWidget {
  const DeviceInformation({super.key});

  @override
  State<DeviceInformation> createState() => _DeviceInformationState();
}

class _DeviceInformationState extends State<DeviceInformation> {
  var deviceInfoList = [
    {"title": 'نام سازمان / خصوصی', "value": ''},
    {"title": 'نام نهاد / خصوصی', "value": ''},
    {"title": 'نام نصاب', "value": ''},
    {"title": 'وضعیت', "value": ''},
  ];

  @override
  void initState() {
    deviceInfoList[0]["value"] = devicePageSampleData[0]["orgName"] as String;

    deviceInfoList[1]["value"] = devicePageSampleData[0]["nahadName"] as String;

    deviceInfoList[2]["value"] =
        devicePageSampleData[0]["installerName"] as String;

    deviceInfoList[3]["value"] = devicePageSampleData[0]["status"] as String;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MyExpansionTile(
      initiallyExpanded: true,
      title: "اطلاعات موتورخانه",
      children: [
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: deviceInfoList.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              children: [
                Text(
                  "${deviceInfoList[index]["title"]}: ",
                  style: Theme.of(context).textTheme.labelMedium?.apply(
                    color: Theme.of(context).hintColor,
                  ),
                ),
                Expanded(
                  child: Text(
                    "${deviceInfoList[index]["value"]}",
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
            imagepath: "assets/images/views/Hirkan_1Boiler_1Pump_2Coil.png",
            caption: "نمای موتورخانه",
          ),
        ),
      ],
    );
  }
}
