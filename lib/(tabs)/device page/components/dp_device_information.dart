import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/expansion%20tile/my_expansion_tile.dart';
import 'package:shooka_flutter/utils/sample_datas.dart';

class DeviceInformation extends StatefulWidget {
  const DeviceInformation({super.key});

  @override
  State<DeviceInformation> createState() => _DeviceInformationState();
}

class _DeviceInformationState extends State<DeviceInformation> {
  final deviceInformationList = {
    "orgName": "",
    "nahadName": "",
    "installerName": "",
    "status": "",
  };

  @override
  void initState() {
    deviceInformationList["orgName"] =
        devicePageSampleData[0]["orgName"] as String;

    deviceInformationList["nahadName"] =
        devicePageSampleData[0]["nahadName"] as String;

    deviceInformationList["installerName"] =
        devicePageSampleData[0]["installerName"] as String;

    deviceInformationList["status"] =
        devicePageSampleData[0]["status"] as String;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MyExpansionTile(
      initiallyExpanded: true,
      title: "اطلاعات موتورخانه",
      children: [
        ListView.builder(
          shrinkWrap: true,
          itemCount: deviceInformationList.length,
          itemBuilder: (context, index) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [],
          ),
        ),
      ],
    );
  }
}
