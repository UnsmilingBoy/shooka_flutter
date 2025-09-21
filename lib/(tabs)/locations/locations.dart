import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/locations/components/add_location_modal.dart';
import 'package:shooka_flutter/(tabs)/locations/components/filter_locations_modal.dart';
import 'package:shooka_flutter/(tabs)/locations/components/location_tile.dart';
import 'package:shooka_flutter/components/tab_header.dart';
import 'package:shooka_flutter/utils/floating%20action%20button/add_floating_button.dart';
import 'package:shooka_flutter/utils/scaffolds/back_scaffold.dart';

class LocationsTab extends StatelessWidget {
  const LocationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    const locationsSampleData = [
      {"city": "بوئین زهرا", "province": "قزوین"},
      {"city": "ساوه", "province": "مرکزی"},
      {"city": "بندرگز", "province": "گلستان"},
      {"city": "آمل", "province": "مازندران"},
      {"city": "بوئین زهرا", "province": "قزوین"},
      {"city": "ساوه", "province": "مرکزی"},
      {"city": "بندرگز", "province": "گلستان"},
      {"city": "آمل", "province": "مازندران"},
      {"city": "بوئین زهرا", "province": "قزوین"},
      {"city": "ساوه", "province": "مرکزی"},
      {"city": "بندرگز", "province": "گلستان"},
      {"city": "آمل", "province": "مازندران"},
      {"city": "بوئین زهرا", "province": "قزوین"},
      {"city": "ساوه", "province": "مرکزی"},
      {"city": "بندرگز", "province": "گلستان"},
      {"city": "آمل", "province": "مازندران"},
    ];

    TextEditingController searchController = TextEditingController();

    return BackScaffold(
      backLabel: "خانه",
      backRoute: "/home",
      label: "مکان ها",

      //
      // Add Floating Button
      //
      floatingActionButton: AddFloatingButton(addModal: AddLocationModal()),

      //
      // Body
      //
      body: SingleChildScrollView(
        child: Column(
          children: [
            //
            // Header (Search and filter)
            //
            TabHeader(
              searchController: searchController,
              filterModal: FilterLocationsModal(),
              searchPlaceholder: "جستجوی مکان...",
            ),

            //
            // List of locations
            //
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: locationsSampleData.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: LocationTile(
                  color: Theme.of(context).colorScheme.surface,
                  city: locationsSampleData[index]["city"] ?? "",
                  province: locationsSampleData[index]["province"] ?? "",
                  borderRadius: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
