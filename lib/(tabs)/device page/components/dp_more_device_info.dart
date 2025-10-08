import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/expansion%20tile/my_expansion_tile.dart';

class MoreDeviceInfo extends StatefulWidget {
  const MoreDeviceInfo({super.key});

  @override
  State<MoreDeviceInfo> createState() => _MoreDeviceInfoState();
}

class _MoreDeviceInfoState extends State<MoreDeviceInfo> {
  var installLocationInfoList = [
    {"title": 'کاربری موتورخانه', "value": '---'},
    {"title": 'آیا مبدل استخر / جکوزی / گرمایش از کف دارد؟', "value": 'خیر'},
    {"title": 'تعداد دیگ ها', "value": '0'},
    {"title": 'تعداد پمپ های سیرکوله', "value": '0'},
    {"title": 'تعداد منابع کوئلی', "value": '0'},
    {"title": 'تعداد پمپ های منابع کوئلی', "value": '0'},
    {"title": 'تعداد پمپ های آبگرم مصرفی', "value": '0'},
  ];

  @override
  Widget build(BuildContext context) {
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
