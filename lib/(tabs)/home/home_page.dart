import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';
import 'package:shooka_flutter/utils/containers/mainmenu_container.dart';
import 'package:shooka_flutter/utils/layouts/base_page.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const devicesSampleData = [
      {"name": "موتورخانه 1", "status": "فعال", "city": "تهران"},
      {"name": "موتورخانه 2", "status": "غیرفعال", "city": "آمل"},
      {"name": "موتورخانه 3", "status": "فعال", "city": "زنجان"},
      {"name": "موتورخانه 4", "status": "فعال", "city": "آمل"},
    ];

    const logsSampleData = [
      {
        "title": "پیام ادمینپیام ادمینپیام ادمینپیام ادمینپیام ادمینپیام ادمین",
        "message": "سنسور دمای برگشت باید تعویض گردد",
        "author": "سپنتا شفیع زاده",
        "device": "دانشگاه مازندران - پردیس - سالن ورزشی قائم",
      },
      {
        "title": "بازدید، سرویس، راه‌اندازی سالیانه",
        "message":
            "سنسور دمای برگشت باید تعویض گرددسنسور دمای برگشت باید تعویض گرددسنسور دمای برگشت باید تعویض گرددسنسور دمای برگشت باید تعویض گرددسنسور دمای برگشت باید تعویض گرددسنسور دمای برگشت باید تعویض گرددسنسور دمای برگشت باید تعویض گرددسنسور دمای برگشت باید تعویض گرددسنسور دمای برگشت باید تعویض گرددسنسور دمای برگشت باید تعویض گرددسنسور دمای برگشت باید تعویض گردد",
        "author": "admin",
        "device": "شرکت گاز مازندران - اداره خلیل شهر",
      },
      {
        "title": "پیام ادمین",
        "message": "سنسور دمای برگشت باید تعویض گردد",
        "author": "admin",
        "device": "دانشگاه مازندران - پردیس - سالن ورزشی قائم",
      },
    ];

    return BasePage(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            spacing: 15,
            children: [
              Row(
                children: [
                  Text(
                    "خوش آمدید سپنتا شفیع زاده!",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              //
              // A Row With Two Container Tiles Providing Some Info (Boilers Status and count)
              //
              SizedBox(
                height: 135,
                child: Row(
                  spacing: 15,
                  children: [
                    //
                    // Active Boilers Info Tile
                    //
                    Expanded(
                      child: MainmenuContainer(
                        borderRadius: 10,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          spacing: 10,
                          children: [
                            Text("موتورخانه های فعال"),
                            CircularPercentIndicator(
                              lineWidth: 7,
                              animation: true,
                              progressColor: Theme.of(
                                context,
                              ).colorScheme.secondary,

                              percent: 25 / 27,
                              radius: 40,
                              center: Text("25/27"),
                            ),
                          ],
                        ),
                      ),
                    ),

                    //
                    // Quick Access Tile
                    //
                    Expanded(
                      child: MainmenuContainer(
                        borderRadius: 10,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("دسترسی سریع"),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                              child: Column(
                                spacing: 5,
                                children: [
                                  ContainerButton(
                                    padding: EdgeInsets.all(15),
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    borderRadius: 5,
                                    fillWidth: true,
                                    child: Text("افزودن موتورخانه"),
                                    onPressed: () =>
                                        Navigator.pushReplacementNamed(
                                          context,
                                          "/add_device",
                                        ),
                                  ),
                                  ContainerButton(
                                    padding: EdgeInsets.all(15),
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                    borderRadius: 5,
                                    fillWidth: true,
                                    child: Text("افزودن رویداد"),
                                    onPressed: () =>
                                        Navigator.pushReplacementNamed(
                                          context,
                                          "/add_event",
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //
              // Brief Device List and Add Device Button
              //
              MainmenuContainer(
                borderRadius: 10,
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  spacing: 15,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () => Navigator.pushReplacementNamed(
                              context,
                              "/device_list",
                            ),
                            child: Text(
                              "لیست موتورخانه ها",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pushReplacementNamed(
                              context,
                              "/device_list",
                            ),
                            child: Icon(Icons.chevron_right_rounded),
                          ),
                        ],
                      ),
                    ),

                    //
                    // Device List
                    //
                    devicesSampleData.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 50),
                            child: Text("موتورخانه ای وجود ندارد."),
                          )
                        : Padding(
                            padding: EdgeInsets.zero,
                            child: Column(
                              children: devicesSampleData.map((device) {
                                return ContainerButton(
                                  borderRadius: 0,
                                  onPressed: () {
                                    print("Navigate to device details");
                                  },
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  color: null,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(device["name"]!),
                                    subtitle: Text("شهر: ${device["city"]}"),
                                    subtitleTextStyle: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).hintColor,
                                    ),
                                    trailing: Tooltip(
                                      message:
                                          "موتورخانه ${device["status"]} است.",
                                      child: Icon(
                                        size: 15,
                                        Icons.circle,
                                        color: device["status"] == "فعال"
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                    //
                    // Add Device Button
                    //
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: ContainerButton(
                        fillWidth: true,
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            "/add_device",
                          );
                        },
                        padding: EdgeInsets.all(20),
                        color: Theme.of(context).primaryColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: Colors.white, size: 18),
                            Text(
                              "افزودن موتورخانه",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Brief Organization List and Add Organization Button
              MainmenuContainer(
                padding: EdgeInsets.symmetric(vertical: 20),
                borderRadius: 10,
                child: Column(
                  spacing: 15,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "رویداد ها",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pushReplacementNamed(
                              context,
                              "/events",
                            ),
                            child: Icon(Icons.chevron_right_rounded),
                          ),
                        ],
                      ),
                    ),
                    logsSampleData.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 50),
                            child: Text("رویدادی وجود ندارد."),
                          )
                        : Padding(
                            padding: EdgeInsets.zero,
                            child: Column(
                              children: logsSampleData.map((event) {
                                return ContainerButton(
                                  borderRadius: 0,
                                  onPressed: () {
                                    print("Navigate to device details");
                                  },
                                  // padding: EdgeInsets.symmetric(horizontal: 20),
                                  color: null,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Row(
                                      spacing: 10,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            event["title"]!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                        Expanded(
                                          child: Row(
                                            spacing: 2,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  textAlign: TextAlign.left,
                                                  event["author"].toString(),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Icon(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.secondary,
                                                Icons.person,
                                                size: 16,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Text(
                                      "دستگاه: ${event["device"]}",
                                    ),
                                    subtitleTextStyle: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).hintColor,
                                    ),
                                    // trailing: Row(
                                    //   children: [
                                    //     Icon(Icons.person),
                                    //     Text(event["author"].toString()),
                                    //   ],
                                    // ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
