import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shooka_flutter/(tabs)/profile/components/edit_profile_modal.dart';
import 'package:shooka_flutter/components/drawer.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    const userSampleData = {
      "name": "سپنتا",
      "role": "سرپرست",
      "username": "s.shafizadeh",
      "phone_number": "09911254099",
      "email": "sepantashafizadeh@gmail.com",
    };

    final tiles = [
      {
        "title": "نام",
        "icon": Icon(Icons.label),
        "value": userSampleData["name"],
      },
      {
        "title": "نقش",
        "icon": Icon(Icons.badge),
        "value": userSampleData["role"],
      },
      {
        "title": "نام کاربری",
        "icon": Icon(Icons.person_rounded),
        "value": userSampleData["username"],
      },
      {
        "title": "شماره همراه",
        "icon": Icon(Icons.phone),
        "value": userSampleData["phone_number"],
      },
      {
        "title": "ایمیل",
        "icon": Icon(Icons.email),
        "value": userSampleData["email"],
      },
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        //
        // Appbar
        //
        appBar: AppBar(
          title: Text("حساب کاربری"),
          centerTitle: true,
          actions: [
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => Navigator.of(context).pushReplacementNamed("/home"),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 5,
                  children: [
                    Text("خانه", style: Theme.of(context).textTheme.labelLarge),
                    Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
            SizedBox(width: 5),
          ],
        ),

        //
        // Drawer
        //
        drawer: MyDrawer(),

        //
        // Body
        //
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
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
                          child: CircleAvatar(
                            backgroundImage: AssetImage(
                              "assets/images/profile.jpg",
                            ),
                            radius: 60,
                          ),
                        ),
                        Text(
                          "سپنتا شفیع زاده",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          "سرپرست",
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
                  padding: EdgeInsets.all(10),
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: ListTile(
                      onTap: () => print("cat"),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
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
                            Icon(Icons.edit, size: 18),
                            Text(
                              "ویرایش",
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
                        ),
                        onPressed: () => showMaterialModalBottomSheet(
                          //TODO: FIX THIS
                          context: context,
                          builder: (context) => SingleChildScrollView(
                            controller: ModalScrollController.of(context),
                            child: EditProfileModal(),
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
                                  Icon(Icons.password_outlined, size: 18),
                                  Text(
                                    "تغییر رمز عبور",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelLarge,
                                  ),
                                ],
                              ),
                              onPressed: () => print("change pw"),
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
                                  Icon(Icons.logout, size: 18),
                                  Text(
                                    "خروج از حساب",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelLarge,
                                  ),
                                ],
                              ),
                              onPressed: () => print("signout"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
