import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/locations/components/add_location_modal.dart';
import 'package:shooka_flutter/(tabs)/locations/components/location_tile.dart';
import 'package:shooka_flutter/components/tab_header.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/utils/floating%20action%20button/add_floating_button.dart';
import 'package:shooka_flutter/utils/loadings/loading.dart';
import 'package:shooka_flutter/utils/scaffolds/back_scaffold.dart';

class LocationsTab extends StatefulWidget {
  const LocationsTab({super.key});

  @override
  State<LocationsTab> createState() => _LocationsTabState();
}

class _LocationsTabState extends State<LocationsTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<GeneralProvider>().fetchLocations(page: 1);
    });
  }

  String searchValue = "";

  @override
  Widget build(BuildContext context) {
    final locations = context.watch<GeneralProvider>().locations;
    bool getLoading = context.watch<GeneralProvider>().fetchLocationsLoading;

    TextEditingController searchController = TextEditingController();

    return BackScaffold(
      backLabel: "خانه",
      backRoute: "/home",
      label: "مکان ها",

      //
      // Add Floating Button
      //
      floatingActionButton: AddFloatingButton(
        addModal: AddLocationModal(isEdit: false),
      ),

      //
      // Body
      //
      body: Column(
        spacing: 10,
        children: [
          //
          // Header (Search and filter)
          //
          TabHeader(
            onSubmitted: (value) async {
              setState(() {
                searchValue = value;
              });
              await context.read<GeneralProvider>().fetchLocations(
                page: 1,
                search: value,
              );
            },
            searchController: searchController,
            noFilter: true,
            searchPlaceholder: "جستجوی مکان...",
          ),

          //
          // Searched For (Only appears when the user searches for something)
          //
          if (searchValue != "")
            Row(
              children: [
                Expanded(
                  child: Text(
                    "نتایج جستجو برای مکان ها با نام: $searchValue",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ],
            ),

          //
          // List of locations
          //
          Expanded(
            child: getLoading
                ? Center(child: Loading())
                : locations.isEmpty
                ? Center(child: Text("مکانی یافت نشد."))
                : ListView.builder(
                    itemCount: locations.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: LocationTile(
                        onPressed: () => showMaterialModalBottomSheet(
                          enableDrag: false,
                          context: context,
                          builder: (context) => AddLocationModal(
                            isEdit: true,
                            id: locations[index].id,
                            city: locations[index].city,
                            province: locations[index].province,
                          ),
                        ),

                        color: Theme.of(context).colorScheme.surface,
                        city: locations[index].city,
                        province: locations[index].province,
                        borderRadius: 10,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
