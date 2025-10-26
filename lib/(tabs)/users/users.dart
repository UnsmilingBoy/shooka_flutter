import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/users/components/add_user_modal.dart';
import 'package:shooka_flutter/(tabs)/users/components/filter_users_modal.dart';
import 'package:shooka_flutter/(tabs)/users/components/user_tile.dart';
import 'package:shooka_flutter/components/tab_header.dart';
import 'package:shooka_flutter/services/auth_service.dart';
import 'package:shooka_flutter/services/providers/user_provider.dart';
import 'package:shooka_flutter/utils/floating%20action%20button/add_floating_button.dart';
import 'package:shooka_flutter/utils/loadings/loading.dart';
import 'package:shooka_flutter/utils/scaffolds/back_scaffold.dart';

class UsersTab extends StatefulWidget {
  const UsersTab({super.key});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  final ScrollController _scrollController = ScrollController();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    Future.microtask(() async {
      await context.read<UserProvider>().fetchUsers(page: 1);
      // Check after initial load completes
      if (mounted) {
        _checkAndLoadMoreIfNeeded();
      }
    });

    _scrollController.addListener(_onScroll);

    // Listen to user provider changes and check if more items needed
    context.read<UserProvider>().addListener(_onUserListChanged);
  }

  void _onUserListChanged() {
    // Check after list updates (e.g., after add/edit/delete)
    if (mounted && !context.read<UserProvider>().fetchUsersLoading) {
      Future.delayed(Duration(milliseconds: 200), () {
        if (mounted) {
          _checkAndLoadMoreIfNeeded();
        }
      });
    }
  }

  Future<void> _loadCurrentUserId() async {
    final auth = context.read<AuthService>();
    final userId = await auth.storage.read(key: 'userId');
    setState(() {
      _currentUserId = userId;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    context.read<UserProvider>().removeListener(_onUserListChanged);
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      // Trigger next page when near the end
      final provider = context.read<UserProvider>();
      if (!provider.fetchUsersLoading) {
        provider.usersNextPage();
      }
    }
  }

  // Check if viewport has enough items to scroll, if not load more
  void _checkAndLoadMoreIfNeeded() {
    if (!mounted) return;

    final provider = context.read<UserProvider>();

    // If we have a scroll controller with a position
    if (_scrollController.hasClients) {
      final position = _scrollController.position;

      // If list doesn't fill viewport (no scrolling possible)
      if (position.maxScrollExtent <= 0 &&
          provider.usersPage < provider.usersTotalPages &&
          !provider.usersNextPageLoading) {
        // Load next page and check again
        provider.usersNextPage().then((_) {
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
    final userProvider = context.watch<UserProvider>();
    final allUsers = userProvider.users;

    // Filter out the current user from the list
    final users = _currentUserId != null
        ? allUsers
              .where((user) => user.id.toString() != _currentUserId)
              .toList()
        : allUsers;

    bool getLoading = userProvider.fetchUsersLoading;
    bool nextPageLoading = userProvider.usersNextPageLoading;

    TextEditingController searchController = TextEditingController();

    return BackScaffold(
      backLabel: "خانه",
      backRoute: "/home",
      label: "کاربران",

      //
      // Floating Action Button
      //
      floatingActionButton: AddFloatingButton(addModal: AddUserModal()),

      //
      // Body
      //
      body: Column(
        spacing: 10,
        children: [
          //
          // Header (search + filter)
          //
          TabHeader(
            onSubmitted: (value) async {
              setState(() {
                searchValue = value;
              });
              await context.read<UserProvider>().fetchUsers(
                page: 1,
                search: value,
              );
            },
            searchController: searchController,
            filterModal: FilterUsersModal(),
            searchPlaceholder: "جستجوی کاربر...",
          ),

          //
          // Searched For (Only appears when the user searches for something)
          //
          if (searchValue != "")
            Row(
              children: [
                Expanded(
                  child: Text(
                    "نتایج جستجو برای کاربر ها با نام: $searchValue",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ],
            ),

          //
          // List of users
          //
          Expanded(
            child: getLoading
                ? Center(child: Loading())
                : users.isEmpty
                ? Center(child: Text("کاربری یافت نشد."))
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: nextPageLoading
                        ? users.length + 1
                        : users.length,
                    itemBuilder: (context, index) {
                      if (index == users.length && nextPageLoading) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: Loading()),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: UserTile(
                          onPressed: () => showMaterialModalBottomSheet(
                            enableDrag: false,
                            context: context,
                            builder: (context) => AddUserModal(
                              editMode: true,
                              id: users[index].id,
                              userName: users[index].username,
                              email: users[index].email,
                              phoneNumber: users[index].phoneNumber,
                              name: users[index].firstName,
                              imageHref: users[index].profileHref,
                              role: users[index].role,
                            ),
                          ),
                          color: Theme.of(context).colorScheme.surface,
                          name: users[index].firstName,
                          imagePath: users[index].profileHref,
                          role: users[index].role,
                          status: users[index].isActive.toString(),
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
