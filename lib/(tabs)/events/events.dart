import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shooka_flutter/(tabs)/events/components/event_tile.dart';
import 'package:shooka_flutter/(tabs)/events/components/add_event_modal.dart';
import 'package:shooka_flutter/(tabs)/events/components/filter_event_modal.dart';
import 'package:shooka_flutter/components/tab_header.dart';
import 'package:shooka_flutter/utils/floating%20action%20button/add_floating_button.dart';
import 'package:shooka_flutter/utils/scaffolds/back_scaffold.dart';

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
      floatingActionButton: AddFloatingButton(addModal: AddEventModal()),

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
            TabHeader(
              searchController: searchController,
              filterModal: FilterEventModal(),
              searchPlaceholder: "جستجوی رویداد...",
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
