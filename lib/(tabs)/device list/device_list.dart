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
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<DeviceProvider>().loadDevices();
    });

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
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    final deviceProvider = context.watch<DeviceProvider>();

    if (deviceProvider.isLoading) {
      return const Scaffold(body: Center(child: Loading()));
    }

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
      body: SingleChildScrollView(
        child: Column(
          spacing: 10,
          children: [
            //
            // Header (Search and Filter)
            //
            TabHeader(
              searchController: searchController,
              filterModal: FilterDeviceModal(),
              searchPlaceholder: "جستجوی موتورخانه...",
            ),
            //
            // Device List
            //
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: devices.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: DeviceTile(
                  deviceId: devices[index].id,
                  name: devices[index].name,
                  org: devices[index].organization,
                  status: devices[index].status,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
