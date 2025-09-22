import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shooka_flutter/(tabs)/organizations/components/add_org_modal.dart';
import 'package:shooka_flutter/(tabs)/organizations/components/filter_org_modal.dart';
import 'package:shooka_flutter/(tabs)/organizations/components/org_tile.dart';
import 'package:shooka_flutter/components/tab_header.dart';
import 'package:shooka_flutter/utils/floating%20action%20button/add_floating_button.dart';
import 'package:shooka_flutter/utils/scaffolds/back_scaffold.dart';

class OrganiztionsTab extends StatelessWidget {
  const OrganiztionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    const orgSampleData = [
      {"name": "انتقال گاز شهرستان نور", "parent": "شرکت انتقال گاز ایران"},
      {
        "name":
            "اداره کل زندانهای استان مازندراناداره کل زندانهای استان مازندراناداره کل زندانهای استان مازندراناداره کل زندانهای استان مازندراناداره کل زندانهای استان مازندراناداره کل زندانهای استان مازندراناداره کل زندانهای استان مازندراناداره کل زندانهای استان مازندران",
        "parent": "	زندان‌ها و اقدامات تأمینی و تربیتی",
      },
      {"name": "انتقال گاز شهرستان نور", "parent": "شرکت انتقال گاز ایران"},
      {
        "name": "اداره کل زندانهای استان مازندران",
        "parent": "	زندان‌ها و اقدامات تأمینی و تربیتی",
      },
      {"name": "انتقال گاز شهرستان نور", "parent": "شرکت انتقال گاز ایران"},
      {
        "name": "اداره کل زندانهای استان مازندران",
        "parent":
            "	زندان‌ها و اقدامات تأمینی و تربیتیزندان‌ها و اقدامات تأمینی و تربیتیزندان‌ها و اقدامات تأمینی و تربیتیزندان‌ها و اقدامات تأمینی و تربیتیزندان‌ها و اقدامات تأمینی و تربیتیزندان‌ها و اقدامات تأمینی و تربیتیزندان‌ها و اقدامات تأمینی و تربیتیزندان‌ها و اقدامات تأمینی و تربیتیزندان‌ها و اقدامات تأمینی و تربیتی",
      },
      {"name": "انتقال گاز شهرستان نور", "parent": "شرکت انتقال گاز ایران"},
      {
        "name": "اداره کل زندانهای استان مازندران",
        "parent": "	زندان‌ها و اقدامات تأمینی و تربیتی",
      },
      {"name": "انتقال گاز شهرستان نور", "parent": "شرکت انتقال گاز ایران"},
      {
        "name": "اداره کل زندانهای استان مازندران",
        "parent": "	زندان‌ها و اقدامات تأمینی و تربیتی",
      },
      {"name": "انتقال گاز شهرستان نور", "parent": "شرکت انتقال گاز ایران"},
      {
        "name": "اداره کل زندانهای استان مازندران",
        "parent": "	زندان‌ها و اقدامات تأمینی و تربیتی",
      },
      {"name": "انتقال گاز شهرستان نور", "parent": "شرکت انتقال گاز ایران"},
      {
        "name": "اداره کل زندانهای استان مازندران",
        "parent": "	زندان‌ها و اقدامات تأمینی و تربیتی",
      },
      {"name": "انتقال گاز شهرستان نور", "parent": "شرکت انتقال گاز ایران"},
      {
        "name": "اداره کل زندانهای استان مازندران",
        "parent": "	زندان‌ها و اقدامات تأمینی و تربیتی",
      },
      {"name": "انتقال گاز شهرستان نور", "parent": "شرکت انتقال گاز ایران"},
      {
        "name": "اداره کل زندانهای استان مازندران",
        "parent": "	زندان‌ها و اقدامات تأمینی و تربیتی",
      },
      {"name": "انتقال گاز شهرستان نور", "parent": "شرکت انتقال گاز ایران"},
      {
        "name": "اداره کل زندانهای استان مازندران",
        "parent": "	زندان‌ها و اقدامات تأمینی و تربیتی",
      },
      {"name": "انتقال گاز شهرستان نور", "parent": "شرکت انتقال گاز ایران"},
      {
        "name": "اداره کل زندانهای استان مازندران",
        "parent": "	زندان‌ها و اقدامات تأمینی و تربیتی",
      },
    ];

    TextEditingController searchController = TextEditingController();

    return BackScaffold(
      backLabel: "خانه",
      backRoute: "/home",
      label: "سازمان ها",

      //
      // Floating Action Button
      //
      floatingActionButton: AddFloatingButton(
        addModal: AddOrgModal(isEdit: false),
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
            TabHeader(
              searchController: searchController,
              filterModal: FilterOrgModal(),
              searchPlaceholder: "جستجوی سازمان...",
            ),

            //
            // Org List
            //
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: orgSampleData.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: OrgTile(
                  onPressed: () => showMaterialModalBottomSheet(
                    enableDrag: false,
                    context: context,
                    builder: (context) => AddOrgModal(
                      isEdit: true,
                      name: orgSampleData[index]["name"],
                      parent: orgSampleData[index]["parent"],
                    ),
                  ),
                  color: Theme.of(context).colorScheme.surface,
                  orgName: orgSampleData[index]["name"] ?? "",
                  orgParent: orgSampleData[index]["parent"] ?? "",
                  borderRadius: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
