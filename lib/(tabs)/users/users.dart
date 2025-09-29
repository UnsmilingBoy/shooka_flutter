import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shooka_flutter/(tabs)/users/components/add_user_modal.dart';
import 'package:shooka_flutter/(tabs)/users/components/filter_users_modal.dart';
import 'package:shooka_flutter/(tabs)/users/components/user_tile.dart';
import 'package:shooka_flutter/components/tab_header.dart';
import 'package:shooka_flutter/utils/floating%20action%20button/add_floating_button.dart';
import 'package:shooka_flutter/utils/sample_datas.dart';
import 'package:shooka_flutter/utils/scaffolds/back_scaffold.dart';

class UsersTab extends StatelessWidget {
  const UsersTab({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        child: Column(
          spacing: 10,
          children: [
            //
            // Header (search + filter)
            //
            TabHeader(
              searchController: searchController,
              filterModal: FilterUsersModal(),
              searchPlaceholder: "جستجوی کاربر...",
            ),

            //
            // List of users
            //
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: usersSampleData.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: UserTile(
                  onPressed: () => showMaterialModalBottomSheet(
                    enableDrag: false,
                    context: context,
                    builder: (context) => AddUserModal(
                      editMode: true,
                      userName: usersSampleData[index]["username"],
                      email: usersSampleData[index]["email"],
                      password: usersSampleData[index]["password"],
                      phoneNumber: usersSampleData[index]["phone_number"],
                      name: usersSampleData[index]["name"],
                      repeatPassword: usersSampleData[index]["password"],
                      role: usersSampleData[index]["role"],
                    ),
                  ),
                  color: Theme.of(context).colorScheme.surface,
                  name: usersSampleData[index]["name"] ?? "",
                  role: usersSampleData[index]["role"] ?? "",
                  status: usersSampleData[index]["status"] ?? "غیر فعال",
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
