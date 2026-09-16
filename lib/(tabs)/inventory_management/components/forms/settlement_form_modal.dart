import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/forms/form_modal_shared.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/shared/inventory_form_ui.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/models/inventory_form_data_class.dart';
import 'package:shooka_flutter/services/providers/inventory_provider.dart';
import 'package:shooka_flutter/utils/toastifications/toasts.dart';

/// Creates a settlement (فرم تسویه حساب) for the selected devices of a form.
///
/// settlement_type: `device` (تسویه دستگاه / شرکت) or
/// `representatives` (تسویه با نماینده).
class SettlementFormModal extends StatefulWidget {
  final InventoryFormItem form;
  final String projectName;

  const SettlementFormModal({
    super.key,
    required this.form,
    this.projectName = 'teska-hirkan',
  });

  @override
  State<SettlementFormModal> createState() => _SettlementFormModalState();
}

class _SettlementFormModalState extends State<SettlementFormModal> {
  /// 'device' | 'representatives'
  String _type = 'device';
  final _selectedCodes = <String>{};
  final _amount = TextEditingController();
  final _sourceBank = TextEditingController(text: 'بانک ملی ایران');
  final _destinationBank = TextEditingController(text: 'بانک ملی ایران');
  final _note = TextEditingController();
  String? _receiptImage;

  @override
  void initState() {
    super.initState();
    // Pre-select every still-unsettled device for the default type so a
    // one-tap submit settles the whole remainder of the form.
    _selectedCodes.addAll(_unsettledCodes(representative: false));
  }

  Set<String> _unsettledCodes({required bool representative}) {
    final settled = widget.form.settledCodes(representative: representative);
    return widget.form.devices
        .map((d) => d.code)
        .where((code) => !settled.contains(code))
        .toSet();
  }

  Set<String> get _settledForCurrentType =>
      widget.form.settledCodes(representative: _isRepresentative);

  void _onTypeChanged(String value) {
    setState(() {
      _type = value;
      // Auto-select the remaining unsettled devices of the new type.
      _selectedCodes
        ..clear()
        ..addAll(_unsettledCodes(representative: _isRepresentative));
    });
  }

  @override
  void dispose() {
    _amount.dispose();
    _sourceBank.dispose();
    _destinationBank.dispose();
    _note.dispose();
    super.dispose();
  }

  bool get _isRepresentative => _type == 'representatives';

  Future<void> _pickReceipt() async {
    final image = await pickReceiptImageAsBase64();
    if (image != null && mounted) {
      setState(() => _receiptImage = image);
    }
  }

  Future<void> _submit() async {
    final settled = _settledForCurrentType;
    final blocked = _selectedCodes.where(settled.contains).toList();
    if (blocked.isNotEmpty) {
      flatErrorToast(
        title: 'این دستگاه‌ها قبلاً تسویه شده‌اند',
        description: 'دستگاه ${blocked.join('، ')} برای این نوع تسویه ثبت شده است',
      );
      return;
    }
    if (_selectedCodes.isEmpty) {
      flatErrorToast(title: 'حداقل یک دستگاه تسویه‌نشده را انتخاب کنید');
      return;
    }
    if (_amount.text.trim().isEmpty ||
        int.tryParse(_amount.text.trim().replaceAll(',', '')) == null) {
      flatErrorToast(title: 'مبلغ تسویه معتبر وارد کنید');
      return;
    }
    if (_sourceBank.text.trim().isEmpty ||
        _destinationBank.text.trim().isEmpty) {
      flatErrorToast(title: 'بانک مبدأ و مقصد الزامی است');
      return;
    }
    try {
      final data = <String, dynamic>{
        'project_name': widget.projectName,
        'settlement_type': _type,
        'devices': _selectedCodes.toList(),
        'form_id': widget.form.id,
        'source_bank': _sourceBank.text.trim(),
        'destination_bank': _destinationBank.text.trim(),
        'amount': _amount.text.trim().replaceAll(',', ''),
        'note': _note.text.trim(),
        if (_receiptImage != null) 'receipt_image': _receiptImage,
      };
      await context.read<InventoryProvider>().submitSettlement(data: data);
      if (!mounted) return;
      filledSuccessToast(title: 'تسویه حساب با موفقیت ثبت شد');
      Navigator.pop(context, true);
    } catch (e) {
      flatErrorToast(title: 'خطا در ثبت تسویه', description: e.toString());
    }
  }

