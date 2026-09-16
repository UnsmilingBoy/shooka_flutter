import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/forms/form_modal_shared.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/shared/inventory_form_ui.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/models/inventory_form_data_class.dart';
import 'package:shooka_flutter/services/providers/inventory_provider.dart';
import 'package:shooka_flutter/services/providers/software_support_provider.dart';
import 'package:shooka_flutter/utils/datepickers/my_date_picker.dart';
import 'package:shooka_flutter/utils/toastifications/toasts.dart';

class PartsFormModal extends StatefulWidget {
  final InventoryFormItem? form;

  const PartsFormModal({super.key, this.form});

  @override
  State<PartsFormModal> createState() => _PartsFormModalState();
}

class _InstallRow {
  String? item;

  /// Raw `item_type` from the loaded form, resolved to [item] (option name)
  /// once install options are fetched.
  String? pendingLabel;
  final quantity = TextEditingController(text: '1');
  _InstallRow();
  void dispose() => quantity.dispose();
}

class _PartsFormModalState extends State<PartsFormModal> {
  static const _projectName = 'teska-hirkan';
  static const _deviceTypeName = 'hirkan-r8';
  String? _selectedProvince;
  final _exportUnit = TextEditingController();
  final _postingType = TextEditingController();
  int? _selectedUserId;
  final _sourceBank = TextEditingController();
  final _destinationBank = TextEditingController();
  final _amount = TextEditingController();
  final _date = TextEditingController();
  final _note = TextEditingController();
  final _installRows = <_InstallRow>[];
  List<InventoryInstallItemOption> _options = [];
  bool _itemsLoading = true;

  bool get _isEdit => widget.form != null;

  String get _effectiveDeviceType => _deviceTypeName;

  void _prefillFromForm() {
    final form = widget.form;
    if (form == null) return;
    _exportUnit.text = form.exportUnit;
    _postingType.text = form.postingType;
    _sourceBank.text = form.sourceBank;
    _destinationBank.text = form.destinationBank;
    _amount.text = form.amount;
    _date.text = form.dateOfReceipt;
    _note.text = form.note;
    final matchedProvince = matchIranProvince(form.destination);
    _selectedProvince = matchedProvince.isEmpty ? null : matchedProvince;
    _selectedUserId = int.tryParse(form.sentTo.trim());
    for (final row in _installRows) {
      row.dispose();
    }
    _installRows.clear();
    for (final item in form.installItems) {
      final row = _InstallRow()..pendingLabel = item.itemType;
      row.quantity.text = item.quantity > 0 ? item.quantity.toString() : '1';
      _installRows.add(row);
    }
  }

