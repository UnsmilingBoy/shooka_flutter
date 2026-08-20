import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/accounting/components/accounting_detail_panel.dart';
import 'package:shooka_flutter/(tabs)/accounting/components/filter_accounting_modal.dart';
import 'package:shooka_flutter/components/tab_header.dart';
import 'package:shooka_flutter/models/factor_data_class.dart';
import 'package:shooka_flutter/services/providers/accounting_provider.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';
import 'package:shooka_flutter/utils/loadings/loading.dart';
import 'package:shooka_flutter/utils/scaffolds/back_scaffold.dart';

class AccountingTab extends StatefulWidget {
  const AccountingTab({super.key});

  @override
  State<AccountingTab> createState() => _AccountingTabState();
}

class _AccountingTabState extends State<AccountingTab> {
  final ScrollController _scrollController = ScrollController();
  late final AccountingProvider _accountingProvider;

  Factor? _selectedFactor;
  String searchValue = '';

  @override
  void initState() {
    super.initState();

    _accountingProvider = context.read<AccountingProvider>();

    Future.microtask(() async {
      await _accountingProvider.loadFactors();
      if (mounted) _checkAndLoadMoreIfNeeded();
    });

    _scrollController.addListener(_onScroll);
    _accountingProvider.addListener(_onFactorListChanged);
  }

  void _onFactorListChanged() {
    if (mounted && !context.read<AccountingProvider>().fetchLoading) {
      // Refresh selected factor with latest data
      if (_selectedFactor != null) {
        final factors = context.read<AccountingProvider>().factors;
        final updated = factors.firstWhere(
          (f) => f.factorId == _selectedFactor!.factorId,
          orElse: () => _selectedFactor!,
        );
        if (mounted) setState(() => _selectedFactor = updated);
      }
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _checkAndLoadMoreIfNeeded();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _accountingProvider.removeListener(_onFactorListChanged);
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      final provider = context.read<AccountingProvider>();
      if (!provider.fetchLoading) {
        provider.nextPage();
      }
    }
  }

  void _checkAndLoadMoreIfNeeded() {
    if (!mounted) return;
    final provider = context.read<AccountingProvider>();
    if (_scrollController.hasClients) {
      final position = _scrollController.position;
      if (position.maxScrollExtent <= 0 &&
          provider.page < provider.totalPages &&
          !provider.nextPageLoading) {
        provider.nextPage().then((_) {
          if (mounted) {
            Future.delayed(
              const Duration(milliseconds: 100),
              _checkAndLoadMoreIfNeeded,
            );
          }
        });
      }
    } else {
      Future.delayed(
        const Duration(milliseconds: 100),
        _checkAndLoadMoreIfNeeded,
      );
    }
  }

  void _selectFactor(Factor factor) => setState(() => _selectedFactor = factor);
  void _closeDetailPanel() => setState(() => _selectedFactor = null);

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    final accountingProvider = context.watch<AccountingProvider>();
    final factors = accountingProvider.factors;
    final getLoading = accountingProvider.fetchLoading;
    final nextPageLoading = accountingProvider.nextPageLoading;
    final screenWidth = MediaQuery.of(context).size.width;

    final bool canUseSplitView = screenWidth > 1200;
    final bool showSplitView = canUseSplitView && _selectedFactor != null;

