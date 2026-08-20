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
import 'package:shooka_flutter/services/providers/software_support_provider.dart';
import 'package:shooka_flutter/services/providers/user_provider.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';
import 'package:shooka_flutter/utils/constants.dart';
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
      requests.add(context.read<SoftwareSupportProvider>().loadEvents());
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
    final canSeeOrgs = accessControl.hasAccessTo(AppPanel.orgList);
    final canSeeLocs = accessControl.hasAccessTo(AppPanel.locList);

    final events = context.watch<EventProvider>().events;
    bool eventLoading = context.watch<EventProvider>().fetchLoading;

    final supportProvider = context.watch<SoftwareSupportProvider>();
    final supportEvents = supportProvider.events;
    final supportLoading = supportProvider.fetchLoading;

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

    //
    // Brief list cards
    //
    final eventCard = _buildListCard(
      title: "رویداد ها",
      route: "/events",
      loading: eventLoading,
      emptyText: "رویدادی وجود ندارد.",
      itemCount: events.length,
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
    );

    final supportCard = _buildListCard(
      title: "پشتیبانی نرم افزاری",
      route: "/software_support",
      loading: supportLoading,
      emptyText: "رویدادی وجود ندارد.",
      itemCount: supportEvents.length,
      itemBuilder: (context, index) => EventTile(
        borderRadius: 0,
        timeCreated: supportEvents[index].timestamp,
        message: supportEvents[index].eventCategoryDetails,
        author: supportEvents[index].creator,
        device: supportEvents[index].deviceName,
        title: supportEvents[index].title,
        eventGroupId: supportEvents[index].eventGroupId,
        factorId: supportEvents[index].factorId,
        isCompleted: supportEvents[index].isCompleted,
        completedAt: supportEvents[index].completedAt,
        isSent: supportEvents[index].isSent,
        sentAt: supportEvents[index].sentAt,
        canEdit: false,
        detailBackRoute: "/software_support",
        detailBackLabel: "پشتیبانی نرم افزاری",
        detailRouteName: "/software_support_event_page",
      ),
    );

    final deviceCard = _buildListCard(
      title: "لیست موتورخانه ها",
      route: "/device_list",
      loading: deviceLoading,
      emptyText: "موتورخانه ای وجود ندارد.",
      itemCount: devices.length,
      itemBuilder: (context, index) => DeviceTile(
        index: index + 1,
        plan: devices[index].plan ?? "-",
        deviceId: devices[index].id,
        borderRadius: 0,
        compactMode: true,
        name: devices[index].name,
        org: devices[index].organization,
        isConnected: devices[index].isConnected,
        installationDate: devices[index].createdAt,
        latLong: devices[index].latLong,
        address:
            (generalProvider.filters?["locations"] as List?)?.firstWhere(
              (location) => location["id"] == devices[index].location,
              orElse: () => null,
            )?["location"]?[1] ??
            "",
        status: devices[index].status,
        rawStatus: devices[index].rawStatus,
        rejectionNote: devices[index].rejectionNote,
        creator: devices[index].creator,
      ),
    );

    final accountingCard = _buildListCard(
      title: "فاکتور های ثبت شده",
      route: "/accounting",
      loading: accountingLoading,
      emptyText: "فاکتوری وجود ندارد.",
      itemCount: accountingFactors.length,
      itemBuilder: (context, index) =>
          _HomeFactorTile(factor: accountingFactors[index]),
    );

    return ProfileScaffold(
      name: name,
      username: user?.username ?? "",
      user: user,
      onRefresh: _refreshHomeData,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= kDesktopBreakpoint;
            return Column(
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
                    onTap: () =>
                        Navigator.pushNamed(context, "/rejected_devices"),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
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
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(color: Colors.red),
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
                // Stats
                //
                if (isDesktop)
                  _buildStatsSection(
                    context,
                    constraints.maxWidth,
                    isDesktop,
                    activeDevicesPercentage,
                    rejectedDevicesCount,
                    devices.length,
                    events.length,
                    supportEvents.length,
                    accountingFactors.length,
                    canSeeDevices,
                    canSeeEvents,
                    canSeeAccounting,
                  ),

                //
                // Quick access buttons
                //
                if (isDesktop)
                  _buildQuickAccessSection(
                    context,
                    constraints.maxWidth,
                    isDesktop,
                    canSeeDevices,
                    canSeeEvents,
                    canAddDevice,
                    canAddEvent,
                    canSeeOrgs,
                    canSeeLocs,
                    canSeeAccounting,
                  ),

                //
                // Mobile: quick access buttons above the stats tiles
                //
                if (!isDesktop)
                  _buildQuickAccessSection(
                    context,
                    constraints.maxWidth,
                    isDesktop,
                    canSeeDevices,
                    canSeeEvents,
                    canAddDevice,
                    canAddEvent,
                    canSeeOrgs,
                    canSeeLocs,
                    canSeeAccounting,
                  ),
                if (!isDesktop)
                  _buildStatsSection(
                    context,
                    constraints.maxWidth,
                    isDesktop,
                    activeDevicesPercentage,
                    rejectedDevicesCount,
                    devices.length,
                    events.length,
                    supportEvents.length,
                    accountingFactors.length,
                    canSeeDevices,
                    canSeeEvents,
                    canSeeAccounting,
                  ),

                //
                // Brief lists
                //
                if (isDesktop)
                  Column(
                    spacing: 15,
                    children: [
                      if (canSeeEvents)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 15,
                          children: [
                            Expanded(child: eventCard),
                            Expanded(child: supportCard),
                          ],
                        ),
                      if (canSeeDevices || canSeeAccounting)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 15,
                          children: [
                            if (canSeeDevices) Expanded(child: deviceCard),
                            if (canSeeAccounting)
                              Expanded(child: accountingCard),
                          ],
                        ),
                    ],
                  )
                else
                  Column(
                    spacing: 15,
                    children: [
                      if (canSeeEvents) eventCard,
                      if (canSeeEvents) supportCard,
                      if (canSeeDevices) deviceCard,
                      if (canSeeAccounting) accountingCard,
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    double maxW,
    bool isDesktop,
    num activeDevicesPercentage,
    int rejectedDevicesCount,
    int devicesCount,
    int eventsCount,
    int supportEventsCount,
    int accountingFactorsCount,
    bool canSeeDevices,
    bool canSeeEvents,
    bool canSeeAccounting,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final cards = <Widget>[];

    if (canSeeDevices) {
      if (isDesktop) {
        cards.add(
          _StatCard(
            label: "موتورخانه های متصل",
            // icon: Icons.check_circle_outline,
            color: scheme.secondary,
            onTap: () => Navigator.of(context).pushNamed("/device_list"),
            child: CircularPercentIndicator(
              lineWidth: 7,
              animation: true,
              progressColor: scheme.secondary,
              percent: activeDevicesPercentage / 100,
              radius: 34,
              center: Text("$activeDevicesPercentage%"),
            ),
          ),
        );
      }
      cards.add(
        _StatCard(
          label: "موتورخانه ها",
          value: "$devicesCount",
          icon: Icons.devices,
          color: scheme.primary,
          onTap: () => Navigator.of(context).pushNamed("/device_list"),
        ),
      );
      if (isDesktop) {
        cards.add(
          _StatCard(
            label: "موتورخانه های رد شده",
            value: "$rejectedDevicesCount",
            icon: Icons.cancel_outlined,
            color: scheme.error,
            onTap: () => Navigator.of(context).pushNamed("/rejected_devices"),
          ),
        );
      }
    }

    if (canSeeEvents) {
      cards.add(
        _StatCard(
          label: "رویداد ها",
          value: "$eventsCount",
          icon: Icons.event,
          color: scheme.primary,
          onTap: () => Navigator.of(context).pushNamed("/events"),
        ),
      );
      if (isDesktop) {
        cards.add(
          _StatCard(
            label: "پشتیبانی نرم افزاری",
            value: "$supportEventsCount",
            icon: Icons.support_agent,
            color: scheme.tertiary,
            onTap: () => Navigator.of(context).pushNamed("/software_support"),
          ),
        );
      }
    }

    if (canSeeAccounting && isDesktop) {
      cards.add(
        _StatCard(
          label: "فاکتور های ثبت شده",
          value: "$accountingFactorsCount",
          icon: Icons.receipt_long,
          color: scheme.primary,
          onTap: () => Navigator.of(context).pushNamed("/accounting"),
        ),
      );
    }

    if (cards.isEmpty) return const SizedBox.shrink();

    if (isDesktop) {
      return Row(
        spacing: 15,
        children: [for (final card in cards) Expanded(child: card)],
      );
    }

    final itemWidth = (maxW - 15) / 2;
    return Wrap(
      spacing: 15,
      runSpacing: 15,
      children: [
        for (final card in cards) SizedBox(width: itemWidth, child: card),
      ],
    );
  }

  Widget _buildQuickAccessSection(
    BuildContext context,
    double maxW,
    bool isDesktop,
    bool canSeeDevices,
    bool canSeeEvents,
    bool canAddDevice,
    bool canAddEvent,
    bool canSeeOrgs,
    bool canSeeLocs,
    bool canSeeAccounting,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final buttons = <Widget>[];
    final buttonPadding = isDesktop
        ? const EdgeInsets.symmetric(vertical: 18, horizontal: 12)
        : const EdgeInsets.symmetric(vertical: 14, horizontal: 8);

    void addButton(String route, String label, IconData icon, Color color) {
      buttons.add(
        ContainerButton(
          borderRadius: 10,
          color: color,
          fillWidth: true,
          padding: buttonPadding,
          onPressed: () => Navigator.of(context).pushNamed(route),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 6,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.apply(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (canAddDevice) {
      addButton("/add_device", "افزودن موتورخانه", Icons.add, scheme.primary);
    }
    if (canAddEvent) {
      addButton("/add_event", "افزودن رویداد", Icons.add, scheme.secondary);
    }
    if (isDesktop && canSeeDevices) {
      addButton("/device_list", "موتورخانه ها", Icons.devices, scheme.primary);
    }
    if (isDesktop && canSeeEvents) {
      addButton("/events", "رویداد ها", Icons.event, scheme.secondary);
      addButton(
        "/software_support",
        "پشتیبانی نرم افزاری",
        Icons.support_agent,
        scheme.tertiary,
      );
    }
    // if (canSeeOrgs) {
    //   addButton("/organizations", "سازمان ها", Icons.apartment, scheme.primary);
    // }
    // addButton("/views", "نما ها", Icons.view_list, scheme.secondary);
    // if (canSeeLocs) {
    //   addButton("/locations", "مکان ها", Icons.location_on, scheme.primary);
    // }
    if (isDesktop && canSeeAccounting) {
      addButton(
        "/accounting",
        "حسابداری",
        Icons.account_balance,
        scheme.tertiary,
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    if (isDesktop) {
      return Row(
        spacing: 10,
        children: [for (final button in buttons) Expanded(child: button)],
      );
    }

    final itemWidth = (maxW - 10) / 2;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final button in buttons) SizedBox(width: itemWidth, child: button),
      ],
    );
  }

  Widget _buildListCard({
    required String title,
    required String route,
    required bool loading,
    required String emptyText,
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
  }) {
    return MainmenuContainer(
      borderRadius: 10,
      padding: const EdgeInsets.symmetric(vertical: 20),
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
                  onTap: () => Navigator.pushNamed(context, route),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pushNamed(context, route),
                  child: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),

          //
          // List
          //
          loading
              ? const ShimmerList()
              : itemCount == 0
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Text(emptyText),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(0),
                  itemCount: itemCount > 5 ? 5 : itemCount,
                  itemBuilder: itemBuilder,
                ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String? value;
  final IconData? icon;
  final Color? color;
  final Widget? child;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    this.value,
    this.icon,
    this.color,
    this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: MainmenuContainer(
        height: 150,
        borderRadius: 10,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(icon, color: color ?? scheme.primary, size: 26),
            child ??
                (value != null
                    ? Text(
                        value!,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      )
                    : const SizedBox.shrink()),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
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
