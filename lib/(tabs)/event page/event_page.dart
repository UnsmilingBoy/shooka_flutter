import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/sample_datas.dart';
import 'package:shooka_flutter/utils/scaffolds/back_scaffold.dart';

class EventPage extends StatelessWidget {
  final int eventId;
  const EventPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return BackScaffold(
      label: "جزئیات رویداد",
      backRoute: "/events",
      backLabel: "رویدادها",
      body: SingleChildScrollView(
        //
        // Event Header
        //
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              //
              // Title
              //
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "عنوان: ${logsSampleData[eventId]["title"]}",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              Column(
                spacing: 2,
                children: [
                  //
                  // Device
                  //
                  Row(
                    spacing: 3,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.heat_pump_rounded,
                        size: 20,
                        color: Theme.of(context).hintColor,
                      ),
                      Expanded(
                        child: Text(
                          "دستگاه:  ${logsSampleData[eventId]["device"]}",
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),

                  //
                  // Author
                  //
                  Row(
                    spacing: 3,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.attribution_outlined,
                        size: 20,
                        color: Theme.of(context).hintColor,
                      ),
                      Expanded(
                        child: Text(
                          "ایجادکننده:  ${logsSampleData[eventId]["author"]}",
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),

                  //
                  // Date
                  //
                  Row(
                    spacing: 3,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.date_range,
                        size: 20,
                        color: Theme.of(context).hintColor,
                      ),
                      Expanded(
                        child: Text(
                          "زمان ایجاد:  ${logsSampleData[eventId]["date"]}",
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              //
              // Event (report) Content
              //
              Divider(color: Theme.of(context).hintColor),
              Text(
                logsSampleData[eventId]["message"] as String,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
