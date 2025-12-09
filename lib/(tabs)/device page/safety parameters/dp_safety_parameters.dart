import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/device%20page/safety%20parameters/edit_safety_parameters.dart';
import 'package:shooka_flutter/services/providers/general_provider.dart';
import 'package:shooka_flutter/utils/expansion%20tile/my_expansion_tile.dart';

class DpSafetyParameters extends StatefulWidget {
  const DpSafetyParameters({super.key});

  @override
  State<DpSafetyParameters> createState() => _DpSafetyParametersState();
}

class _DpSafetyParametersState extends State<DpSafetyParameters> {
  // Mock data - will be replaced with actual device data when backend supports it
  final Map<int, Map<String, String>> mockSafetyData = {
    1: {"status": "approved", "note": ""},
    2: {"status": "approved", "note": ""},
    3: {"status": "rejected", "note": "نیاز به نصب سرج ارستر"},
    4: {"status": "approved", "note": ""},
    5: {"status": "approved", "note": ""},
    6: {"status": "rejected", "note": "نقشه سیم کشی موجود نیست"},
  };

  @override
  Widget build(BuildContext context) {
    final generalProvider = context.watch<GeneralProvider>();
    final checklist = generalProvider.filters?["checklist"] as List?;

    return MyExpansionTile(
      initiallyExpanded: false,
      title: "پارامترهای ایمنی و الکتریکی",
      completeOnPressed: () => showMaterialModalBottomSheet(
        context: context,
        builder: (context) => EditSafetyParameters(),
      ),
      children: [
        if (checklist != null && checklist.isNotEmpty)
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: checklist.length,
            itemBuilder: (context, index) {
              final checklistItem = checklist[index];
              final id = checklistItem["id"] as int;
              final label = checklistItem["label"] ?? "";

              // Get mock data for this item
              final mockData =
                  mockSafetyData[id] ?? {"status": "approved", "note": ""};
              final isApproved = mockData["status"] == "approved";

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
                    if (!isApproved && mockData["note"]!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0, right: 8.0),
                        child: Text(
                          "دلیل رد: ${mockData["note"]}",
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
