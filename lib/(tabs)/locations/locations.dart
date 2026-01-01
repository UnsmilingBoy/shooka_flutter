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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await context.read<GeneralProvider>().fetchLocations(page: 1);
      // Check after initial load completes
      if (mounted) {
        _checkAndLoadMoreIfNeeded();
      }
    });
    _scrollController.addListener(_onScroll);

    // Listen to general provider changes and check if more items needed
    context.read<GeneralProvider>().addListener(_onLocationListChanged);
  }

  void _onLocationListChanged() {
    // Check after list updates (e.g., after add/edit/delete)
    if (mounted && !context.read<GeneralProvider>().fetchLocationsLoading) {
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
    context.read<GeneralProvider>().removeListener(_onLocationListChanged);
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      // Trigger next page when near the end
      final provider = context.read<GeneralProvider>();
      if (!provider.fetchLocationsLoading) {
        provider.locationsNextPage();
      }
    }
  }

  // Check if viewport has enough items to scroll, if not load more
  void _checkAndLoadMoreIfNeeded() {
    if (!mounted) return;

    final provider = context.read<GeneralProvider>();

    // If we have a scroll controller with a position
    if (_scrollController.hasClients) {
      final position = _scrollController.position;

      // If list doesn't fill viewport (no scrolling possible)
      if (position.maxScrollExtent <= 0 &&
          provider.locationsPage < provider.locationsTotalPages &&
          !provider.locationNextPageLoading) {
        // Load next page and check again
        provider.locationsNextPage().then((_) {
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
    final generalProvider = context.watch<GeneralProvider>();
    final locations = generalProvider.locations;
    bool getLoading = generalProvider.fetchLocationsLoading;
    bool nextPageLoading = generalProvider.locationNextPageLoading;

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
                    controller: _scrollController,
                    itemCount: nextPageLoading
                        ? locations.length + 1
                        : locations.length,
                    itemBuilder: (context, index) {
                      if (index == locations.length && nextPageLoading) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: Loading()),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: LocationTile(
                          onPressed: () {
                            final screenWidth = MediaQuery.of(
                              context,
                            ).size.width;
                            final isDesktop = screenWidth > 900;
                            if (isDesktop) {
                              showDialog(
                                context: context,
                                builder: (context) => AddLocationModal(
                                  isEdit: true,
                                  id: locations[index].id,
                                  city: locations[index].city,
                                  province: locations[index].province,
                                ),
                              );
                            } else {
                              showMaterialModalBottomSheet(
                                enableDrag: false,
                                context: context,
                                builder: (context) => AddLocationModal(
                                  isEdit: true,
                                  id: locations[index].id,
                                  city: locations[index].city,
                                  province: locations[index].province,
                                ),
                              );
                            }
                          },

                          color: Theme.of(context).colorScheme.surface,
                          city: locations[index].city,
                          province: locations[index].province,
                          borderRadius: 10,
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
