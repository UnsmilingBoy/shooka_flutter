import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/utils/expansion%20tile/my_expansion_tile.dart';

class MoreDeviceInfo extends StatefulWidget {
  const MoreDeviceInfo({super.key});

  @override
  State<MoreDeviceInfo> createState() => _MoreDeviceInfoState();
}

class _MoreDeviceInfoState extends State<MoreDeviceInfo> {
  @override
  Widget build(BuildContext context) {
    final completeData = context.watch<DeviceProvider>().completeDeviceInfo;

    var installLocationInfoList = [
      {"title": 'کاربری موتورخانه', "value": completeData?.usage},
      {
        "title": 'آیا مبدل استخر / جکوزی / گرمایش از کف دارد؟',
        "value": completeData?.hasExchanger,
      },
      {"title": 'تعداد دیگ ها', "value": completeData?.numberOfBoilers},
      {
        "title": 'تعداد پمپ های سیرکوله',
        "value": completeData?.numberOfCirculatingPumps,
      },
      {
        "title": 'تعداد منابع کوئلی',
        "value": completeData?.numberOfCoilSources,
      },
      {
        "title": 'تعداد پمپ های منابع کوئلی',
        "value": completeData?.numberOfCoilSourcesPumps,
      },
      {
        "title": 'تعداد پمپ های آبگرم مصرفی',
        "value": completeData?.numberOfHotWaterPumps,
      },
    ];

    return MyExpansionTile(
      title: "اطلاعات کاربری موتورخانه",
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
      ],
    );
  }
}
