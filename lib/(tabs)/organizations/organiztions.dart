import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/organizations/components/add_org_modal.dart';
import 'package:shooka_flutter/(tabs)/organizations/components/org_tile.dart';
import 'package:shooka_flutter/components/tab_header.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/utils/floating%20action%20button/add_floating_button.dart';
import 'package:shooka_flutter/utils/loadings/loading.dart';
import 'package:shooka_flutter/utils/scaffolds/back_scaffold.dart';

class OrganiztionsTab extends StatefulWidget {
  const OrganiztionsTab({super.key});

  @override
  State<OrganiztionsTab> createState() => _OrganiztionsTabState();
}

class _OrganiztionsTabState extends State<OrganiztionsTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await context.read<GeneralProvider>().fetchOrganizations(page: 1);
      // Check after initial load completes
      if (mounted) {
        _checkAndLoadMoreIfNeeded();
      }
    });
    _scrollController.addListener(_onScroll);
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
      final provider = context.read<GeneralProvider>();
      if (!provider.fetchOrganizationsLoading) {
        provider.orgNextPage();
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
          provider.orgPage < provider.orgTotalPages &&
          !provider.orgNextPageLoading) {
        // Load next page and check again
        provider.orgNextPage().then((_) {
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
    final organizations = context.watch<GeneralProvider>().organizations;
    final generalProvider = context.watch<GeneralProvider>();

    bool nextPageLoading = generalProvider.orgNextPageLoading;
    bool getLoading = context
        .watch<GeneralProvider>()
        .fetchOrganizationsLoading;

    TextEditingController searchController = TextEditingController();

    return BackScaffold(
      backLabel: "خانه",
      backRoute: "/home",
      label: "سازمان ها",

      //
      // Floating Action Button
      //
      floatingActionButton: AddFloatingButton(
        addModal: AddOrgModal(isEdit: false),
      ),

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
              await context.read<GeneralProvider>().fetchOrganizations(
                page: 1,
                search: value,
              );
            },
            searchController: searchController,
            noFilter: true,
            searchPlaceholder: "جستجوی سازمان...",
          ),

          //
          // Searched For (Only appears when the user searches for something)
          //
          if (searchValue != "")
            Row(
              children: [
                Expanded(
                  child: Text(
                    "نتایج جستجو برای سازمان ها با نام: $searchValue",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ],
            ),

          //
          // Org List
          //
          Expanded(
            child: getLoading
                ? Center(child: Loading())
                : organizations.isEmpty
                ? Center(child: Text("سازمانی یافت نشد."))
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: nextPageLoading
                        ? organizations.length + 1
                        : organizations.length,
                    itemBuilder: (context, index) {
                      if (index == organizations.length && nextPageLoading) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: Loading()),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: OrgTile(
                          onPressed: () => showMaterialModalBottomSheet(
                            enableDrag: false,
                            context: context,
                            builder: (context) => AddOrgModal(
                              isEdit: true,
                              id: organizations[index].id,
                              name: organizations[index].name,
                              parent: organizations[index].administration,
                            ),
                          ),
                          color: Theme.of(context).colorScheme.surface,
                          orgName: organizations[index].name,
                          orgParent: organizations[index].administration,
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
