import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/details/detail_widgets.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/details/form_details_view.dart';
import 'package:shooka_flutter/models/inventory_form_data_class.dart';
import 'package:shooka_flutter/services/providers/inventory_provider.dart';

class InventoryFormsTable extends StatefulWidget {
  const InventoryFormsTable({super.key});

  @override
  State<InventoryFormsTable> createState() => _InventoryFormsTableState();
}

/// API returns Jalali datetimes like `1405/06/12 00:00:00`; the table only
/// shows the date part.
String _dateOnly(String value) => value.split(' ').first;

/// Client-side sort by the Jalali receipt date — the zero-padded
/// `1405/06/12 00:00:00` format orders correctly with plain string
/// comparison. Empty dates always sink to the end, whatever the direction.
List<InventoryFormItem> _sortFormsByDate(
  List<InventoryFormItem> forms,
  bool ascending,
) {
  final sorted = List<InventoryFormItem>.of(forms);
  sorted.sort((a, b) {
    final da = a.dateOfReceipt;
    final db = b.dateOfReceipt;
    if (da.isEmpty && db.isEmpty) return 0;
    if (da.isEmpty) return 1;
    if (db.isEmpty) return -1;
    final cmp = da.compareTo(db);
    return ascending ? cmp : -cmp;
  });
  return sorted;
}

/// Client-side sort by the form id (largest first unless [ascending]).
List<InventoryFormItem> _sortFormsById(
  List<InventoryFormItem> forms,
  bool ascending,
) {
  final sorted = List<InventoryFormItem>.of(forms);
  sorted.sort((a, b) {
    final cmp = a.id.compareTo(b.id);
    return ascending ? cmp : -cmp;
  });
  return sorted;
}

/// Tooltip for a sortable header, reflecting the column's current state.
String _sortTooltip(String label, bool active, bool ascending) {
  if (!active) return 'مرتب‌سازی بر اساس $label';
  return ascending ? '$label: صعودی' : '$label: نزولی';
}

/// Sortable columns of the desktop table header.
enum _FormSortColumn { id, date }

class _InventoryFormsTableState extends State<InventoryFormsTable> {
  final _scrollController = ScrollController();

  /// Active sort column, or `null` while the server's original order is shown.
  /// First tap on a column sorts it descending (newest / largest first), the
  /// next tap flips the direction.
  _FormSortColumn? _sortColumn;
  bool _sortAscending = false;

  void _toggleSort(_FormSortColumn column) => setState(() {
    if (_sortColumn != column) {
      _sortColumn = column;
      _sortAscending = false; // first tap on a column: descending
    } else {
      _sortAscending = !_sortAscending;
    }
  });

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.extentAfter < 500) {
      context.read<InventoryProvider>().loadMoreForms();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();
    final forms = switch (_sortColumn) {
      null => provider.forms,
      _FormSortColumn.date => _sortFormsByDate(
        provider.forms,
        _sortAscending,
      ),
      _FormSortColumn.id => _sortFormsById(provider.forms, _sortAscending),
    };
    if (forms.isEmpty) return const _EmptyFormsState();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 860) {
          return _DesktopFormsTable(
            forms: forms,
            provider: provider,
            controller: _scrollController,
            sortColumn: _sortColumn,
            sortAscending: _sortAscending,
            onSort: _toggleSort,
          );
        }
        return _MobileFormsList(
          forms: forms,
          provider: provider,
          controller: _scrollController,
          sortColumn: _sortColumn,
          sortAscending: _sortAscending,
          onSort: _toggleSort,
        );
      },
    );
  }
}

class _DesktopFormsTable extends StatelessWidget {
  final List<InventoryFormItem> forms;
  final InventoryProvider provider;
  final ScrollController controller;

  /// Active sort column (`null` = server's original order, no arrow shown).
  final _FormSortColumn? sortColumn;
  final bool sortAscending;
  final ValueChanged<_FormSortColumn> onSort;

