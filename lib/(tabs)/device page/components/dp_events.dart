import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/event%20list/components/event_tile.dart';
import 'package:shooka_flutter/utils/expansion%20tile/my_expansion_tile.dart';
import 'package:shooka_flutter/utils/sample_datas.dart';

class DpEvents extends StatelessWidget {
  const DpEvents({super.key});

  @override
  Widget build(BuildContext context) {
    return MyExpansionTile(
      padding: EdgeInsets.all(0),
      title: "رخدادها",
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: 5,

          itemBuilder: (context, index) {
            return EventTile(
              title: eventsSampleData[index]["title"] as String,
              author: eventsSampleData[index]["title"] as String,
              device: eventsSampleData[index]["title"] as String,
              timeCreated: eventsSampleData[index]["title"] as String,
              message: [],
            );
          },
        ),
      ],
    );
  }
}
