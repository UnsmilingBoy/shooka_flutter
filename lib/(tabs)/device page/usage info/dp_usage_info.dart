import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/device%20page/usage%20info/complete_dp_usage_info.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/utils/expansion%20tile/my_expansion_tile.dart';

class UsageInfo extends StatefulWidget {
  const UsageInfo({super.key});

  @override
  State<UsageInfo> createState() => _UsageInfoState();
}

class _UsageInfoState extends State<UsageInfo> {
  @override
  Widget build(BuildContext context) {
    final completeData = context.watch<DeviceProvider>().completeDeviceInfo;

    var installLocationInfoList = [
      {
        "title": 'کاربری موتورخانه',
        "value": completeData?.usage == "heating"
            ? "گرمایشی"
            : completeData?.usage == "both"
            ? "گرمایشی و آب گرم بهداشتی"
            : completeData?.usage == "sanitary"
            ? "آب گرم بهداشتی"
            : "-",
      },
      {
        "title": 'آیا مبدل استخر / جکوزی / گرمایش از کف دارد؟',
        "value": completeData?.hasExchanger == true ? 'بله' : 'خیر',
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
      if (completeData?.hasExchanger == true)
        {
          "title": 'تعداد مبدل های گرمایش از کف',
          "value": completeData?.numberOfFloorHeatingExchangers,
        },

      if (completeData?.hasExchanger == true)
        {
          "title": 'تعداد مبدل های جکوزی',
          "value": completeData?.numberOfJaccuziExchangers,
        },
      if (completeData?.hasExchanger == true)
        {
          "title": 'تعداد مبدل آب استخر',
          "value": completeData?.numberOfPoolExchangers,
        },
    ];

    return MyExpansionTile(
      completeOnPressed: () => showMaterialModalBottomSheet(
        context: context,
        builder: (context) => const CompleteDpUsageInfo(),
      ),
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