  void _resolvePendingInstallRows() {
    if (_options.isEmpty) return;
    var changed = false;
    for (final row in _installRows) {
      if (row.item == null && row.pendingLabel != null) {
        final label = row.pendingLabel!.trim();
        InventoryInstallItemOption? match;
        for (final option in _options) {
          if (option.label.trim() == label || option.name.trim() == label) {
            match = option;
            break;
          }
        }
        if (match != null) {
          row.item = match.name;
          row.pendingLabel = null;
          changed = true;
        }
      }
    }
    if (changed && mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _prefillFromForm();
    _loadItems();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final supportProvider = context.read<SoftwareSupportProvider>();
      if (supportProvider.users.isEmpty && !supportProvider.usersLoading) {
        supportProvider.fetchUsers();
      }
    });
  }

  Future<void> _loadItems() async {
    try {
      final options = await context.read<InventoryProvider>().fetchInstallItems(
        projectName: _projectName,
        deviceType: _deviceTypeName,
      );
      if (mounted) {
        setState(() {
          _options = options;
          _itemsLoading = false;
        });
        _resolvePendingInstallRows();
      }
    } catch (e) {
      if (mounted) setState(() => _itemsLoading = false);
      flatErrorToast(
        title: 'خطا در بارگذاری اقلام نصب',
        description: e.toString(),
      );
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _exportUnit,
      _postingType,
      _sourceBank,
      _destinationBank,
      _amount,
      _date,
      _note,
    ]) {
      controller.dispose();
    }
    for (final row in _installRows) {
      row.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await myDatePicker(context);
    if (date != null) _date.text = jalaliDateText(date);
    if (mounted) setState(() {});
  }

  Future<void> _submit() async {
    final requiredFields = [
      _exportUnit,
      _postingType,
      _sourceBank,
      _destinationBank,
      _amount,
      _date,
    ];
    final invalidItems = _installRows.any(
      (row) =>
          row.item == null ||
          int.tryParse(row.quantity.text.trim()) == null ||
          int.parse(row.quantity.text.trim()) < 1,
    );
    if (requiredFields.any((field) => field.text.trim().isEmpty) ||
        _installRows.isEmpty ||
        invalidItems) {
      flatErrorToast(
        title: _installRows.isEmpty
            ? 'حداقل یک قلم برای ارسال اضافه کنید'
            : 'لطفا همه فیلدهای ستاره‌دار را کامل کنید',
      );
      return;
    }
    if (_selectedProvince == null) {
      flatErrorToast(title: 'استان مقصد انتخاب نشده است');
      return;
    }
    if (_selectedUserId == null) {
      flatErrorToast(title: 'نماینده (گیرنده) انتخاب نشده است');
      return;
    }
    final installItems = _installRows
        .map(
          (row) => {
            'item_type': _options
                .firstWhere((option) => option.name == row.item)
                .label,
            'quantity': int.parse(row.quantity.text.trim()),
          },
        )
        .toList();
    try {
      final provider = context.read<InventoryProvider>();
      if (_isEdit) {
        final data = <String, dynamic>{
          'form_id': widget.form!.id,
          'device_type': _effectiveDeviceType,
          'destination': _selectedProvince,
          'export_unit': _exportUnit.text.trim(),
          'posting_type': _postingType.text.trim(),
          'sent_to': _selectedUserId,
          'source_bank': _sourceBank.text.trim(),
          'destination_bank': _destinationBank.text.trim(),
          'amount': _amount.text.trim(),
          'date_of_receipt': _date.text.trim(),
          'note': _note.text.trim(),
          'install_items': installItems,
        };
        await provider.editInventoryItems(data: data);
        if (!mounted) return;
        filledSuccessToast(title: 'فرم ارسال قطعات با موفقیت ویرایش شد');
        Navigator.pop(context, true);
      } else {
        final data = <String, dynamic>{
          'project_name': _projectName,
          'device_type': _deviceTypeName,
          'destination': _selectedProvince,
          'export_unit': _exportUnit.text.trim(),
          'posting_type': _postingType.text.trim(),
          'sent_to': _selectedUserId,
          'source_bank': _sourceBank.text.trim(),
          'destination_bank': _destinationBank.text.trim(),
          'amount': _amount.text.trim(),
          'date_of_receipt': _date.text.trim(),
          'note': _note.text.trim(),
          'install_items': installItems,
        };
        await provider.submitInventoryItems(data: data);
        if (!mounted) return;
        filledSuccessToast(title: 'فرم ارسال قطعات با موفقیت ثبت شد');
        Navigator.pop(context);
      }
    } catch (e) {
      flatErrorToast(
        title: _isEdit ? 'خطا در ویرایش فرم' : 'خطا در ثبت فرم',
        description: e.toString(),
      );
    }
  }

  Widget _shipmentDetails() => Column(
    children: [
      InventoryFormPair(
        first: ProvinceDropdownField(
          value: _selectedProvince,
          onChanged: (value) => setState(() => _selectedProvince = value),
        ),
        second: RecipientDropdownField(
          userId: _selectedUserId,
          onChanged: (value) => setState(() => _selectedUserId = value),
        ),
      ),
      const SizedBox(height: 12),
      pairFormFields(
        'واحد صادرکننده',
        _exportUnit,
        Icons.business_outlined,
        'نوع ارسال',
        _postingType,
        Icons.local_shipping_outlined,
      ),
      const SizedBox(height: 12),
      pairFormFields(
        'بانک مبدأ',
        _sourceBank,
        Icons.account_balance_outlined,
        'بانک مقصد',
        _destinationBank,
        Icons.account_balance_outlined,
      ),
      const SizedBox(height: 12),
      InventoryFormPair(
        first: InventoryFormField(
          label: 'مبلغ',
          controller: _amount,
          icon: Icons.payments_outlined,
          keyboardType: TextInputType.number,
          required: true,
        ),
        second: InventoryFormField(
          label: 'تاریخ دریافت',
          controller: _date,
          icon: Icons.calendar_today_outlined,
          hint: '۱۴۰۵/۰۱/۰۱',
          readOnly: true,
          onTap: _pickDate,
          required: true,
        ),
      ),
      const SizedBox(height: 12),
      InventoryFormField(
        label: 'توضیحات',
        controller: _note,
        icon: Icons.notes_rounded,
        hint: 'توضیحات تکمیلی ارسال، در صورت نیاز',
        maxLines: 3,
      ),
    ],
  );

  Widget _itemEditor(int index, _InstallRow row) {
    return FormRepeatingCard(
      badge: 'قلم ${index + 1}',
      onDelete: () => setState(() {
        row.dispose();
        _installRows.removeAt(index);
      }),
      child: InventoryFormPair(
            first: DropdownButtonFormField<String>(
              key: ValueKey('parts_install_${index}_${row.item}'),
              initialValue: row.item,
              isExpanded: true,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: inventoryInputDecoration(
                context,
                label: 'قلم قابل ارسال*',
                icon: Icons.handyman_outlined,
              ),
              items: _options
                  .map(
                    (option) => DropdownMenuItem(
                      value: option.name,
                      child: Text(
                        option.label,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => row.item = value),
            ),
            second: InventoryFormField(
              label: 'تعداد',
              controller: row.quantity,
              icon: Icons.numbers_rounded,
              keyboardType: TextInputType.number,
              required: true,
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<InventoryProvider>().submitLoading;
    return BottomModalTemplate(
      title: _isEdit ? 'ویرایش ارسال قطعات #${widget.form!.id}' : 'ارسال قطعات',
      children: [
        InventoryFormHeader(
          title: _isEdit
              ? 'ویرایش ارسال قطعات #${widget.form!.id}'
              : 'ثبت ارسال قطعات و اقلام',
          description: 'مشخصات ارسال و تعداد اقلام را با دقت وارد کنید.',
          icon: Icons.handyman_outlined,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        const SizedBox(height: 16),
        InventoryFormSection(
          title: 'اطلاعات ارسال',
          description: 'مقصد، گیرنده و اطلاعات مالی فرم',
          icon: Icons.local_shipping_outlined,
          child: _shipmentDetails(),
        ),
        const SizedBox(height: 14),
        InventoryFormSection(
          title: 'اقلام قابل ارسال',
          description: 'حداقل یک قلم را به فرم اضافه کنید.',
          icon: Icons.inventory_2_outlined,
          trailing: _itemsLoading
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
          child: _itemsLoading
              ? const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                )
              : _options.isEmpty
              ? const InventoryEmptyItems(
                  message: 'برای این نوع دستگاه قلمی ثبت نشده است.',
                )
              : Column(
                  children: [
                    ..._installRows.asMap().entries.map(
                      (entry) => _itemEditor(entry.key, entry.value),
                    ),
                    if (_installRows.isEmpty)
                      const InventoryEmptyItems(
                        message: 'هنوز قلمی برای ارسال انتخاب نشده است.',
                      ),
                    InventoryAddRowButton(
                      label: 'افزودن قلم',
                      onPressed: () =>
                          setState(() => _installRows.add(_InstallRow())),
                    ),
                  ],
                ),
        ),
        ModalBottomButtons(
          saveText: _isEdit ? 'ثبت ویرایش قطعات' : 'ثبت ارسال قطعات',
          isLoading: loading,
          onSave: loading ? null : _submit,
        ),
      ],
    );
  }
}