  const _DesktopFormsTable({
    required this.forms,
    required this.provider,
    required this.controller,
    required this.sortColumn,
    required this.sortAscending,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        // Keeps the table distinct from the page without the stark white
        // contrast that surface can produce in light mode.
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Scrollbar(
        controller: controller,
        thumbVisibility: true,
        trackVisibility: true,
        scrollbarOrientation: ScrollbarOrientation.right,
        thickness: 7,
        radius: const Radius.circular(4),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.only(bottom: 12),
          children: [
            LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DividerTheme(
                    // DataTable uses DividerTheme under Material 3 rather
                    // than ThemeData.dividerColor for its row borders. A
                    // low-opacity on-surface tint stays subtle in either mode.
                    data: DividerThemeData(
                      color: scheme.onSurface.withValues(alpha: 0.08),
                      thickness: 0.75,
                    ),
                    child: DataTableTheme(
                      data: const DataTableThemeData(dividerThickness: 0.75),
                      child: DataTable(
                        dividerThickness: 0.75,
                        showCheckboxColumn: false,
                        columnSpacing: 28,
                        horizontalMargin: 20,
                        headingRowHeight: 48,
                        dataRowMinHeight: 62,
                        dataRowMaxHeight: 72,
                        headingTextStyle: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                        dataTextStyle: textTheme.labelMedium?.copyWith(
                          color: scheme.onSurface,
                        ),
                        headingRowColor: WidgetStatePropertyAll(
                          scheme.surfaceContainer,
                        ),
                        columns: [
                          DataColumn(
                            label: _SortHeaderLabel(
                              label: 'شناسه',
                              active: sortColumn == _FormSortColumn.id,
                              ascending: sortAscending,
                            ),
                            headingRowAlignment: MainAxisAlignment.center,
                            tooltip: _sortTooltip(
                              'شناسه',
                              sortColumn == _FormSortColumn.id,
                              sortAscending,
                            ),
                            onSort: (_, __) => onSort(_FormSortColumn.id),
                          ),
                          const DataColumn(
                            label: Text('نوع فرم'),
                            headingRowAlignment: MainAxisAlignment.center,
                          ),
                          const DataColumn(
                            label: Text('مقصد'),
                            headingRowAlignment: MainAxisAlignment.center,
                          ),
                          const DataColumn(
                            label: Text('واحد صادرکننده'),
                            headingRowAlignment: MainAxisAlignment.center,
                          ),
                          const DataColumn(
                            label: Text('نوع ارسال'),
                            headingRowAlignment: MainAxisAlignment.center,
                          ),
                          DataColumn(
                            label: _SortHeaderLabel(
                              label: 'تاریخ',
                              active: sortColumn == _FormSortColumn.date,
                              ascending: sortAscending,
                            ),
                            headingRowAlignment: MainAxisAlignment.center,
                            tooltip: _sortTooltip(
                              'تاریخ',
                              sortColumn == _FormSortColumn.date,
                              sortAscending,
                            ),
                            onSort: (_, __) => onSort(_FormSortColumn.date),
                          ),
                          const DataColumn(
                            label: Text('تعداد'),
                            headingRowAlignment: MainAxisAlignment.center,
                          ),
                        ],
                        rows: [
                          for (final form in forms)
                            DataRow(
                              onSelectChanged: (_) =>
                                  showFormDetails(context, form),
                              cells: [
                                DataCell(Center(child: Text('#${form.id}'))),
                                DataCell(
                                  Center(
                                    child: _FormKindPill(kind: form.kind),
                                  ),
                                ),
                                DataCell(
                                  Center(child: _TableText(form.destination)),
                                ),
                                DataCell(
                                  Center(child: _TableText(form.exportUnit)),
                                ),
                                DataCell(
                                  Center(child: _TableText(form.postingType)),
                                ),
                                DataCell(
                                  Center(
                                    child: _TableText(
                                      _dateOnly(form.dateOfReceipt),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: _CountPill(
                                      count:
                                          form.deviceCount +
                                          form.installItems.length,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (provider.isLoadingMore)
              const Padding(
                padding: EdgeInsets.all(14),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

class _MobileFormsList extends StatelessWidget {
  final List<InventoryFormItem> forms;
  final InventoryProvider provider;
  final ScrollController controller;

  /// Same sort state as the desktop header — cards get the same control via
  /// [_SortBar] because there is no clickable column header on mobile.
  final _FormSortColumn? sortColumn;
  final bool sortAscending;
  final ValueChanged<_FormSortColumn> onSort;

  const _MobileFormsList({
    required this.forms,
    required this.provider,
    required this.controller,
    required this.sortColumn,
    required this.sortAscending,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SortBar(
          sortColumn: sortColumn,
          sortAscending: sortAscending,
          onSort: onSort,
        ),
        Expanded(
          child: Scrollbar(
            controller: controller,
            thumbVisibility: true,
            trackVisibility: true,
            scrollbarOrientation: ScrollbarOrientation.right,
            thickness: 7,
            radius: const Radius.circular(4),
            child: ListView.separated(
              controller: controller,
              padding: const EdgeInsets.only(bottom: 12),
              itemCount: forms.length + (provider.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == forms.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return _MobileFormCard(form: forms[index]);
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact sort control above the mobile card list: one chip per sortable
/// column, arrow shown only on the active one.
class _SortBar extends StatelessWidget {
  final _FormSortColumn? sortColumn;
  final bool sortAscending;
  final ValueChanged<_FormSortColumn> onSort;

  const _SortBar({
    required this.sortColumn,
    required this.sortAscending,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            'مرتب‌سازی',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          _SortChip(
            label: 'شناسه',
            active: sortColumn == _FormSortColumn.id,
            ascending: sortAscending,
            onTap: () => onSort(_FormSortColumn.id),
          ),
          const SizedBox(width: 8),
          _SortChip(
            label: 'تاریخ',
            active: sortColumn == _FormSortColumn.date,
            ascending: sortAscending,
            onTap: () => onSort(_FormSortColumn.date),
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool active;
  final bool ascending;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.active,
    required this.ascending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = active ? scheme.primary : scheme.onSurfaceVariant;
    return Material(
      color: active
          ? scheme.primary.withValues(alpha: 0.12)
          : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (active) ...[
                const SizedBox(width: 4),
                Icon(
                  ascending
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 13,
                  color: foreground,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileFormCard extends StatelessWidget {
  final InventoryFormItem form;

  const _MobileFormCard({required this.form});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final borderColor = scheme.outline.withValues(alpha: 0.45);
    final textTheme = Theme.of(context).textTheme;
    final kindColor = switch (form.kind) {
      InventoryFormType.returned => scheme.error,
      InventoryFormType.pack => scheme.primary,
      InventoryFormType.parts => scheme.tertiary,
    };
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => showFormDetails(context, form),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _FormIcon(color: kindColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'فرم انبار #${form.id}',
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          form.postingType.isEmpty
                              ? 'بدون نوع ارسال'
                              : form.postingType,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _FormKindPill(kind: form.kind),
                  const SizedBox(width: 6),
                  _CountPill(
                    count: form.deviceCount + form.installItems.length,
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_left_rounded, color: scheme.outline),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 18,
                runSpacing: 10,
                children: [
                  InfoItem(
                    icon: Icons.location_on_outlined,
                    label: 'مقصد',
                    value: form.destination,
                  ),
                  InfoItem(
                    icon: Icons.business_outlined,
                    label: 'واحد صادرکننده',
                    value: form.exportUnit,
                  ),
                  InfoItem(
                    icon: Icons.calendar_today_outlined,
                    label: 'تاریخ',
                    value: _dateOnly(form.dateOfReceipt),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sortable header cell: label + direction arrow. While the server's
/// default order is active ([active] is `false`), no arrow is shown.
class _SortHeaderLabel extends StatelessWidget {
  final String label;
  final bool active;
  final bool ascending;

  const _SortHeaderLabel({
    required this.label,
    required this.active,
    required this.ascending,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        if (active) ...[
          const SizedBox(width: 4),
          Icon(
            ascending
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            size: 14,
          ),
        ],
      ],
    );
  }
}

class _EmptyFormsState extends StatelessWidget {
  const _EmptyFormsState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 34, color: scheme.outline),
            const SizedBox(height: 10),
            Text(
              'فرمی پیدا نشد',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'عبارت جستجو یا فیلترها را تغییر دهید.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormIcon extends StatelessWidget {
  final Color color;

  const _FormIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(Icons.receipt_long_outlined, size: 19, color: color),
    );
  }
}

class _CountPill extends StatelessWidget {
  final int count;

  const _CountPill({required this.count});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$count قلم',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FormKindPill extends StatelessWidget {
  final InventoryFormType kind;

  const _FormKindPill({required this.kind});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (color, icon) = switch (kind) {
      InventoryFormType.returned => (
        scheme.error,
        Icons.assignment_return_outlined,
      ),
      InventoryFormType.pack => (scheme.primary, Icons.inventory_2_outlined),
      InventoryFormType.parts => (scheme.tertiary, Icons.handyman_outlined),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            kind.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TableText extends StatelessWidget {
  final String value;

  const _TableText(this.value);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 150),
      child: Text(
        value.isEmpty ? '—' : value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}
