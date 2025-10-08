import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/image%20views/image_with_caption.dart';
import 'package:shooka_flutter/utils/scaffolds/back_scaffold.dart';

class ViewsTab extends StatelessWidget {
  const ViewsTab({super.key});

  @override
  Widget build(BuildContext context) {
    const imageList = [
      {
        "name": "Hirkan_1Boiler_1Pump_2Coil",
        "path": "assets/images/views/Hirkan_1Boiler_1Pump_2Coil.png",
      },
      {
        "name": "Hirkan_1Boiler_2Pump_2Coil",
        "path": "assets/images/views/Hirkan_1Boiler_2Pump_2Coil.png",
      },
      {
        "name": "Hirkan_2Boiler_2Pump_2Coil",
        "path": "assets/images/views/Hirkan_2Boiler_2Pump_2Coil.png",
      },
      {
        "name": "Hirkan_2Boiler_3Pump_2Coil_1Hx_2PumpColdSide_2PumpWaterJet",
        "path":
            "assets/images/views/Hirkan_2Boiler_3Pump_2Coil_1Hx_2PumpColdSide_2PumpWaterJet.png",
      },
      {
        "name": "Hirkan_3Boiler_5Pump_1Coil_1",
        "path": "assets/images/views/Hirkan_3Boiler_5Pump_1Coil_1.png",
      },
      {
        "name": "Hirkan_1Boiler_1Pump_2Coil",
        "path": "assets/images/views/Hirkan_1Boiler_1Pump_2Coil.png",
      },
      {
        "name": "Hirkan_1Boiler_2Pump_2Coil",
        "path": "assets/images/views/Hirkan_1Boiler_2Pump_2Coil.png",
      },
      {
        "name": "Hirkan_2Boiler_2Pump_2Coil",
        "path": "assets/images/views/Hirkan_2Boiler_2Pump_2Coil.png",
      },
      {
        "name": "Hirkan_2Boiler_3Pump_2Coil_1Hx_2PumpColdSide_2PumpWaterJet",
        "path":
            "assets/images/views/Hirkan_2Boiler_3Pump_2Coil_1Hx_2PumpColdSide_2PumpWaterJet.png",
      },
      {
        "name": "Hirkan_3Boiler_5Pump_1Coil_1",
        "path": "assets/images/views/Hirkan_3Boiler_5Pump_1Coil_1.png",
      },
      {
        "name": "Hirkan_1Boiler_1Pump_2Coil",
        "path": "assets/images/views/Hirkan_1Boiler_1Pump_2Coil.png",
      },
      {
        "name": "Hirkan_1Boiler_2Pump_2Coil",
        "path": "assets/images/views/Hirkan_1Boiler_2Pump_2Coil.png",
      },
      {
        "name": "Hirkan_2Boiler_2Pump_2Coil",
        "path": "assets/images/views/Hirkan_2Boiler_2Pump_2Coil.png",
      },
      {
        "name": "Hirkan_2Boiler_3Pump_2Coil_1Hx_2PumpColdSide_2PumpWaterJet",
        "path":
            "assets/images/views/Hirkan_2Boiler_3Pump_2Coil_1Hx_2PumpColdSide_2PumpWaterJet.png",
      },
      {
        "name": "Hirkan_3Boiler_5Pump_1Coil_1",
        "path": "assets/images/views/Hirkan_3Boiler_5Pump_1Coil_1.png",
      },
    ];

    return BackScaffold(
      label: "نما ها",
      backLabel: "خانه",
      backRoute: "/home",

      //
      // Body
      //
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 2,
        ),
        itemCount: imageList.length,
        itemBuilder: (context, index) =>
            //
            // Dialog for opening images
            //
            ImageWithCaption(
              imagepath: imageList[index]["path"] as String,
              caption: imageList[index]["name"] as String,
            ),
      ),
    );
  }
}
