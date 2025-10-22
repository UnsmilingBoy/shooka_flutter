import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/device%20list/components/add_device_modal.dart';
import 'package:shooka_flutter/(tabs)/device%20list/components/filter_device_modal.dart';
import 'package:shooka_flutter/(tabs)/device%20list/components/device_tile.dart';
import 'package:shooka_flutter/components/tab_header.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
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

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<DeviceProvider>().loadDevices(all: false, page: 1);
    });

    _scrollController.addListener(_onScroll);

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      // Trigger next page when near the end
      final provider = context.read<DeviceProvider>();
      if (!provider.isLoading) {
        provider.devicesNextPage();
      }
    }
  }

  String searchValue = "";

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    final deviceProvider = context.watch<DeviceProvider>();

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
                          status: devices[index].status,
                          color: Theme.of(context).colorScheme.surface,
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
