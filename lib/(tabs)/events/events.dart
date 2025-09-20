import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shooka_flutter/components/event_tile.dart';
import 'package:shooka_flutter/(tabs)/events/components/add_event_modal.dart';
import 'package:shooka_flutter/(tabs)/events/components/filter_event_modal.dart';
import 'package:shooka_flutter/utils/buttons/my_icon_button.dart';
import 'package:shooka_flutter/utils/layouts/back_scaffold.dart';
import 'package:shooka_flutter/utils/textfields/OutlineTextfield.dart';

class EventsTab extends StatefulWidget {
  final bool openAddEvent;
  const EventsTab({super.key, required this.openAddEvent});

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  @override
  void initState() {
    super.initState();

    // Opens the add event modal if the route was "/add_event"
    if (widget.openAddEvent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showMaterialModalBottomSheet(
          enableDrag: false,
          context: context,
          builder: (context) => AddEventModal(),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
      {
        "title": "پیام ادمین",
        "message": "سنسور دمای برگشت باید تعویض گردد",
        "author": "admin",
        "device": "دانشگاه مازندران - پردیس - سالن ورزشی قائم",
      },
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
      {
        "title": "پیام ادمین",
        "message": "سنسور دمای برگشت باید تعویض گردد",
        "author": "admin",
        "device": "دانشگاه مازندران - پردیس - سالن ورزشی قائم",
      },
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
      {
        "title": "پیام ادمین",
        "message": "سنسور دمای برگشت باید تعویض گردد",
        "author": "admin",
        "device": "دانشگاه مازندران - پردیس - سالن ورزشی قائم",
      },
    ];

    TextEditingController searchController = TextEditingController();

    return BackScaffold(
      backLabel: "خانه",
      backRoute: "/home",
      label: "رویداد ها",

      //
      // Floating action button
      //
      floatingActionButton: InkWell(
        borderRadius: BorderRadius.circular(1000),
        onTap: () => showMaterialModalBottomSheet(
          enableDrag: false,
          context: context,
          builder: (context) => AddEventModal(),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor,
          ),
          padding: EdgeInsets.all(20),
          child: Icon(Icons.add),
        ),
      ),

      //
      // Body
      //
      body: SingleChildScrollView(
        child: Column(
          spacing: 10,
          children: [
            //
            // Header (Search and Filter)
            //
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: Outlinetextfield(
                      controller: searchController,
                      placeholder: "جستجوی موتوخانه...",
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                  width: 50,
                  child: MyIconButton(
                    onPressed: () => showMaterialModalBottomSheet(
                      enableDrag: false,
                      context: context,
                      builder: (context) => FilterEventModal(),
                    ),
                    color: Theme.of(context).colorScheme.secondary,
                    child: Icon(Icons.filter_alt_rounded),
                  ),
                ),
              ],
            ),

            //
            // Events List
            //
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: logsSampleData.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: EventTile(
                  title: logsSampleData[index]["title"] ?? "",
                  author: logsSampleData[index]["author"] ?? "",
                  device: logsSampleData[index]["device"] ?? "",
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
