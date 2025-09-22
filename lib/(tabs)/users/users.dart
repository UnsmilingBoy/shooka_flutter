import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/users/components/add_user_modal.dart';
import 'package:shooka_flutter/(tabs)/users/components/filter_users_modal.dart';
import 'package:shooka_flutter/(tabs)/users/components/user_tile.dart';
import 'package:shooka_flutter/components/tab_header.dart';
import 'package:shooka_flutter/utils/floating%20action%20button/add_floating_button.dart';
import 'package:shooka_flutter/utils/scaffolds/back_scaffold.dart';

class UsersTab extends StatelessWidget {
  const UsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    const userSampleData = [
      {
        "name": "محمد تقی‌ زاده",
        "role": "سرپرست",
        "status": "فعال",
        "pfp": "assets/images/profile.jpg",
      },
      {
        "name":
            "محمد محمدی محمدی محمدی محمدی محمدی محمدی محمدی محمدی محمدی محمدی",
        "status": "غیر فعال",
        "role": "نصاب",
        "pfp": "assets/images/profile.jpg",
      },
      {
        "name": "علی رضایی",
        "status": "فعال",
        "role": "نصاب",
        "pfp": "assets/images/profile.jpg",
      },
      {
        "name": "محمد محمدی",
        "status": "فعال",
        "role": "نصاب",
        "pfp": "assets/images/profile.jpg",
      },
      {
        "name": "علی رضایی",
        "status": "فعال",
        "role": "نصاب",
        "pfp": "assets/images/profile.jpg",
      },
      {
        "name": "محمد تقی‌ زاده",
        "role": "سرپرست",
        "status": "فعال",
        "pfp": "assets/images/profile.jpg",
      },
      {
        "name":
            "محمد محمدی محمدی محمدی محمدی محمدی محمدی محمدی محمدی محمدی محمدی",
        "status": "غیر فعال",
        "role": "نصاب",
        "pfp": "assets/images/profile.jpg",
      },
      {
        "name": "علی رضایی",
        "status": "فعال",
        "role": "نصاب",
        "pfp": "assets/images/profile.jpg",
      },
      {
        "name": "محمد محمدی",
        "status": "فعال",
        "role": "نصاب",
        "pfp": "assets/images/profile.jpg",
      },
      {
        "name": "علی رضایی",
        "status": "فعال",
        "role": "نصاب",
        "pfp": "assets/images/profile.jpg",
      },
    ];

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
