import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/device%20list/components/add_device_modal.dart';
import 'package:shooka_flutter/(tabs)/device%20list/components/filter_device_modal.dart';
import 'package:shooka_flutter/(tabs)/device%20list/components/device_tile.dart';
import 'package:shooka_flutter/components/tab_header.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/utils/floating%20action%20button/add_floating_button.dart';
import 'package:shooka_flutter/utils/loadings/loading.dart';
import 'package:shooka_flutter/utils/scaffolds/back_scaffold.dart';

class DeviceList extends StatefulWidget {
  final bool openAddDevice;

  const DeviceList({super.key, required this.openAddDevice});

  @override
  State<DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  final ScrollController _scrollController = ScrollController();
  late final DeviceProvider _deviceProvider;

  @override
  void initState() {
    super.initState();

    _deviceProvider = context.read<DeviceProvider>();

    Future.microtask(() async {
      await _deviceProvider.loadDevices(all: false, page: 1);
      // Check after initial load completes
      if (mounted) {
        _checkAndLoadMoreIfNeeded();
      }
    });

    _scrollController.addListener(_onScroll);

    // Listen to device provider changes and check if more items needed
    _deviceProvider.addListener(_onDeviceListChanged);

    // Opens the add device modal if the route was "/add_device"
    if (widget.openAddDevice) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showMaterialModalBottomSheet(
          enableDrag: false,
          context: context,
          builder: (context) => AddDeviceModal(),
        );
      });
    }
  }

  void _onDeviceListChanged() {
    // Check after list updates (e.g., after add/edit/delete)
    if (mounted && !_deviceProvider.isLoading) {
      Future.delayed(Duration(milliseconds: 200), () {
        if (mounted) {
          _checkAndLoadMoreIfNeeded();
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _deviceProvider.removeListener(_onDeviceListChanged);
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      // Trigger next page when near the end
      if (!_deviceProvider.isLoading) {
        _deviceProvider.devicesNextPage();
      }
    }
  }

  // Check if viewport has enough items to scroll, if not load more
  void _checkAndLoadMoreIfNeeded() {
    if (!mounted) return;

    // If we have a scroll controller with a position
    if (_scrollController.hasClients) {
      final position = _scrollController.position;

      // If list doesn't fill viewport (no scrolling possible)
      if (position.maxScrollExtent <= 0 &&
          _deviceProvider.devicesPage < _deviceProvider.devicesTotalPages &&
          !_deviceProvider.devicesNextPageLoading) {
        // Load next page and check again
        _deviceProvider.devicesNextPage().then((_) {
          if (mounted) {
            Future.delayed(
              Duration(milliseconds: 100),
              _checkAndLoadMoreIfNeeded,
            );
          }
        });
      }
    } else {
      // If no clients yet, wait a bit and try again
      Future.delayed(Duration(milliseconds: 100), _checkAndLoadMoreIfNeeded);
    }
  }

  String searchValue = "";

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    final deviceProvider = context.watch<DeviceProvider>();
    final generalProvider = context.watch<GeneralProvider>();

    final devices = deviceProvider.devices;

    return BackScaffold(
      label: "موتورخانه ها",
      backLabel: "خانه",
      backRoute: "/home",

      //
      // Floating Action Button
      //
      floatingActionButton: AddFloatingButton(addModal: AddDeviceModal()),

      //
      // Body
      //
      body: Column(
        spacing: 10,
        children: [
          //
          // Header (Search and Filter)
          //
          TabHeader(
            onSubmitted: (value) async {
              setState(() {
                searchValue = value;
              });
              await context.read<DeviceProvider>().loadDevices(
                all: false,
                page: 1,
                search: value,
                // Preserve existing filters
                installer: deviceProvider.lastSelectedInstaller,
                organization: deviceProvider.lastSelectedOrg,
                administration: deviceProvider.lastSelectedAdmin,
                province: deviceProvider.lastSelectedProvince,
                city: deviceProvider.lastSelectedCity,
                plan: deviceProvider.lastSelectedPlan,
                start: deviceProvider.lastStartDate,
                end: deviceProvider.lastEndDate,
              );
            },
            searchController: searchController,
            filterModal: FilterDeviceModal(),
            searchPlaceholder: "جستجوی موتورخانه...",
          ),

          //
          // Searched For (Only appears when the user searches for something)
          //
          if (searchValue != "")
            Row(
              children: [
                Expanded(
                  child: Text(
                    "نتایج جستجو برای موتورخانه ها با نام: $searchValue",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ],
            ),

          //
          // Active Filters Indicator
          //
          if (deviceProvider.filterCount > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimaryFixedVariant,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${deviceProvider.filterCount} فیلتر فعال",
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimaryFixedVariant,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      deviceProvider.clearFilters();
                      await deviceProvider.loadDevices(
                        all: false,
                        page: 1,
                        search: searchValue.isEmpty ? null : searchValue,
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      "پاک کردن فیلترها",
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimaryFixedVariant,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          //
          // Column Headers for Wide Screens
          //
          if (MediaQuery.of(context).size.width > 800)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'نام',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'سازمان',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'نصاب',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'تاریخ نصب',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'شهر',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'وضعیت',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Center(
                      child: Text(
                        'اتصال',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          //
          // Device List
          //
          Expanded(
            child: deviceProvider.isLoading
                ? Center(child: Loading()) // Loading Ui
                : devices.isEmpty
                ? Center(child: Text("موتورخانه ای یافت نشد."))
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: deviceProvider.devicesNextPageLoading
                        ? devices.length + 1
                        : devices.length,
                    itemBuilder: (context, index) {
                      if (index == devices.length &&
                          deviceProvider.devicesNextPageLoading) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: Loading()),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: DeviceTile(
                          deviceId: devices[index].id,
                          name: devices[index].name,
                          org: devices[index].organization,
                          isConnected: devices[index].isConnected,
                          color: Theme.of(context).colorScheme.surface,
                          isFirst:
                              index == 0, // Show tooltip only for first item
                          installationDate: devices[index].createdAt.replaceAll(
                            " ",
                            " - ",
                          ),
                          latLong: devices[index].latLong,
                          address:
                              (generalProvider.filters?["locations"] as List?)
                                  ?.firstWhere(
                                    (location) =>
                                        location["id"] ==
                                        devices[index].location,
                                    orElse: () => null,
                                  )?["location"]?[1] ??
                              "",
                          status: devices[index].status,
                          creator: devices[index].creator,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
