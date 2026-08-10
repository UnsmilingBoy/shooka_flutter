import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/device%20list/components/device_tile.dart';
import 'package:shooka_flutter/(tabs)/event%20list/components/event_tile.dart';
import 'package:shooka_flutter/components/shimmer_list.dart';
import 'package:shooka_flutter/models/app_panel.dart';
import 'package:shooka_flutter/models/factor_data_class.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/services/providers/event_provider.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/services/providers/accounting_provider.dart';
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
      _refreshHomeData();
    });
  }

  Future<void> _refreshHomeData() async {
    final userProvider = context.read<UserProvider>();
    await userProvider.loadUserProfile();

    if (!mounted) return;

    final accessControl = userProvider.accessControl;
    final canSeeDevices = accessControl.hasAccessTo(AppPanel.deviceList);
    final canSeeEvents = accessControl.hasAccessTo(AppPanel.eventList);
    final canSeeAccounting = accessControl.hasAccessTo(AppPanel.accounting);

    final requests = <Future<void>>[];

    if (canSeeDevices) {
      requests.add(context.read<GeneralProvider>().fetchFilters());
      requests.add(
        context.read<DeviceProvider>().loadDevices(all: false, page: 1),
      );
    }

    if (canSeeEvents) {
      requests.add(context.read<EventProvider>().loadEvents());
    }

    if (canSeeAccounting) {
      requests.add(context.read<AccountingProvider>().loadFactors());
    }

    await Future.wait(requests);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;
    final accessControl = userProvider.accessControl;
    final name = "${user?.firstName} ${user?.lastName}";

    final canSeeDevices = accessControl.hasAccessTo(AppPanel.deviceList);
    final canSeeEvents = accessControl.hasAccessTo(AppPanel.eventList);
    final canAddDevice = accessControl.hasAccessTo(
      AppPanel.addDeviceFunctionality,
    );
    final canAddEvent = accessControl.hasAccessTo(
      AppPanel.addEventFunctionality,
    );
    final canSeeAccounting = accessControl.hasAccessTo(AppPanel.accounting);

    final events = context.watch<EventProvider>().events;
    bool eventLoading = context.watch<EventProvider>().fetchLoading;

    final devices = context.watch<DeviceProvider>().devices;
    final generalProvider = context.watch<GeneralProvider>();
    final activeDevicesPercentage = context
        .watch<DeviceProvider>()
        .activeDevicesPercentage;
    final rejectedDevicesCount = context
        .watch<DeviceProvider>()
        .rejectedDevicesCount;

    bool deviceLoading = context.watch<DeviceProvider>().isLoading;

    final accountingFactors = context.watch<AccountingProvider>().factors;
    bool accountingLoading = context.watch<AccountingProvider>().fetchLoading;

    return ProfileScaffold(
      name: name,
      username: user?.username ?? "",
      onRefresh: _refreshHomeData,
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

            // Rejected devices warning
            if (rejectedDevicesCount > 0 && canSeeDevices)
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, "/rejected_devices"),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "شما $rejectedDevicesCount موتورخانه رد شده دارید. برای مشاهده کلیک کنید.",
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium?.copyWith(color: Colors.red),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.red,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

            //
            // A Row With Two Container Tiles Providing Some Info (Boilers Status and count)
            //
            if (canSeeDevices || canAddDevice || canAddEvent)
              SizedBox(
                height: 135,
                child: Row(
                  spacing: 15,
                  children: [
                    //
                    // Active Boilers Info Tile
                    //
                    if (canSeeDevices)
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
                    if (canAddDevice || canAddEvent)
                      Expanded(
                        child: Column(
                          spacing: 10,
                          children: [
                            if (canAddDevice)
                              Expanded(
                                child: ContainerButton(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: 10,
                                  fillWidth: true,
                                  child: Text(
                                    "افزودن موتورخانه",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.apply(color: Colors.white),
                                  ),
                                  onPressed: () => Navigator.of(
                                    context,
                                  ).pushNamed("/add_device"),
                                ),
                              ),
                            if (canAddEvent)
                              Expanded(
                                child: ContainerButton(
                                  padding: EdgeInsets.all(10),
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                  borderRadius: 10,
                                  fillWidth: true,
                                  child: Text(
                                    "افزودن رویداد",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.apply(color: Colors.white),
                                  ),
                                  onPressed: () => Navigator.of(
                                    context,
                                  ).pushNamed("/add_event"),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

            //
            // Brief Events List
            //
            if (canSeeEvents)
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
                            onTap: () =>
                                Navigator.pushNamed(context, "/events"),
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
                              eventGroupId: events[index].eventGroupId,
                              factorId: events[index].factorId,
                              isCompleted: events[index].isCompleted,
                              completedAt: events[index].completedAt,
                              isSent: events[index].isSent,
                              sentAt: events[index].sentAt,
                            ),
                          ),
                  ],
                ),
              ),

            //
            // Brief Device List
            //
            if (canSeeDevices)
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
                              plan: devices[index].plan ?? "-",
                              deviceId: devices[index].id,
                              borderRadius: 0,
                              name: devices[index].name,
                              org: devices[index].organization,
                              isConnected: devices[index].isConnected,
                              installationDate: devices[index].createdAt,
                              latLong: devices[index].latLong,
                              address:
                                  (generalProvider.filters?["locations"]
                                          as List?)
                                      ?.firstWhere(
                                        (location) =>
                                            location["id"] ==
                                            devices[index].location,
                                        orElse: () => null,
                                      )?["location"]?[1] ??
                                  "",
                              status: devices[index].status,
                              rawStatus: devices[index].rawStatus,
                              rejectionNote: devices[index].rejectionNote,
                              creator: devices[index].creator,
                            ),
                          ),
                  ],
                ),
              ),

            //
            // Brief Accounting (Sent Invoices) List
            //
            if (canSeeAccounting)
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
                                Navigator.pushNamed(context, "/accounting"),
                            child: Text(
                              "فاکتور های ثبت شده",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          InkWell(
                            onTap: () =>
                                Navigator.pushNamed(context, "/accounting"),
                            child: Icon(Icons.chevron_right_rounded),
                          ),
                        ],
                      ),
                    ),

                    //
                    // Accounting Factors List
                    //
                    accountingLoading
                        ? ShimmerList()
                        : accountingFactors.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 50),
                            child: Text("فاکتوری وجود ندارد."),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.all(0),
                            itemCount: accountingFactors.length > 5
                                ? 5
                                : accountingFactors.length,
                            itemBuilder: (context, index) => _HomeFactorTile(
                              factor: accountingFactors[index],
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

class _HomeFactorTile extends StatelessWidget {
  final Factor factor;
  const _HomeFactorTile({required this.factor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, "/accounting"),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Factor number
            Expanded(
              flex: 2,
              child: Text(
                'فاکتور: ${factor.factorNumber}',
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Groups count
            Expanded(
              child: Row(
                spacing: 4,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.groups_rounded,
                    size: 14,
                    color: Theme.of(context).hintColor,
                  ),
                  Text(
                    '${factor.groups.length}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            // Print status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: factor.isPrinted
                    ? Colors.green.withOpacity(0.15)
                    : Colors.grey.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                factor.isPrinted ? 'چاپ شده' : 'چاپ نشده',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: factor.isPrinted ? Colors.green : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