    return BackScaffold(
      backLabel: 'خانه',
      backRoute: '/home',
      label: 'پنل حسابداری',
      body: showSplitView
          ? _buildSplitView(
              context,
              accountingProvider,
              factors,
              searchController,
              getLoading,
              nextPageLoading,
            )
          : _buildNormalView(
              context,
              accountingProvider,
              factors,
              searchController,
              getLoading,
              nextPageLoading,
              canUseSplitView,
            ),
    );
  }

  //
  // Split View (wide screens)
  //
  Widget _buildSplitView(
    BuildContext context,
    AccountingProvider accountingProvider,
    List<Factor> factors,
    TextEditingController searchController,
    bool getLoading,
    bool nextPageLoading,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Factor list panel
        Expanded(
          flex: 4,
          child: Column(
            children: [
              TabHeader(
                onSubmitted: (value) async {
                  setState(() => searchValue = value);
                  await accountingProvider.loadFactors(search: value);
                },
                searchController: searchController,
                filterModal: const FilterAccountingModal(),
                searchPlaceholder: 'جستجوی فاکتور...',
              ),
              const SizedBox(height: 10),
              if (searchValue.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'نتایج جستجو برای: $searchValue',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: getLoading
                    ? const Center(child: Loading())
                    : factors.isEmpty
                    ? const Center(child: Text('فاکتوری یافت نشد.'))
                    : _buildFactorListView(
                        context,
                        factors,
                        nextPageLoading,
                        enableSplitViewClick: true,
                      ),
              ),
            ],
          ),
        ),

        // Detail panel
        const SizedBox(width: 16),
        Expanded(
          flex: 6,
          child: AccountingDetailPanel(
            key: ValueKey(_selectedFactor!.factorId),
            factor: _selectedFactor!,
            onClose: _closeDetailPanel,
          ),
        ),
      ],
    );
  }

  //
  // Normal View (small screens)
  //
  Widget _buildNormalView(
    BuildContext context,
    AccountingProvider accountingProvider,
    List<Factor> factors,
    TextEditingController searchController,
    bool getLoading,
    bool nextPageLoading,
    bool canUseSplitView,
  ) {
    return Column(
      spacing: 10,
      children: [
        TabHeader(
          onSubmitted: (value) async {
            setState(() => searchValue = value);
            await accountingProvider.loadFactors(search: value);
          },
          searchController: searchController,
          filterModal: const FilterAccountingModal(),
          searchPlaceholder: 'جستجوی فاکتور...',
        ),
        if (searchValue.isNotEmpty)
          Row(
            children: [
              Expanded(
                child: Text(
                  'نتایج جستجو برای: $searchValue',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
        Expanded(
          child: getLoading
              ? const Center(child: Loading())
              : factors.isEmpty
              ? const Center(child: Text('فاکتوری یافت نشد.'))
              : _buildFactorListView(
                  context,
                  factors,
                  nextPageLoading,
                  enableSplitViewClick: canUseSplitView,
                ),
        ),
      ],
    );
  }

  Widget _buildFactorListView(
    BuildContext context,
    List<Factor> factors,
    bool nextPageLoading, {
    required bool enableSplitViewClick,
  }) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: nextPageLoading ? factors.length + 1 : factors.length,
      itemBuilder: (context, index) {
        if (index == factors.length && nextPageLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: Loading()),
          );
        }

        final factor = factors[index];
        final bool isSelected = _selectedFactor?.factorId == factor.factorId;

        return Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: FactorTile(
            factor: factor,
            isSelected: isSelected,
            onTap: enableSplitViewClick
                ? () => _selectFactor(factor)
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AccountingDetailPage(factor: factor),
                    ),
                  ),
          ),
        );
      },
    );
  }
}

//
// Factor Tile
//
class FactorTile extends StatelessWidget {
  final Factor factor;
  final bool isSelected;
  final VoidCallback? onTap;

  const FactorTile({
    super.key,
    required this.factor,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasFactorNumber =
        factor.factorNumber.isNotEmpty && factor.factorNumber != '0';

    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final selectedTextColor = (isSelected && isLight)
        ? colorScheme.onPrimaryContainer
        : null;
    final selectedHintColor = selectedTextColor ?? Theme.of(context).hintColor;

    return ContainerButton(
      color: isSelected
          ? colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surface,
      onPressed: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            // Header row: factor number + status badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    hasFactorNumber
                        ? 'فاکتور: ${factor.factorNumber}'
                        : 'فاکتور #${factor.factorId}',
                    style: Theme.of(context).textTheme.titleSmall?.apply(
                      color: selectedTextColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                hasFactorNumber
                    ? _PrintedBadge(isPrinted: factor.isPrinted)
                    : _StatusBadge(
                        label: 'ثبت نشده',
                        color: Colors.orange,
                        icon: Icons.edit_off_rounded,
                      ),
              ],
            ),
            // Info row — wrap to prevent overflow
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    Icon(
                      Icons.groups_rounded,
                      size: 14,
                      color: selectedHintColor,
                    ),
                    Text(
                      '${factor.groups.length} رویداد',
                      style: Theme.of(context).textTheme.labelSmall?.apply(
                        color: selectedTextColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    Icon(
                      Icons.attach_money_rounded,
                      size: 14,
                      color: selectedHintColor,
                    ),
                    Flexible(
                      child: Text(
                        '${_formatPrice(factor.totalPrice)} ریال',
                        style: Theme.of(context).textTheme.labelSmall?.apply(
                          color: selectedTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: selectedHintColor,
                    ),
                    Flexible(
                      child: Text(
                        factor.createdAt,
                        style: Theme.of(context).textTheme.labelSmall?.apply(
                          color: selectedTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Note
            if (factor.note != null && factor.note!.isNotEmpty)
              Text(
                factor.note!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: selectedHintColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price == price.toInt().toDouble()) {
      return _formatInt(price.toInt());
    }
    return _formatInt(price.toInt());
  }

  String _formatInt(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

class _PrintedBadge extends StatelessWidget {
  final bool isPrinted;
  const _PrintedBadge({required this.isPrinted});

  @override
  Widget build(BuildContext context) {
    final color = isPrinted ? Colors.green : Theme.of(context).hintColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Icon(
            isPrinted ? Icons.print_rounded : Icons.print_disabled_rounded,
            size: 12,
            color: color,
          ),
          Text(
            isPrinted ? 'چاپ شده' : 'چاپ نشده',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: color, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Icon(icon, size: 12, color: color),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: color, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

//
// Mobile full-screen factor detail page
//
class AccountingDetailPage extends StatelessWidget {
  final Factor factor;
  const AccountingDetailPage({super.key, required this.factor});

  @override
  Widget build(BuildContext context) {
    return BackScaffold(
      label: 'جزئیات فاکتور',
      backRoute: '/accounting',
      backLabel: 'حسابداری',
      body: AccountingDetailPanel(factor: factor),
    );
  }
}
