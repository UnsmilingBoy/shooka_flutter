import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/forms/form_modal_shared.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/shared/adaptive_modal.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/shared/inventory_form_ui.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/models/inventory_form_data_class.dart';
import 'package:shooka_flutter/services/providers/inventory_provider.dart';
import 'package:shooka_flutter/utils/datepickers/my_date_picker.dart';
import 'package:shooka_flutter/utils/toastifications/toasts.dart';

class ReturnedFormModal extends StatefulWidget {
  const ReturnedFormModal({super.key});

  @override
  State<ReturnedFormModal> createState() => _ReturnedFormModalState();
}

class _ReturnedFormModalState extends State<ReturnedFormModal> {
  static const _projectName = 'teska-hirkan';
  final _source = TextEditingController();
  final _exportUnit = TextEditingController();
  final _postingType = TextEditingController();
  final _date = TextEditingController();
  final _note = TextEditingController();

  InventoryFormItem? _selectedForm;
  InventoryFormItem? _details;
  bool _detailsLoading = false;
  String? _detailsError;

  final _selectedDevices = <String>{};
  final _selectedItems = <int, int>{};

  @override
  void dispose() {
    for (final controller in [
      _source,
      _exportUnit,
      _postingType,
      _date,
      _note,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await myDatePicker(context);
    if (date != null) _date.text = jalaliDateText(date);
    if (mounted) setState(() {});
  }

  void _openFormPicker() {
    showAdaptiveInventoryModal(
      context,
      _OriginalFormPicker(
        selectedId: _selectedForm?.id,
        onSelected: _onFormPicked,
      ),
    );
  }

  void _onFormPicked(InventoryFormItem form) {
    setState(() {
      _selectedForm = form;
      _details = null;
      _detailsError = null;
      _selectedDevices.clear();
      _selectedItems.clear();
    });
    _loadDetails(form.id);
  }

  Future<void> _loadDetails(int formId) async {
    setState(() {
      _detailsLoading = true;
      _detailsError = null;
    });
    try {
      final details = await context
          .read<InventoryProvider>()
          .api
          .fetchInventoryItemById(formID: formId);
      if (!mounted) return;
      setState(() {
        _details = details;
        _detailsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _detailsLoading = false;
        _detailsError = e.toString();
      });
    }
  }

  void _autofillFromOriginal() {
    final form = _details ?? _selectedForm;
    if (form == null) return;
    setState(() {
      if (_source.text.trim().isEmpty) _source.text = form.destination;
      if (_exportUnit.text.trim().isEmpty) _exportUnit.text = form.exportUnit;
      if (_postingType.text.trim().isEmpty) {
        _postingType.text = form.postingType;
      }
    });
    filledSuccessToast(title: 'اطلاعات از فرم اصلی کپی شد');
  }

  void _clearSelection() {
    setState(() {
      _selectedForm = null;
      _details = null;
      _detailsError = null;
      _selectedDevices.clear();
      _selectedItems.clear();
    });
  }

  /// Devices of the picked form that have NOT been returned yet. Devices
  /// flagged `is_returned` are hidden from the returnable list so the user
  /// can never return the same device twice.
  List<InventoryDevice> get _returnableDevices =>
      _details?.devices.where((d) => !d.isReturned).toList() ?? const [];

  int get _alreadyReturnedCount =>
      (_details?.devices.length ?? 0) - _returnableDevices.length;

  Future<void> _submit() async {
    final form = _selectedForm;
    if (form == null) {
      flatErrorToast(title: 'اول فرم اصلی را انتخاب کنید');
      return;
    }
    if (_source.text.trim().isEmpty ||
        _exportUnit.text.trim().isEmpty ||
        _postingType.text.trim().isEmpty ||
        _date.text.trim().isEmpty) {
      flatErrorToast(title: 'لطفا همه فیلدهای ستاره‌دار را کامل کنید');
      return;
    }
    if (_selectedDevices.isEmpty && _selectedItems.isEmpty) {
      flatErrorToast(title: 'حداقل یک دستگاه یا قلم برگشتی انتخاب کنید');
      return;
    }
    // Quantities are deduct amounts: clamp each to its available stock so we
    // never send more than the form holds.
    final itemsPayload = <Map<String, dynamic>>[];
    for (final entry in _selectedItems.entries) {
      var available = 0;
      for (final item
          in _details?.installItems ?? const <InventoryLineItem>[]) {
        if (item.formItemId == entry.key) {
          available = item.quantity;
          break;
        }
      }
      final qty = available > 0 ? entry.value.clamp(1, available) : entry.value;
      itemsPayload.add({'form_item_id': entry.key, 'quantity': qty});
    }
    final data = <String, dynamic>{
      'project_name': _projectName,
      'original_form_id': form.id,
      'source': _source.text.trim(),
      'export_unit': _exportUnit.text.trim(),
      'posting_type': _postingType.text.trim(),
      'date_of_receipt': _date.text.trim(),
      if (_note.text.trim().isNotEmpty) 'note': _note.text.trim(),
      if (_selectedDevices.isNotEmpty) 'devices': _selectedDevices.toList(),
      if (_selectedItems.isNotEmpty) 'items': itemsPayload,
    };
    try {
      final result = await context.read<InventoryProvider>().submitReturnForm(
        data: data,
      );
      if (!mounted) return;
      final returnId = (result['data'] as Map?)?['return_form_id'];
      filledSuccessToast(
        title: returnId != null
            ? 'فرم برگشتی #$returnId با موفقیت ثبت شد'
            : 'فرم برگشتی با موفقیت ثبت شد',
      );
      Navigator.pop(context);
    } catch (e) {
      flatErrorToast(title: 'خطا در ثبت فرم برگشتی', description: e.toString());
    }
  }



  @override
  Widget build(BuildContext context) {
    final loading = context.watch<InventoryProvider>().submitLoading;
    final scheme = Theme.of(context).colorScheme;
    final deviceCount = _selectedDevices.length;
    final itemCount = _selectedItems.length;
    return BottomModalTemplate(
      title: 'فرم برگشتی',
      children: [
        InventoryFormHeader(
          title: 'ثبت فرم برگشتی',
          description:
              'فرم اصلی را انتخاب کنید، اقلام برگشتی را تیک بزنید و ثبت کنید.',
          icon: Icons.assignment_return_outlined,
          color: scheme.error,
        ),
        const SizedBox(height: 16),
        InventoryFormSection(
          title: 'فرم اصلی *',
          description: 'فرمی که اقلام از آن برگشت می‌خورند',
          icon: Icons.history_rounded,
          child: _OriginalFormSelector(
            selected: _selectedForm,
            onPick: _openFormPicker,
            onClear: _clearSelection,
          ),
        ),
        const SizedBox(height: 14),
        InventoryFormSection(
          title: 'اطلاعات برگشت',
          description: 'مبدأ، واحد صادرکننده و تاریخ برگشت',
          icon: Icons.fact_check_outlined,
          trailing: (_details ?? _selectedForm) == null
              ? null
              : TextButton.icon(
                  onPressed: _autofillFromOriginal,
                  icon: const Icon(Icons.copy_all_outlined, size: 16),
                  label: const Text('کپی از فرم اصلی'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
          child: Column(
            children: [
              pairFormFields(
                'مبدأ',
                _source,
                Icons.location_on_outlined,
                'واحد صادرکننده',
                _exportUnit,
                Icons.business_outlined,
              ),
              const SizedBox(height: 12),
              pairFormFields(
                'نوع ارسال',
                _postingType,
                Icons.local_shipping_outlined,
                'توضیحات',
                _note,
                Icons.notes_rounded,
                secondHint: 'اختیاری',
              ),
              const SizedBox(height: 12),
              InventoryFormField(
                label: 'تاریخ دریافت',
                controller: _date,
                icon: Icons.calendar_today_outlined,
                hint: '۱۴۰۵/۰۱/۰۱',
                readOnly: true,
                onTap: _pickDate,
                required: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        InventoryFormSection(
          title: 'دستگاه‌های برگشتی',
          description: _selectedForm == null
              ? 'اول فرم اصلی را انتخاب کنید.'
              : '${_returnableDevices.length} دستگاه قابل برگشت در فرم اصلی',
          icon: Icons.devices_other_outlined,
          trailing: _returnableDevices.isEmpty
              ? null
              : TextButton(
                  onPressed: () => setState(() {
                    if (_selectedDevices.length == _returnableDevices.length) {
                      _selectedDevices.clear();
                    } else {
                      _selectedDevices
                        ..clear()
                        ..addAll(_returnableDevices.map((d) => d.code));
                    }
                  }),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(
                    _selectedDevices.length == _returnableDevices.length
                        ? 'حذف همه'
                        : 'انتخاب همه',
                  ),
                ),
          child: _ReturnableDevices(
            selectedForm: _selectedForm,
            devices: _returnableDevices,
            alreadyReturnedCount: _alreadyReturnedCount,
            loading: _detailsLoading,
            error: _detailsError,
            selected: _selectedDevices,
            onToggle: (code) => setState(() {
              if (_selectedDevices.contains(code)) {
                _selectedDevices.remove(code);
              } else {
                _selectedDevices.add(code);
              }
            }),
            onRetry: () => _loadDetails(_selectedForm!.id),
          ),
        ),
        const SizedBox(height: 14),
        InventoryFormSection(
          title: 'اقلام برگشتی',
          description: _selectedForm == null
              ? 'اول فرم اصلی را انتخاب کنید.'
              : '${_details?.installItems.length ?? 0} قلم در فرم اصلی',
          icon: Icons.handyman_outlined,
          child: _ReturnableItems(
            selectedForm: _selectedForm,
            details: _details,
            loading: _detailsLoading,
            error: _detailsError,
            selected: _selectedItems,
            onToggle: (item) => setState(() {
              if (_selectedItems.containsKey(item.formItemId)) {
                _selectedItems.remove(item.formItemId);
              } else {
                // Default return amount is 1: the user edits how many units
                // to deduct, never the remaining stock.
                _selectedItems[item.formItemId] = 1;
              }
            }),
            onQuantityChanged: (item, qty) => setState(() {
              final max = item.quantity > 0 ? item.quantity : qty;
              _selectedItems[item.formItemId] = qty.clamp(1, max);
            }),
            onRetry: () => _loadDetails(_selectedForm!.id),
          ),
        ),
        if (deviceCount > 0 || itemCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              '$deviceCount دستگاه و $itemCount قلم برای برگشت انتخاب شده',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ModalBottomButtons(
          saveText: 'ثبت فرم برگشتی',
          isLoading: loading,
          onSave: loading ? null : _submit,
        ),
      ],
    );
  }
}

class _OriginalFormSelector extends StatelessWidget {
  final InventoryFormItem? selected;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const _OriginalFormSelector({
    required this.selected,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final form = selected;
    if (form == null) {
      return Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: onPick,
          borderRadius: BorderRadius.circular(9),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: scheme.primary.withValues(alpha: .5),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    size: 19,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'انتخاب فرم اصلی *',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'از لیست فرم‌ها جستجو و انتخاب کنید',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: scheme.outline),
              ],
            ),
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: scheme.primary.withValues(alpha: .35)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 19,
              color: scheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'فرم انبار #${form.id}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${form.destination} • ${form.dateOfReceipt}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onPick,
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            child: const Text('تغییر'),
          ),
          IconButton(
            tooltip: 'حذف انتخاب',
            visualDensity: VisualDensity.compact,
            onPressed: onClear,
            icon: Icon(Icons.close_rounded, size: 18, color: scheme.error),
          ),
        ],
      ),
    );
  }
}

class _OriginalFormPicker extends StatefulWidget {
  final int? selectedId;
  final ValueChanged<InventoryFormItem> onSelected;

  const _OriginalFormPicker({required this.onSelected, this.selectedId});

  @override
  State<_OriginalFormPicker> createState() => _OriginalFormPickerState();
}

class _OriginalFormPickerState extends State<_OriginalFormPicker> {
  static const _pageSize = 15;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  final _items = <InventoryFormItem>[];
  int _page = 0;
  bool _hasNext = true;
  int _totalCount = 0;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch(reset: true));
  }

  void _onScroll() {
    if (!_scrollController.hasClients ||
        _loading ||
        _loadingMore ||
        !_hasNext) {
      return;
    }
    if (_scrollController.position.extentAfter < 500) _fetch();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final query = value.trim();
      if (query == _query) return;
      setState(() => _query = query);
      _fetch(reset: true);
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    if (_query.isEmpty) return;
    setState(() => _query = '');
    _fetch(reset: true);
  }

  Future<void> _fetch({bool reset = false}) async {
    if (!reset && (_loadingMore || !_hasNext)) return;
    setState(() {
      if (reset) {
        _loading = true;
        _error = null;
      } else {
        _loadingMore = true;
      }
    });
    try {
      final res = await context
          .read<InventoryProvider>()
          .api
          .fetchDeviceItemsList(
            page: reset ? 1 : _page + 1,
            dataPerPage: _pageSize,
            destination: _query.isEmpty ? null : _query,
          );
      if (!mounted) return;
      final results = List<InventoryFormItem>.from(res['results'] as List);
      final page = res['page'] as int;
      final totalPages = res['pages'] as int;
      setState(() {
        if (reset) _items.clear();
        _items.addAll(results);
        _page = page;
        _hasNext = (res['has_next_page'] as bool?) ?? (page < totalPages);
        _totalCount = res['total_count'] as int;
        _loading = false;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      if (reset) {
        setState(() {
          _loading = false;
          _loadingMore = false;
          _error = e.toString();
        });
      } else {
        setState(() => _loadingMore = false);
        flatErrorToast(
          title: 'خطا در بارگذاری فرم‌های بیشتر',
          description: e.toString(),
        );
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          textInputAction: TextInputAction.search,
          style: Theme.of(context).textTheme.labelMedium,
          decoration: InputDecoration(
            hintText: 'جستجو با مقصد... مثلاً گلستان',
            hintStyle: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
            prefixIcon: _loading && _query.isNotEmpty
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.search_rounded, size: 20),
            suffixIcon: _searchController.text.isEmpty && _query.isEmpty
                ? null
                : IconButton(
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    tooltip: 'پاک کردن جستجو',
                  ),
            filled: true,
            fillColor: scheme.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: BorderSide(
                color: scheme.outline.withValues(alpha: .4),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: BorderSide(
                color: scheme.outline.withValues(alpha: .4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _loading ? 'در حال جستجو...' : '$_totalCount فرم',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Flexible(child: _buildList(context)),
      ],
    );

    if (MediaQuery.sizeOf(context).width >= 900) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 560, maxHeight: 620),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'انتخاب فرم اصلی',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(child: content),
              ],
            ),
          ),
        ),
      );
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            left: 15,
            right: 15,
            top: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'انتخاب فرم اصلی',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.7,
                ),
                child: content,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Returned forms can never be a return source: only original
    // (non-returned) forms are shown. The list API carries no install
    // items, so the row shows just the device count.
    final forms = _items.where((form) => !form.isReturned).toList();
    if (_loading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 34, color: scheme.error),
              const SizedBox(height: 8),
              Text(
                'خطا در بارگذاری فرم‌ها',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => _fetch(reset: true),
                child: const Text('تلاش مجدد'),
              ),
            ],
          ),
        ),
      );
    }
    if (forms.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_outlined, size: 34, color: scheme.outline),
              const SizedBox(height: 8),
              Text(
                _query.isEmpty
                    ? 'فرمی پیدا نشد'
                    : 'فرمی با مقصد «$_query» پیدا نشد',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      controller: _scrollController,
      shrinkWrap: true,
      itemCount: forms.length + (_loadingMore || _hasNext ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == forms.length) {
          if (!_hasNext) return const SizedBox.shrink();
          if (!_loadingMore) {
            // Prefetch next page when the trailing slot becomes visible.
            WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
          }
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Center(
              child: SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final form = forms[index];
        final isSelected = form.id == widget.selectedId;
        return Material(
          color: isSelected
              ? scheme.primary.withValues(alpha: .08)
              : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () {
              widget.onSelected(form);
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? scheme.primary.withValues(alpha: .6)
                      : scheme.outline.withValues(alpha: .3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.receipt_long_outlined,
                      size: 17,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'فرم #${form.id} • ${form.destination}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${form.exportUnit} • ${form.deviceCount} دستگاه',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle_rounded,
                      size: 20,
                      color: scheme.primary,
                    )
                  else
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: scheme.outline,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ReturnableDevices extends StatelessWidget {
  final InventoryFormItem? selectedForm;
  final List<InventoryDevice> devices;
  final int alreadyReturnedCount;
  final bool loading;
  final String? error;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback onRetry;

  const _ReturnableDevices({
    required this.selectedForm,
    required this.devices,
    required this.alreadyReturnedCount,
    required this.loading,
    required this.error,
    required this.selected,
    required this.onToggle,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedForm == null) {
      return const InventoryEmptyItems(
        message: 'برای مشاهده دستگاه‌ها، اول فرم اصلی را انتخاب کنید.',
      );
    }
    if (loading) {
      return const SizedBox(
        height: 90,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return _RetryBox(message: 'خطا در بارگذاری جزئیات فرم', onRetry: onRetry);
    }
    if (devices.isEmpty) {
      return InventoryEmptyItems(
        message: alreadyReturnedCount > 0
            ? 'همه دستگاه‌های این فرم قبلاً برگشت خورده‌اند.'
            : 'این فرم دستگاهی ندارد؛ از بخش اقلام استفاده کنید.',
      );
    }
    return Column(
      children: [
        if (alreadyReturnedCount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InventoryEmptyItems(
              message:
                  '$alreadyReturnedCount دستگاه قبلاً برگشت خورده و نمایش داده نشده است.',
            ),
          ),
        for (final device in devices)
          _SelectableTile(
            checked: selected.contains(device.code),
            onTap: () => onToggle(device.code),
            title: device.code,
            subtitle: '${device.deviceType} • ${device.serialNumber}'.trim(),
            trailing: selected.contains(device.code)
                ? Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : Icon(
                    Icons.radio_button_unchecked_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.outline,
                  ),
          ),
      ],
    );
  }
}

class _ReturnableItems extends StatelessWidget {
  final InventoryFormItem? selectedForm;
  final InventoryFormItem? details;
  final bool loading;
  final String? error;
  final Map<int, int> selected;
  final ValueChanged<InventoryLineItem> onToggle;
  final void Function(InventoryLineItem item, int qty) onQuantityChanged;
  final VoidCallback onRetry;

  const _ReturnableItems({
    required this.selectedForm,
    required this.details,
    required this.loading,
    required this.error,
    required this.selected,
    required this.onToggle,
    required this.onQuantityChanged,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedForm == null) {
      return const InventoryEmptyItems(
        message: 'برای مشاهده اقلام، اول فرم اصلی را انتخاب کنید.',
      );
    }
    if (loading) {
      return const SizedBox(
        height: 90,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return _RetryBox(message: 'خطا در بارگذاری جزئیات فرم', onRetry: onRetry);
    }
    final items = details?.installItems ?? const [];
    if (items.isEmpty) {
      return const InventoryEmptyItems(
        message: 'این فرم قلمی ندارد؛ از بخش دستگاه‌ها استفاده کنید.',
      );
    }
    return Column(
      children: [
        for (final item in items)
          _ItemTile(
            item: item,
            checked: selected.containsKey(item.formItemId),
            quantity: selected[item.formItemId] ?? 1,
            onToggle: item.formItemId <= 0 ? null : () => onToggle(item),
            onQuantityChanged: (qty) => onQuantityChanged(item, qty),
          ),
      ],
    );
  }
}

class _SelectableTile extends StatelessWidget {
  final bool checked;
  final VoidCallback onTap;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SelectableTile({
    required this.checked,
    required this.onTap,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: checked
            ? scheme.primary.withValues(alpha: .07)
            : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: checked
                    ? scheme.primary.withValues(alpha: .55)
                    : scheme.outline.withValues(alpha: .3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (subtitle.trim().isNotEmpty &&
                          subtitle.trim() != '•') ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final InventoryLineItem item;
  final bool checked;
  final int quantity;
  final VoidCallback? onToggle;
  final ValueChanged<int> onQuantityChanged;

  const _ItemTile({
    required this.item,
    required this.checked,
    required this.quantity,
    required this.onToggle,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final max = item.quantity > 0 ? item.quantity : 999;
    final missingId = item.formItemId <= 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: checked
            ? scheme.primary.withValues(alpha: .07)
            : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: checked
                    ? scheme.primary.withValues(alpha: .55)
                    : scheme.outline.withValues(alpha: .3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.itemType.isEmpty
                                ? 'قلم #${item.formItemId}'
                                : item.itemType,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            missingId
                                ? 'شناسه قلم در دسترس نیست'
                                : 'موجودی فرم: ${item.quantity} • شناسه: ${item.formItemId}',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: missingId
                                      ? scheme.error
                                      : scheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      checked
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 20,
                      color: checked ? scheme.primary : scheme.outline,
                    ),
                  ],
                ),
                if (checked && !missingId) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'تعداد برگشتی',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      _StepperButton(
                        icon: Icons.remove_rounded,
                        onPressed: quantity > 1
                            ? () => onQuantityChanged(quantity - 1)
                            : null,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: scheme.outline.withValues(alpha: .35),
                          ),
                        ),
                        child: Text(
                          '$quantity',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      _StepperButton(
                        icon: Icons.add_rounded,
                        onPressed: quantity < max
                            ? () => onQuantityChanged(quantity + 1)
                            : null,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _StepperButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: onPressed == null
          ? scheme.surfaceContainerHighest
          : scheme.primary.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(
            icon,
            size: 17,
            color: onPressed == null ? scheme.outline : scheme.primary,
          ),
        ),
      ),
    );
  }
}

class _RetryBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _RetryBox({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.error.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: scheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('تلاش مجدد')),
        ],
      ),
    );
  }
}
