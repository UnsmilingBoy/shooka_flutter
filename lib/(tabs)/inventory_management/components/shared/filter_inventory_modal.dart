import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/providers/inventory_provider.dart';

class FilterInventoryModal extends StatefulWidget {
  const FilterInventoryModal({super.key});

  @override
  State<FilterInventoryModal> createState() => _FilterInventoryModalState();
}

class _FilterInventoryModalState extends State<FilterInventoryModal> {
  late final TextEditingController _destinationController;
  late final TextEditingController _startController;
  late final TextEditingController _endController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<InventoryProvider>();
    _destinationController = TextEditingController(
      text: provider.destinationFilter,
    );
    _startController = TextEditingController(text: provider.startFilter);
    _endController = TextEditingController(text: provider.endFilter);
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label, {IconData? icon, String? hint}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon == null ? null : Icon(icon),
      hintText: hint,
      isDense: true,
      border: const OutlineInputBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<InventoryProvider>();

    return BottomModalTemplate(
      title: 'فیلتر فرم‌های انبار',
      children: [
        TextField(
          controller: _destinationController,
          decoration: _decoration('مقصد', icon: Icons.location_on_outlined),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _startController,
          decoration: _decoration('از تاریخ', hint: '1405/01/01'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _endController,
          decoration: _decoration('تا تاریخ', hint: '1405/12/29'),
        ),
        ModalBottomButtons(
          saveText: 'اعمال فیلتر',
          onSave: () {
            provider.setFilters(
              destination: _destinationController.text,
              start: _startController.text,
              end: _endController.text,
            );
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
