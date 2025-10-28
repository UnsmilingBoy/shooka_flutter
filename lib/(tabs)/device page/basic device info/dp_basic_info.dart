import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/device%20page/basic%20device%20info/complete_dp_basic_info.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/utils/consts/views_list.dart';
import 'package:shooka_flutter/utils/expansion%20tile/my_expansion_tile.dart';
import 'package:shooka_flutter/utils/image%20views/image_with_caption.dart';

class BasicDeviceInformation extends StatefulWidget {
  const BasicDeviceInformation({super.key});

  @override
  State<BasicDeviceInformation> createState() => _BasicDeviceInformationState();
}

class _BasicDeviceInformationState extends State<BasicDeviceInformation> {
  @override
  Widget build(BuildContext context) {
    // final deviceProvider = context.watch<DeviceProvider>();
    final basicData = context.watch<DeviceProvider>().device;
    final features = context.watch<GeneralProvider>().filters["features"];

    var deviceInfoList = [
      {"title": 'نام', "value": basicData?.name},
      {"title": 'نام سازمان / خصوصی', "value": basicData?.organization},
      {"title": 'نام نهاد / خصوصی', "value": basicData?.administration},
      {"title": 'نام نصاب', "value": basicData?.creator},
      {"title": 'وضعیت', "value": basicData?.status},
    ];

    return MyExpansionTile(
      initiallyExpanded: true,
      title: "اطلاعات موتورخانه",
      completeOnPressed: () => showMaterialModalBottomSheet(
        context: context,
        builder: (context) => CompleteDpBasicInfo(),
      ),
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
          height: MediaQuery.sizeOf(context).width > 600 ? 400 : 200,
          child: ImageWithCaption(
            localImagepath: getMain3DViewById(
              features: features,
              id: basicData?.engineRoomFeature ?? 1,
            ),
            caption: "نمای موتورخانه",
          ),
        ),
      ],
    );
  }
}
