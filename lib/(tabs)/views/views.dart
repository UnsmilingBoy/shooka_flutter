import 'package:flutter/material.dart';
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
        itemBuilder: (context, index) => Stack(
          children: [
            //
            // View Image
            //
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imageList[index]["path"] as String,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            //
            // View Name
            //
            Positioned(
              bottom: 0,
              left: 0,
              right: 0, // <-- fill width
              child: Container(
                padding: const EdgeInsets.all(8), // optional padding
                color: Colors.black.withAlpha(150),
                child: Text(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  imageList[index]["name"] as String,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
