import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/profile/components/change_password_modal.dart';
import 'package:shooka_flutter/(tabs)/profile/components/edit_profile_modal.dart';
import 'package:shooka_flutter/services/auth_service.dart';
import 'package:shooka_flutter/services/providers/user_provider.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';
import 'package:shooka_flutter/utils/loadings/loading.dart';
import 'package:shooka_flutter/utils/scaffolds/back_scaffold.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // call provider method after widget is ready
    Future.microtask(() {
      context.read<UserProvider>().loadUserProfile();
    });
  }

  bool logOutLoading = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    if (userProvider.loadUserLoading) {
      return const Scaffold(body: Center(child: Loading()));
    }

    if (userProvider.error != null) {
      return Scaffold(
        body: Center(child: Text("Error: ${userProvider.error}")),
      );
    }

    final user = userProvider.user;

    final name = "${user?.firstName} ${user?.lastName}";

    final tiles = [
      {"title": "نام", "icon": Icon(Icons.label), "value": name},
      {
        "title": "نقش",
        "icon": Icon(Icons.badge),
        "value": user?.userRole.userRoleLabel,
      },
      {
        "title": "نام کاربری",
        "icon": Icon(Icons.person_rounded),
        "value": user?.username,
      },
      {
        "title": "شماره همراه",
        "icon": Icon(Icons.phone),
        "value": user?.phoneNumber,
      },
      {
        "title": "ایمیل",
        "icon": Icon(Icons.email),
        "value": user?.email ?? "بدون ایمیل",
      },
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BackScaffold(
        label: "حساب کاربری",
        backLabel: "خانه",
        backRoute: "/home",
        //
        // Body
        //
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 15,
              children: [
                //
                // Profile Pic And Name
                //
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 7.0),
                          child: GestureDetector(
                            onTap: () => showMaterialModalBottomSheet(
                              enableDrag: false,
                              context: context,
                              builder: (context) => EditProfileModal(
                                email: user.email,
                                name: name,
                                phoneNumber: user.phoneNumber,
                                username: user.username,
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              radius: 60,
                              child: Text(
                                user!.firstName.isNotEmpty
                                    ? user.firstName[0].toUpperCase()
                                    : "U",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.apply(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          user.userRole.userRoleLabel,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),

                //
                // List of items
                //
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: tiles.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: ListTile(
                      onTap: () => showMaterialModalBottomSheet(
                        enableDrag: false,
                        context: context,
                        builder: (context) => EditProfileModal(
                          email: user.email,
                          name: name,
                          phoneNumber: user.phoneNumber,
                          username: user.username,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 5),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            spacing: 5,
                            children: [
                              tiles[index]["icon"] as Widget,
                              Text(
                                "${tiles[index]["title"]}:",
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ],
                          ),
                          Expanded(
                            child: Text(
                              "${tiles[index]["value"]}",
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.apply(color: Theme.of(context).hintColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                //
                // Bottom Buttons
                //
                Column(
                  spacing: 10,
                  children: [
                    //
                    // Edit Profile Button
                    //
                    ContainerButton(
                      color: Theme.of(context).primaryColor,
                      borderRadius: 10,
                      padding: EdgeInsets.all(15),
                      fillWidth: true,
                      child: Row(
                        spacing: 5,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit, size: 18, color: Colors.white),
                          Text(
                            "ویرایش",
                            style: Theme.of(
                              context,
                            ).textTheme.labelLarge?.apply(color: Colors.white),
                          ),
                        ],
                      ),
                      onPressed: () => showMaterialModalBottomSheet(
                        enableDrag: false,
                        context: context,
                        builder: (context) => EditProfileModal(
                          email: user.email,
                          name: name,
                          phoneNumber: user.phoneNumber,
                          username: user.username,
                        ),
                      ),
                    ),

                    Row(
                      spacing: 10,
                      children: [
                        //
                        // Change Password Button
                        //
                        Expanded(
                          child: ContainerButton(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: 10,
                            padding: EdgeInsets.all(15),
                            child: Row(
                              spacing: 5,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.password_outlined,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                Text(
                                  "تغییر رمز عبور",
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.apply(color: Colors.white),
                                ),
                              ],
                            ),
                            onPressed: () => showMaterialModalBottomSheet(
                              enableDrag: false,
                              context: context,
                              builder: (context) => ChangePasswordModal(),
                            ),
                          ),
                        ),

                        //
                        // Signout Button
                        //
                        Expanded(
                          child: ContainerButton(
                            color: Theme.of(context).colorScheme.error,
                            borderRadius: 10,
                            padding: EdgeInsets.all(15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 5,
                              children: [
                                logOutLoading
                                    ? Loading()
                                    : Icon(
                                        Icons.logout,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                Text(
                                  "خروج از حساب",
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.apply(color: Colors.white),
                                ),
                              ],
                            ),
                            onPressed: () async {
                              final auth = Provider.of<AuthService>(
                                context,
                                listen: false,
                              );
                              setState(() {
                                logOutLoading = true;
                              });
                              await auth.logout();
                              setState(() {
                                logOutLoading = false;
                              });
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (route) => false,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
