import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/shared/filter_inventory_modal.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/shared/inventory_action_buttons.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/list/inventory_forms_table.dart';
import 'package:shooka_flutter/(tabs)/inventory_management/components/insights/inventory_insights.dart';
import 'package:shooka_flutter/services/providers/inventory_provider.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';
import 'package:shooka_flutter/utils/scaffolds/back_scaffold.dart';
import 'package:shooka_flutter/utils/toastifications/toasts.dart';

class InventoryManagementTab extends StatefulWidget {
  const InventoryManagementTab({super.key});

  @override
  State<InventoryManagementTab> createState() => _InventoryManagementTabState();
}

class _InventoryManagementTabState extends State<InventoryManagementTab> {
  final TextEditingController searchController = TextEditingController();

  /// Guards against double-tap on the Excel export (each tap would rebuild
  /// and download a whole workbook).
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<InventoryProvider>().loadForms();
    });
  }

  Future<void> _handleRefresh() =>
      context.read<InventoryProvider>().loadForms();

  /// Builds the day-by-day Excel workbook for the forms currently in view
  /// (search + filters applied).
  Future<void> _exportForms() async {
    if (_exporting) return;
    final provider = context.read<InventoryProvider>();
    if (provider.forms.isEmpty) {
      flatErrorToast(title: 'فرمی برای خروجی گرفتن وجود ندارد');
      return;
    }
    setState(() => _exporting = true);
    try {
      final count = await provider.exportFormsToExcel();
      if (!mounted) return;
      filledSuccessToast(title: 'خروجی اکسل $count فرم آماده شد');
    } catch (e) {
      if (!mounted) return;
      flatErrorToast(
        title: 'خطا در تهیه خروجی اکسل',
        description: e.toString(),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  void _openFilters() {
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;
    if (isDesktop) {
      showDialog(
        context: context,
        builder: (_) => const FilterInventoryModal(),
      );
    } else {
      showMaterialModalBottomSheet(
        context: context,
        enableDrag: false,
        builder: (_) => const FilterInventoryModal(),
      );
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();

    return BackScaffold(
      label: 'مدیریت انبار',
      backLabel: 'خانه',
      backRoute: '/home',
      onRefresh: _handleRefresh,
      body: DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _InventoryTabBar(),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                children: [
                  _OperationsTab(
                    searchController: searchController,
                    onSearch: provider.setSearch,
                    onClear: () {
                      searchController.clear();
                      provider.setSearch('');
                    },
                    onFilter: _openFilters,
                    onExport: _exportForms,
                    exporting: _exporting,
                    loading: provider.fetchLoading,
                  ),
                  const InventoryInsights(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryTabBar extends StatelessWidget {
  const _InventoryTabBar();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // Tinted thumb + colored active label instead of a solid primary slab,
    // so the control stays legible and calm in both light and dark themes.
    final activeColor = scheme.primary;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        // border: Border.all(color: scheme.outline.withValues(alpha: 0.35)),
      ),
      child: TabBar(
        padding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        indicatorPadding: EdgeInsets.zero,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: activeColor.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: activeColor.withValues(alpha: 0.35)),
        ),
        labelColor: activeColor,
        unselectedLabelColor: scheme.onSurfaceVariant,
        labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
        unselectedLabelStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit_note_rounded, size: 19),
                SizedBox(width: 6),
                Text('عملیات و فرم‌ها'),
              ],
            ),
          ),
          Tab(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.insights_rounded, size: 19),
                SizedBox(width: 6),
                Text('آمار و گزارش‌ها'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OperationsTab extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final VoidCallback onClear;
  final VoidCallback onFilter;
  final VoidCallback onExport;
  final bool exporting;
  final bool loading;

  const _OperationsTab({
    required this.searchController,
    required this.onSearch,
    required this.onClear,
    required this.onFilter,
    required this.onExport,
    required this.exporting,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();
    final hasFilters =
        provider.destinationFilter.trim().isNotEmpty ||
        provider.startFilter.trim().isNotEmpty ||
        provider.endFilter.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const InventoryActionButtons(),
        const SizedBox(height: 16),
        _InventoryToolbar(
          controller: searchController,
          filtersActive: hasFilters,
          onSearch: onSearch,
          onClear: onClear,
          onFilter: onFilter,
          onExport: onExport,
          exporting: exporting,
        ),
        const SizedBox(height: 10),
        _StatusRow(
          count: provider.totalCount,
          hasFilters: hasFilters,
          loading: loading,
        ),
        const SizedBox(height: 10),
        Expanded(
          child: loading ? const _TableLoading() : const InventoryFormsTable(),
        ),
      ],
    );
  }
}

/// Slim context line under the toolbar: live form count + a one-tap
/// clear-filters action when filters are applied.
class _StatusRow extends StatelessWidget {
  final int count;
  final bool hasFilters;
  final bool loading;

  const _StatusRow({
    required this.count,
    required this.hasFilters,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 15,
              color: scheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            loading ? 'در حال بارگذاری…' : '$count فرم',
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          if (hasFilters && !loading) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: scheme.tertiary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                'فیلتر فعال',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.tertiary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (hasFilters && !loading)
            TextButton.icon(
              onPressed: () => context.read<InventoryProvider>().setFilters(
                destination: '',
                start: '',
                end: '',
              ),
              icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
              label: const Text('حذف فیلترها'),
              style: TextButton.styleFrom(
                foregroundColor: scheme.primary,
                visualDensity: VisualDensity.compact,
                textStyle: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TableLoading extends StatelessWidget {
  const _TableLoading();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          // border: Border.all(color: scheme.outline.withValues(alpha: 0.35)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox.square(
              dimension: 30,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 14),
            Text(
              'در حال بارگذاری فرم‌ها…',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryToolbar extends StatelessWidget {
  final TextEditingController controller;
  final bool filtersActive;
  final ValueChanged<String> onSearch;
  final VoidCallback onClear;
  final VoidCallback onFilter;
  final VoidCallback onExport;
  final bool exporting;

  const _InventoryToolbar({
    required this.controller,
    required this.filtersActive,
    required this.onSearch,
    required this.onClear,
    required this.onFilter,
    required this.onExport,
    required this.exporting,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 650;
        final fieldBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: scheme.onSurface.withValues(alpha: 0.08),
          ),
        );
        final search = TextField(
          controller: controller,
          onChanged: onSearch,
          onSubmitted: onSearch,
          textInputAction: TextInputAction.search,
          style: textTheme.labelMedium,
          decoration: InputDecoration(
            hintText: 'جستجو در فرم‌ها، مقصد یا شماره سریال...',
            hintStyle: textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 20,
              color: scheme.onSurfaceVariant,
            ),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    tooltip: 'پاک کردن جستجو',
                  ),
            filled: true,
            fillColor: scheme.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            border: fieldBorder,
            enabledBorder: fieldBorder,
            focusedBorder: fieldBorder.copyWith(
              borderSide: BorderSide(color: scheme.primary, width: 1.5),
            ),
          ),
        );

        final filterButton = ContainerButton(
          borderRadius: 12,
          color: scheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
          onPressed: onFilter,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.tune_rounded, size: 18, color: Colors.white),
                  if (filtersActive)
                    PositionedDirectional(
                      top: -3,
                      end: -3,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: scheme.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 6),
              Text(
                'فیلتر',
                style: textTheme.labelLarge?.apply(color: Colors.white),
              ),
            ],
          ),
        );

        // Export: tinted (not solid) so it reads as a secondary action next
        // to the primary «فیلتر» button.
        final exportButton = ContainerButton(
          borderRadius: 12,
          color: scheme.primary.withValues(alpha: 0.12),
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
          onPressed: onExport,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (exporting)
                SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: scheme.primary,
                  ),
                )
              else
                Icon(
                  Icons.download_rounded,
                  size: 18,
                  color: scheme.primary,
                ),
              const SizedBox(width: 6),
              Text(
                compact ? 'اکسل' : 'خروجی اکسل',
                style: textTheme.labelLarge?.apply(color: scheme.primary),
              ),
            ],
          ),
        );

        // Actions: side by side and stretched on compact screens, inline
        // next to the search field on wider layouts.
        final actions = compact
            ? Row(
                children: [
                  Expanded(child: filterButton),
                  const SizedBox(width: 10),
                  Expanded(child: exportButton),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  filterButton,
                  const SizedBox(width: 10),
                  exportButton,
                ],
              );

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(14),
            // border: Border.all(color: scheme.outline.withValues(alpha: 0.35)),
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [search, const SizedBox(height: 10), actions],
                )
              : Row(
                  children: [
                    Expanded(child: search),
                    const SizedBox(width: 12),
                    actions,
                  ],
                ),
        );
      },
    );
  }
}
