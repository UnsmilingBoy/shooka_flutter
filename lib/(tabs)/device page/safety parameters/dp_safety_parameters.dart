import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/device%20page/safety%20parameters/edit_safety_parameters.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/utils/expansion%20tile/my_expansion_tile.dart';

class DpSafetyParameters extends StatefulWidget {
  const DpSafetyParameters({super.key});

  @override
  State<DpSafetyParameters> createState() => _DpSafetyParametersState();
}

class _DpSafetyParametersState extends State<DpSafetyParameters> {
  @override
  Widget build(BuildContext context) {
    final deviceProvider = context.watch<DeviceProvider>();
    final checklistItems =
        deviceProvider.completeDeviceInfo?.checklistItemsData ?? [];

    return MyExpansionTile(
      initiallyExpanded: false,
      title: "پارامترهای ایمنی و الکتریکی",
      completeOnPressed: () {
        final screenWidth = MediaQuery.of(context).size.width;
        final isDesktop = screenWidth > 900;
        if (isDesktop) {
          showDialog(
            context: context,
            builder: (context) => EditSafetyParameters(),
          );
        } else {
          showMaterialModalBottomSheet(
            context: context,
            builder: (context) => EditSafetyParameters(),
          );
        }
      },
      children: [
        if (checklistItems.isNotEmpty)
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: checklistItems.length,
            itemBuilder: (context, index) {
              final checklistItem = checklistItems[index];
              final label = checklistItem.label;
              final isApproved = checklistItem.isApproved;
              final notes = checklistItem.notes;

              return Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.apply(color: Theme.of(context).hintColor),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isApproved
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isApproved ? Colors.green : Colors.red,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            isApproved ? "تایید" : "رد",
                            style: TextStyle(
                              fontSize: 12,
                              color: isApproved ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!isApproved && notes != null && notes.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0, right: 8.0),
                        child: Text(
                          "دلیل رد: $notes",
                          style: Theme.of(context).textTheme.labelSmall?.apply(
                            color: Colors.red.shade300,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          )
        else
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "اطلاعاتی موجود نیست",
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
      ],
    );
  }
}
