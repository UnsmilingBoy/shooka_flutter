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

class _InventoryFormsTableState extends State<InventoryFormsTable> {
  final _scrollController = ScrollController();

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
    final forms = provider.forms;
    if (forms.isEmpty) return const _EmptyFormsState();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 860) {
          return _DesktopFormsTable(
            forms: forms,
            provider: provider,
            controller: _scrollController,
          );
        }
        return _MobileFormsList(
          forms: forms,
          provider: provider,
          controller: _scrollController,
        );
      },
    );
  }
}

class _DesktopFormsTable extends StatelessWidget {
  final List<InventoryFormItem> forms;
  final InventoryProvider provider;
  final ScrollController controller;

  const _DesktopFormsTable({
    required this.forms,
    required this.provider,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final borderColor = scheme.outline.withValues(alpha: 0.45);
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Scrollbar(
        controller: controller,
        thumbVisibility: true,
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.only(bottom: 12),
          children: [
            LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTableTheme(
                    data: const DataTableThemeData(dividerThickness: 0),
                    child: DataTable(
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
                        scheme.surfaceContainerHighest,
                      ),
                      columns: const [
                        DataColumn(label: Text('شناسه')),
                        DataColumn(label: Text('نوع فرم')),
                        DataColumn(label: Text('مقصد')),
                        DataColumn(label: Text('واحد صادرکننده')),
                        DataColumn(label: Text('نوع ارسال')),
                        DataColumn(label: Text('مبلغ')),
                        DataColumn(label: Text('تاریخ')),
                        DataColumn(label: Text('تعداد')),
                      ],
                      rows: [
                        for (final form in forms)
                          DataRow(
                            onSelectChanged: (_) =>
                                showFormDetails(context, form),
                            cells: [
                              DataCell(Text('#${form.id}')),
                              DataCell(_FormKindPill(kind: form.kind)),
                              DataCell(_TableText(form.destination)),
                              DataCell(_TableText(form.exportUnit)),
                              DataCell(_TableText(form.postingType)),
                              DataCell(_TableText(form.amount)),
                              DataCell(_TableText(form.dateOfReceipt)),
                              DataCell(
                                _CountPill(
                                  count:
                                      form.deviceCount +
                                      form.installItems.length,
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

  const _MobileFormsList({
    required this.forms,
    required this.provider,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
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
                    value: form.dateOfReceipt,
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

class _EmptyFormsState extends StatelessWidget {
  const _EmptyFormsState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final borderColor = scheme.outline.withValues(alpha: 0.45);
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
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
      ),
    );
  }
}
