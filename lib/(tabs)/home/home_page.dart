import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/device%20list/components/device_tile.dart';
import 'package:shooka_flutter/(tabs)/event%20list/components/event_tile.dart';
import 'package:shooka_flutter/components/shimmer_list.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/services/providers/event_provider.dart';
import 'package:shooka_flutter/services/providers/user_provider.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';
import 'package:shooka_flutter/utils/containers/mainmenu_container.dart';
import 'package:shooka_flutter/utils/scaffolds/profile_scaffold.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<EventProvider>().loadEvents(all: true);
      context.read<DeviceProvider>().loadDevices(all: false, page: 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final name = "${user?.firstName} ${user?.lastName}";

    final events = context.watch<EventProvider>().events;
    bool eventLoading = context.watch<EventProvider>().fetchLoading;

    final devices = context.watch<DeviceProvider>().devices;
    final activeDevicesPercentage = context
        .watch<DeviceProvider>()
        .activeDevicesPercentage;

    bool deviceLoading = context.watch<DeviceProvider>().isLoading;

    return ProfileScaffold(
      image: user?.profileHref ?? "",
      name: name,
      username: user?.username ?? "",
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          spacing: 15,
          children: [
            Row(
              children: [
                Text(
                  "خوش آمدید $name!",
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
                            Text("موتورخانه های متصل"),
                            CircularPercentIndicator(
                              lineWidth: 7,
                              animation: true,
                              progressColor: Theme.of(
                                context,
                              ).colorScheme.secondary,

                              percent: activeDevicesPercentage / 100,
                              radius: 40,
                              center: Text("$activeDevicesPercentage%"),
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
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.apply(color: Colors.white),
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
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.apply(color: Colors.white),
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
                  eventLoading
                      ? ShimmerList()
                      : events.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50),
                          child: Text("رویدادی وجود ندارد."),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.all(0),
                          itemCount: events.length > 5 ? 5 : events.length,
                          itemBuilder: (context, index) => EventTile(
                            borderRadius: 0,
                            timeCreated: events[index].timestamp,
                            message: events[index].eventCategoryDetails,
                            author: events[index].creator,
                            device: events[index].deviceName,
                            title: events[index].title,
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
                  deviceLoading
                      ? ShimmerList()
                      : devices.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50),
                          child: Text("موتورخانه ای وجود ندارد."),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.all(0),
                          itemCount: devices.length > 5 ? 5 : devices.length,
                          itemBuilder: (context, index) => DeviceTile(
                            deviceId: devices[index].id,
                            borderRadius: 0,
                            name: devices[index].name,
                            org: devices[index].organization,
                            status: devices[index].isConnected,
                            installationDate: devices[index].createdAt,
                            address: "devices[index].city",
                            serialNumber: "devices[index].serialNumber",
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
