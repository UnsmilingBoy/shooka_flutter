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
              itemCount: userSampleData.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: UserTile(
                  onPressed: () => showMaterialModalBottomSheet(
                    enableDrag: false,
                    context: context,
                    builder: (context) => AddUserModal(
                      editMode: true,
                      userName: userSampleData[index]["username"],
                      email: userSampleData[index]["email"],
                      password: userSampleData[index]["password"],
                      phoneNumber: userSampleData[index]["phone_number"],
                      name: userSampleData[index]["name"],
                      repeatPassword: userSampleData[index]["password"],
                      role: userSampleData[index]["role"],
                    ),
                  ),
                  color: Theme.of(context).colorScheme.surface,
                  name: userSampleData[index]["name"] ?? "",
                  role: userSampleData[index]["role"] ?? "",
                  status: userSampleData[index]["status"] ?? "غیر فعال",
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