  Widget _typeCard({
    required String value,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final selected = _type == value;
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Material(
        color: selected
            ? color.withValues(alpha: .1)
            : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            if (_type != value) _onTypeChanged(value);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? color
                    : scheme.outline.withValues(alpha: .35),
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (selected)
                      Icon(Icons.check_circle_rounded, size: 16, color: color),
                    if (selected) const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: selected ? color : scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _devicePicker() {
    final scheme = Theme.of(context).colorScheme;
    final devices = widget.form.devices;
    if (devices.isEmpty) {
      return const InventoryEmptyItems(
        message: 'این فرم دستگاهی ندارد؛ تسویه قابل ثبت نیست.',
      );
    }
    final settled = _settledForCurrentType;
    final selectable = devices
        .where((d) => !settled.contains(d.code))
        .toList();
    if (selectable.isEmpty) {
      return InventoryEmptyItems(
        message: _isRepresentative
            ? 'همه دستگاه‌های این فرم قبلاً تسویه نماینده شده‌اند؛ امکان ثبت تسویه تکراری وجود ندارد.'
            : 'همه دستگاه‌های این فرم قبلاً تسویه دستگاه شده‌اند؛ امکان ثبت تسویه تکراری وجود ندارد.',
      );
    }
    final allSelected =
        selectable.every((d) => _selectedCodes.contains(d.code));
    return Column(
      children: [
        Row(
          children: [
            Text(
              '${_selectedCodes.length} از ${selectable.length} دستگاه تسویه‌نشده انتخاب شده',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => setState(() {
                if (allSelected) {
                  _selectedCodes.clear();
                } else {
                  _selectedCodes.addAll(selectable.map((d) => d.code));
                }
              }),
              child: Text(allSelected ? 'حذف همه' : 'انتخاب همه'),
            ),
          ],
        ),
        if (settled.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(
                  Icons.block_rounded,
                  size: 14,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    '${settled.length} دستگاه قبلاً برای این نوع تسویه ثبت شده و قابل انتخاب نیست.',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 4),
        Container(
          constraints: const BoxConstraints(maxHeight: 220),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: scheme.outline.withValues(alpha: .3)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: devices.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: scheme.outlineVariant.withValues(alpha: .6),
            ),
            itemBuilder: (context, index) {
              final device = devices[index];
              final isSettled = settled.contains(device.code);
              final checked = _selectedCodes.contains(device.code);
              return CheckboxListTile(
                value: isSettled ? true : checked,
                enabled: !isSettled,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: isSettled
                    ? scheme.outline
                    : scheme.primary,
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        device.code,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isSettled
                              ? scheme.onSurfaceVariant
                              : scheme.onSurface,
                        ),
                      ),
                    ),
                    if (isSettled)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.tertiary.withValues(alpha: .14),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 12,
                              color: scheme.tertiary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'تسویه شده',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: scheme.tertiary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10,
                                  ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                subtitle: Text(
                  '${device.deviceType} • ${device.serialNumber}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                onChanged: isSettled
                    ? null
                    : (value) => setState(() {
                        if (value == true) {
                          _selectedCodes.add(device.code);
                        } else {
                          _selectedCodes.remove(device.code);
                        }
                      }),
              );
            },
          ),
        ),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final loading = context.watch<InventoryProvider>().settlementLoading;
    return BottomModalTemplate(
      title: 'تسویه حساب فرم #${widget.form.id}',
      children: [
        InventoryFormHeader(
          title: 'ثبت تسویه حساب',
          description:
              'دستگاه‌های این فرم را انتخاب و نوع تسویه را مشخص کنید.',
          icon: Icons.payments_outlined,
        ),
        const SizedBox(height: 16),
        InventoryFormSection(
          title: 'نوع تسویه',
          description: 'تسویه قیمت دستگاه یا تسویه با نماینده',
          icon: Icons.swap_horiz_rounded,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _typeCard(
                value: 'device',
                title: 'تسویه دستگاه',
                description: 'پرداخت مبلغ دستگاه به شرکت',
                icon: Icons.business_outlined,
                color: scheme.primary,
              ),
              const SizedBox(width: 10),
              _typeCard(
                value: 'representatives',
                title: 'تسویه نماینده',
                description: 'تسویه حساب با نماینده',
                icon: Icons.badge_outlined,
                color: scheme.secondary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        InventoryFormSection(
          title: 'دستگاه‌ها',
          description: 'تسویه برای کدام دستگاه‌ها ثبت شود؟',
          icon: Icons.devices_other_outlined,
          child: _devicePicker(),
        ),
        const SizedBox(height: 14),
        InventoryFormSection(
          title: _isRepresentative ? 'مبلغ تسویه نماینده' : 'مبلغ تسویه دستگاه',
          description: 'بانک‌ها، مبلغ و رسید پرداخت',
          icon: Icons.account_balance_outlined,
          child: Column(
            children: [
              InventoryFormPair(
                first: InventoryFormField(
                  label: 'بانک مبدأ',
                  controller: _sourceBank,
                  icon: Icons.account_balance_outlined,
                  required: true,
                ),
                second: InventoryFormField(
                  label: 'بانک مقصد',
                  controller: _destinationBank,
                  icon: Icons.account_balance_outlined,
                  required: true,
                ),
              ),
              const SizedBox(height: 12),
              InventoryFormField(
                label: 'مبلغ (تومان)',
                controller: _amount,
                icon: Icons.payments_outlined,
                hint: 'مثلاً 20000000',
                keyboardType: TextInputType.number,
                required: true,
              ),
              const SizedBox(height: 12),
              InventoryFormField(
                label: 'توضیحات',
                controller: _note,
                icon: Icons.notes_rounded,
                hint: 'مثلاً تعداد ۲ دستگاه تسویه کامل شد',
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              ReceiptPickerButton(
                picked: _receiptImage != null,
                onPick: _pickReceipt,
                onRemove: () => setState(() => _receiptImage = null),
              ),
            ],
          ),
        ),
        ModalBottomButtons(
          saveText: 'ثبت تسویه حساب',
          isLoading: loading,
          onSave: loading ? null : _submit,
        ),
      ],
    );
  }
}
