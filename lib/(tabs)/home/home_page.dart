import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shooka_flutter/(tabs)/device%20list/components/device_tile.dart';
import 'package:shooka_flutter/(tabs)/event%20list/components/event_tile.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';
import 'package:shooka_flutter/utils/containers/mainmenu_container.dart';
import 'package:shooka_flutter/utils/sample_datas.dart';
import 'package:shooka_flutter/utils/scaffolds/profile_scaffold.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileScaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          spacing: 15,
          children: [
            Row(
              children: [
                Text(
                  "خوش آمدید سپنتا شفیع زاده!",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),

            //
            // A Row With Two Container Tiles Providing Some Info (Boilers Status and count)
            //
            SizedBox(
              height: 135,
              child: Row(
                spacing: 15,
                children: [
                  //
                  // Active Boilers Info Tile
                  //
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          Navigator.of(context).pushNamed("/device_list"),
                      child: MainmenuContainer(
                        borderRadius: 10,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          spacing: 10,
                          children: [
                            Text("موتورخانه های فعال"),
                            CircularPercentIndicator(
                              lineWidth: 7,
                              animation: true,
                              progressColor: Theme.of(
                                context,
                              ).colorScheme.secondary,

                              percent: 25 / 27,
                              radius: 40,
                              center: Text("25/27"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  //
                  // Quick Access Tile
                  //
                  Expanded(
                    child: Column(
                      spacing: 10,
                      children: [
                        Expanded(
                          child: ContainerButton(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: 10,
                            fillWidth: true,
                            child: Text(
                              "افزودن موتورخانه",
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            onPressed: () =>
                                Navigator.of(context).pushNamed("/add_device"),
                          ),
                        ),
                        Expanded(
                          child: ContainerButton(
                            padding: EdgeInsets.all(10),
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: 10,
                            fillWidth: true,
                            child: Text(
                              "افزودن رویداد",
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            onPressed: () =>
                                Navigator.of(context).pushNamed("/add_event"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            //
            // Brief Organization List and Add Organization Button
            //
            MainmenuContainer(
              padding: EdgeInsets.symmetric(vertical: 20),
              borderRadius: 10,
              child: Column(
                spacing: 15,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "رویداد ها",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        InkWell(
                          onTap: () => Navigator.pushNamed(context, "/events"),
                          child: Icon(Icons.chevron_right_rounded),
                        ),
                      ],
                    ),
                  ),

                  //
                  // Events List
                  //
                  logsSampleData.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50),
                          child: Text("رویدادی وجود ندارد."),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.all(0),
                          itemCount: 5,
                          itemBuilder: (context, index) => EventTile(
                            borderRadius: 0,
                            eventId: logsSampleData[index]["event_id"] as int,
                            author: logsSampleData[index]["author"] as String,
                            device: logsSampleData[index]["device"] as String,
                            title: logsSampleData[index]["title"] as String,
                          ),
                        ),
                ],
              ),
            ),

            //
            // Brief Device List and Add Device Button
            //
            MainmenuContainer(
              borderRadius: 10,
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                spacing: 15,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () =>
                              Navigator.pushNamed(context, "/device_list"),
                          child: Text(
                            "لیست موتورخانه ها",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        InkWell(
                          onTap: () =>
                              Navigator.pushNamed(context, "/device_list"),
                          child: Icon(Icons.chevron_right_rounded),
                        ),
                      ],
                    ),
                  ),

                  //
                  // Device List
                  //
                  devicesSampleData.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50),
                          child: Text("موتورخانه ای وجود ندارد."),
                        )
                      : Padding(
                          padding: EdgeInsets.zero,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.all(0),
                            itemCount: 5,
                            itemBuilder: (context, index) => DeviceTile(
                              deviceId:
                                  devicesSampleData[index]["device_id"] as int,
                              borderRadius: 0,
                              name: devicesSampleData[index]["name"] as String,
                              city: devicesSampleData[index]["city"] as String,
                              status:
                                  devicesSampleData[index]["status"] as String,
                            ),
                          ),
                        ),

                  //
                  // Add Device Button
                  //
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: ContainerButton(
                      fillWidth: true,
                      onPressed: () {
                        Navigator.pushNamed(context, "/add_device");
                      },
                      padding: EdgeInsets.all(10),
                      color: Theme.of(context).primaryColor,
                      child: Row(
                        spacing: 5,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 18),
                          Text(
                            "افزودن موتورخانه",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
