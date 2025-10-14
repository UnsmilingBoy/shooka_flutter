import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/device%20page/installation%20info/complete_dp_installation_info.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/utils/expansion%20tile/my_expansion_tile.dart';
import 'package:shooka_flutter/utils/image%20views/image_with_caption.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
    LatLng? deviceLatLng;
    final latLongStr = basicData?.latLong;
    if (latLongStr != null && latLongStr.isNotEmpty) {
      final latLongParts = latLongStr.split(',');
      if (latLongParts.length == 2) {
        final lat = double.tryParse(latLongParts[0].trim());
        final lng = double.tryParse(latLongParts[1].trim());
        if (lat != null && lng != null) {
          deviceLatLng = LatLng(lat, lng);
        }
      }
    }

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
      completeOnPressed: () async => showMaterialModalBottomSheet(
        context: context,
        builder: (context) => const CompleteDpInstallationInfo(),
      ),
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

        if (deviceLatLng != null)
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            height: 180,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: deviceLatLng,
                  initialZoom: 14,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=o0BuBFntqzU1CidazAOK',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: deviceLatLng,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
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
