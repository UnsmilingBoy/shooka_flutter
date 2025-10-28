import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/consts/views_list.dart';
import 'package:shooka_flutter/utils/image%20views/image_with_caption.dart';
import 'package:shooka_flutter/utils/scaffolds/back_scaffold.dart';

class ViewsTab extends StatelessWidget {
  const ViewsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BackScaffold(
      label: "نما ها",
      backLabel: "خانه",
      backRoute: "/home",

      //
      // Body
      //
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
        ),
        itemCount: views.length,
        itemBuilder: (context, index) =>
            //
            // Dialog for opening images
            //
            ImageWithCaption(
              localImagepath: views[index]["path"] as String,
              caption: views[index]["label"] as String,
            ),
      ),
    );
  }
}
