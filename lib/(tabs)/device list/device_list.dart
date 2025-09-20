import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shooka_flutter/(tabs)/device%20list/components/add_device_modal.dart';
import 'package:shooka_flutter/(tabs)/device%20list/components/filter_device_modal.dart';
import 'package:shooka_flutter/components/device_tile.dart';
import 'package:shooka_flutter/utils/buttons/my_icon_button.dart';
import 'package:shooka_flutter/utils/layouts/back_scaffold.dart';
import 'package:shooka_flutter/utils/textfields/OutlineTextfield.dart';

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
    const devicesSampleData = [
      {
        "name":
            "موتورخانه 1موتورخانه 1موتورخانه 1موتورخانه 1موتورخانه 1موتورخانه 1موتورخانه 1 1",
        "status": "فعال",
        "city": "تهران",
      },
      {
        "name": "موتورخانه 2",
        "status": "غیرفعال",
        "city": "آملآملآملآملآملآملآملآملآملآملآملآملآملآملآملآملآملآملآمل",
      },
      {"name": "موتورخانه 3", "status": "فعال", "city": "زنجان"},
      {"name": "موتورخانه 4", "status": "فعال", "city": "آمل"},
      {
        "name": "موتورخانه 2",
        "status": "غیرفعال",
        "city": "آملآملآملآملآملآملآملآملآملآملآملآملآملآملآملآملآملآملآمل",
      },
      {"name": "موتورخانه 3", "status": "فعال", "city": "زنجان"},
      {"name": "موتورخانه 4", "status": "فعال", "city": "آمل"},
      {"name": "موتورخانه 3", "status": "فعال", "city": "زنجان"},
      {"name": "موتورخانه 4", "status": "فعال", "city": "آمل"},
    ];

    TextEditingController searchController = TextEditingController();

    return BackScaffold(
      label: "موتورخانه ها",
      backLabel: "خانه",
      backRoute: "/home",

      //
      // Floating Action Button
      //
      floatingActionButton: InkWell(
        borderRadius: BorderRadius.circular(1000),
        onTap: () => showMaterialModalBottomSheet(
          enableDrag: false,
          context: context,
          builder: (context) => AddDeviceModal(),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor,
          ),
          padding: EdgeInsets.all(20),
          child: Icon(Icons.add),
        ),
      ),

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
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: Outlinetextfield(
                      controller: searchController,
                      placeholder: "جستجوی موتوخانه...",
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                  width: 50,
                  child: MyIconButton(
                    onPressed: () => showMaterialModalBottomSheet(
                      enableDrag: false,
                      context: context,
                      builder: (context) => FilterDeviceModal(),
                    ),
                    color: Theme.of(context).colorScheme.secondary,
                    child: Icon(Icons.filter_alt_rounded),
                  ),
                ),
              ],
            ),

            //
            // Device List
            //
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: devicesSampleData.length,
              itemBuilder: (context, index) => Column(
                spacing: 20,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: DeviceTile(
                      name: devicesSampleData[index]["name"] ?? "",
                      city: devicesSampleData[index]["city"] ?? "",
                      status: devicesSampleData[index]["status"] ?? "",
                      color: Theme.of(context).colorScheme.surface,
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
