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
      setState(() => _receiptImage = "data:image/jpeg;base64,$image");
    }
  }

  Future<void> _submit() async {
    final settled = _settledForCurrentType;
    final blocked = _selectedCodes.where(settled.contains).toList();
    if (blocked.isNotEmpty) {
      flatErrorToast(
        title: 'این دستگاه‌ها قبلاً تسویه شده‌اند',
        description:
            'دستگاه ${blocked.join('، ')} برای این نوع تسویه ثبت شده است',
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
                color: selected ? color : scheme.outline.withValues(alpha: .35),
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
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
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
    final selectable = devices.where((d) => !settled.contains(d.code)).toList();
    if (selectable.isEmpty) {
      return InventoryEmptyItems(
        message: _isRepresentative
            ? 'همه دستگاه‌های این فرم قبلاً تسویه نماینده شده‌اند؛ امکان ثبت تسویه تکراری وجود ندارد.'
            : 'همه دستگاه‌های این فرم قبلاً تسویه دستگاه شده‌اند؛ امکان ثبت تسویه تکراری وجود ندارد.',
      );
    }
    final allSelected = selectable.every(
      (d) => _selectedCodes.contains(d.code),
    );
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
        _ScrollableDeviceList(
          key: ValueKey('settlement_devices_$_type'),
          devices: devices,
          settled: settled,
          selected: _selectedCodes,
          onToggle: (code) => setState(() {
            if (_selectedCodes.contains(code)) {
              _selectedCodes.remove(code);
            } else {
              _selectedCodes.add(code);
            }
          }),
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
          description: 'دستگاه‌های این فرم را انتخاب و نوع تسویه را مشخص کنید.',
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

/// Device list with an always-visible scrollbar plus a bottom fade and a
/// bouncing "scroll for more" pill that hides itself once the user reaches
/// the end — so it's obvious the list scrolls even when the scrollbar thumb
/// is subtle.
class _ScrollableDeviceList extends StatefulWidget {
  final List<InventoryDevice> devices;
  final Set<String> settled;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _ScrollableDeviceList({
    super.key,
    required this.devices,
    required this.settled,
    required this.selected,
    required this.onToggle,
  });

  @override
  State<_ScrollableDeviceList> createState() => _ScrollableDeviceListState();
}

class _ScrollableDeviceListState extends State<_ScrollableDeviceList>
    with SingleTickerProviderStateMixin {
  final _controller = ScrollController();
  late final AnimationController _bounce;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _controller.addListener(_refreshHint);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshHint());
  }

  @override
  void didUpdateWidget(_ScrollableDeviceList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.devices, widget.devices)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _refreshHint());
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_refreshHint)
      ..dispose();
    _bounce.dispose();
    super.dispose();
  }

  void _refreshHint() {
    if (!mounted || !_controller.hasClients) return;
    final max = _controller.position.maxScrollExtent;
    final show = max > 0 && _controller.offset < max - 8;
    if (show != _showHint) setState(() => _showHint = show);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Container(
          constraints: const BoxConstraints(maxHeight: 220),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: scheme.outline.withValues(alpha: .3)),
          ),
          child: Scrollbar(
            controller: _controller,
            thumbVisibility: true,
            trackVisibility: true,
            scrollbarOrientation: ScrollbarOrientation.right,
            thickness: 7,
            radius: const Radius.circular(4),
            child: ListView.separated(
              controller: _controller,
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 28),
              itemCount: widget.devices.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: scheme.outlineVariant.withValues(alpha: .6),
              ),
              itemBuilder: (context, index) {
                final device = widget.devices[index];
                final isSettled = widget.settled.contains(device.code);
                final checked = widget.selected.contains(device.code);
                return CheckboxListTile(
                  value: isSettled ? true : checked,
                  enabled: !isSettled,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: isSettled ? scheme.outline : scheme.primary,
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          device.code,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
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
                      : (_) => widget.onToggle(device.code),
                );
              },
            ),
          ),
        ),
        // Bottom fade + hint pill, visible only while more items are below.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: _showHint ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(10),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      scheme.surfaceContainerLow.withValues(alpha: 0),
                      scheme.surfaceContainerLow.withValues(alpha: .92),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 5,
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: _showHint ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              child: Center(
                child: AnimatedBuilder(
                  animation: _bounce,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(0, _bounce.value * 3),
                    child: child,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: scheme.primary.withValues(alpha: .45),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'اسکرول کنید',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          Icons.keyboard_double_arrow_down_rounded,
                          size: 15,
                          color: scheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
