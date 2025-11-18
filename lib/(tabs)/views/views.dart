import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/utils/image%20views/image_with_caption.dart';
import 'package:shooka_flutter/utils/scaffolds/back_scaffold.dart';

class ViewsTab extends StatefulWidget {
  const ViewsTab({super.key});

  @override
  State<ViewsTab> createState() => _ViewsTabState();
}

class _ViewsTabState extends State<ViewsTab> {
  @override
  void initState() {
    super.initState();
    // Fetch engineroom features when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<GeneralProvider>(context, listen: false);
      provider.fetchEngineroomFeatures(page: 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackScaffold(
      label: "نما ها",
      backLabel: "خانه",
      backRoute: "/home",

      //
      // Body
      //
      body: Consumer<GeneralProvider>(
        builder: (context, provider, child) {
          if (provider.fetchEngineroomFeaturesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.engineroomFeatures.isEmpty) {
            return const Center(child: Text("هیچ نمایی یافت نشد"));
          }

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
            ),
            itemCount: provider.engineroomFeatures.length,
            itemBuilder: (context, index) {
              final feature = provider.engineroomFeatures[index];
              return ImageWithCaption(
                networkImagePath: feature["main_3d_view_url"],
                caption: feature["main_3d_view"] ?? "نما",
              );
            },
          );
        },
      ),
    );
  }
}
