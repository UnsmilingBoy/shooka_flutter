import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/event%20list/components/event_tile.dart';
import 'package:shooka_flutter/services/providers/event_provider.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';
import 'package:shooka_flutter/utils/expansion%20tile/my_expansion_tile.dart';
import 'package:shooka_flutter/utils/loadings/loading.dart';

class DpEvents extends StatelessWidget {
  const DpEvents({super.key});

  @override
  Widget build(BuildContext context) {
    final events = context.watch<EventProvider>().events;
    final loading = context.watch<EventProvider>().fetchLoading;

    return MyExpansionTile(
      padding: EdgeInsets.all(0),
      title: "رخدادها",
      children: [
        loading
            ? Padding(
                padding: const EdgeInsets.all(40.0),
                child: Loading(),
              ) // Loading Ui
            : events.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(40.0),
                child: Text("رویدادی یافت نشد."),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: events.length > 5 ? 5 : events.length,
                itemBuilder: (context, index) {
                  return EventTile(
                    title: events[index].title,
                    author: events[index].creator,
                    device: events[index].deviceName,
                    timeCreated: events[index].timestamp,
                    message: events[index].eventCategoryDetails,
                  );
                },
              ),
        ContainerButton(
          onPressed: () => Navigator.pushNamed(context, '/events'),
          color: Theme.of(context).primaryColor,
          fillWidth: true,
          padding: EdgeInsets.all(14),
          margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
          borderRadius: 10,
          child: Text(
            "مشاهده همه رویداد ها",
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.apply(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
