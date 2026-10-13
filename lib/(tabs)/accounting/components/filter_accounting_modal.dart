import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/providers/accounting_provider.dart';
import 'package:shooka_flutter/utils/datepickers/date_range_filter_field.dart';
import 'package:shooka_flutter/utils/dropdowns/searchable_dropdown_with_label.dart';
import 'package:shooka_flutter/utils/textfields/outline_textformfield.dart';

class FilterAccountingModal extends StatefulWidget {
  const FilterAccountingModal({super.key});

  @override
  State<FilterAccountingModal> createState() => _FilterAccountingModalState();
}

class _FilterAccountingModalState extends State<FilterAccountingModal> {
  JalaliRange? dateRange;

  final TextEditingController _factorNumberController = TextEditingController();
  bool? selectedIsPrinted;

  @override
  void initState() {
    super.initState();
    final accountingProvider = Provider.of<AccountingProvider>(
      context,
      listen: false,
    );
    _factorNumberController.text = accountingProvider.lastFactorNumber ?? '';
    selectedIsPrinted = accountingProvider.lastIsPrinted;
  }

  @override
  void dispose() {
    _factorNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountingProvider = context.watch<AccountingProvider>();

    return BottomModalTemplate(
      title: 'فیلتر فاکتورها',
      children: [
        // Factor number
        OutlineTextformfield(
          controller: _factorNumberController,
          placeholder: 'شماره فاکتور...',
          keyboardType: TextInputType.text,
          maxLines: 1,
        ),
        const SizedBox(height: 8),

        // Is Printed Dropdown
        SearchableDropdownWithLabel(
          onChanged: (value) => setState(() {
            if (value == 'true') {
              selectedIsPrinted = true;
            } else if (value == 'false') {
              selectedIsPrinted = false;
            } else {
              selectedIsPrinted = null;
            }
          }),
          iconOnPressed: () => setState(() => selectedIsPrinted = null),
          items: [
            DropdownItemModel(value: 'true', label: 'چاپ شده'),
            DropdownItemModel(value: 'false', label: 'چاپ نشده'),
          ],
          label: 'وضعیت چاپ:',
          placeholder: 'انتخاب کنید',
          initialValue: selectedIsPrinted?.toString(),
        ),

        //
        // Date range picker (shared, Jalali)
        //
        DateRangeFilterField(
          label: 'بازه زمانی:',
          value: dateRange,
          onChanged: (range) => setState(() {
            dateRange = range;
          }),
        ),

        //
        // Apply Filter Button
        //
        ModalBottomButtons(
          saveText: 'فیلتر',
          onSave: () {
            final factorNum = _factorNumberController.text.trim();
            accountingProvider.loadFactors(
              search: accountingProvider.lastSearchedText,
              factorNumber: factorNum.isNotEmpty ? factorNum : null,
              isPrinted: selectedIsPrinted,
              start: dateRange?.start.formatCompactDate(),
              end: dateRange?.end.formatCompactDate(),
            );
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
