import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/expansion%20tile/my_expansion_tile.dart';
import 'package:shooka_flutter/utils/image%20views/image_with_caption.dart';

class InstallationLocationInfo extends StatefulWidget {
  const InstallationLocationInfo({super.key});

  @override
  State<InstallationLocationInfo> createState() =>
      _InstallationLocationInfoState();
}

class _InstallationLocationInfoState extends State<InstallationLocationInfo> {
  var installLocationInfoList = [
    {"title": 'رابط اول', "value": '---'},
    {"title": 'تلفن رابط اول', "value": 'خیر'},
    {"title": 'رابط دوم', "value": '---'},
    {"title": 'تلفن رابط دوم', "value": 'خیر'},
    {"title": 'متراژ ساختمان', "value": '---'},
    {"title": 'آدرس', "value": '07/20/1402'},
    {"title": 'استان', "value": 'خیر'},
    {"title": 'شهر', "value": 'خیر'},
  ];

  @override
  Widget build(BuildContext context) {
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
            imagepath: "assets/images/views/Hirkan_1Boiler_1Pump_2Coil.png",
            caption: "عکس ساختمان",
          ),
        ),
      ],
    );
  }
}
