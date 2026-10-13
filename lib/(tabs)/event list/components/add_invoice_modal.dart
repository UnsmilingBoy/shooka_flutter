import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/models/event_data_class.dart';
import 'package:shooka_flutter/services/providers/event_provider.dart';
import 'package:shooka_flutter/utils/loadings/loading.dart';
import 'package:shooka_flutter/utils/toastifications/toasts.dart';

/// Invoice picker dialog: select event detail rows (grouped by
/// `eventGroupId`) and send them as an invoice.
///
/// The list intentionally works on the provider's already-loaded events:
/// - search is client-side (a server query here would reset the main
///   event tab's own filters/search),
/// - pagination reuses [EventProvider.eventsNextPage] ("load more"),
///   which only appends to the shared list the main tab also reads.
class AddInvoiceModal extends StatefulWidget {
  const AddInvoiceModal({super.key});

  @override
  State<AddInvoiceModal> createState() => _AddInvoiceModalState();
}

class _AddInvoiceModalState extends State<AddInvoiceModal> {
  // key: eventGroupId → set of selected EventCategoryDetails.eventId values
  final Map<int, Set<int>> _selectedIds = {};
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _showSelectedOnly = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScrollNearEnd);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScrollNearEnd)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScrollNearEnd() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 300) {
      return;
    }
    final provider = context.read<EventProvider>();
    if (!provider.eventsNextPageLoading &&
        provider.eventsPage < provider.eventsTotalPages) {
      provider.eventsNextPage();
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Map<int, List<Event>> _groupEvents(List<Event> events) {
    final Map<int, List<Event>> groups = {};
    for (final event in events) {
      if (event.eventGroupId != null) {
        groups.putIfAbsent(event.eventGroupId!, () => []).add(event);
      }
    }
    return groups;
  }

  bool _matchesQuery(Event event) {
    final q = _query.trim();
    if (q.isEmpty) return true;
    if (event.title.contains(q) ||
        event.deviceName.contains(q) ||
        event.creator.contains(q) ||
        event.timestamp.contains(q)) {
      return true;
    }
    return event.eventCategoryDetails.any(
      (d) => d.text.contains(q) || d.category.contains(q),
    );
  }

  /// Groups after applying the local search + selected-only filters.
  Map<int, List<Event>> _visibleGroups(Map<int, List<Event>> all) {
    final Map<int, List<Event>> out = {};
    for (final entry in all.entries) {
      if (_showSelectedOnly &&
          ((_selectedIds[entry.key]?.isNotEmpty ?? false) == false)) {
        continue;
      }
      if (_query.trim().isEmpty) {
        out[entry.key] = entry.value;
      } else {
        final matching = entry.value.where(_matchesQuery).toList();
        if (matching.isNotEmpty) out[entry.key] = matching;
      }
    }
    return out;
  }

  Set<int> _allIdsForGroup(List<Event> groupEvents) => groupEvents
      .expand((e) => e.eventCategoryDetails)
      .map((d) => d.eventId)
      .toSet();

  bool _isGroupFullySelected(int groupId, List<Event> groupEvents) {
    final all = _allIdsForGroup(groupEvents);
    if (all.isEmpty) return false;
    return _selectedIds.containsKey(groupId) &&
        all.every((id) => _selectedIds[groupId]!.contains(id));
  }

  bool _isGroupPartiallySelected(int groupId, List<Event> groupEvents) {
    if (!_selectedIds.containsKey(groupId)) return false;
    final selected = _selectedIds[groupId]!;
    if (selected.isEmpty) return false;
    return !_isGroupFullySelected(groupId, groupEvents);
  }

  void _toggleGroup(int groupId, List<Event> groupEvents) {
    final all = _allIdsForGroup(groupEvents);
    setState(() {
      if (_isGroupFullySelected(groupId, groupEvents)) {
        _selectedIds[groupId] = {};
      } else {
        _selectedIds[groupId] = Set.from(all);
      }
    });
  }

  void _toggleDetail(int groupId, int eventId, bool? value) {
    setState(() {
      _selectedIds.putIfAbsent(groupId, () => {});
      if (value == true) {
        _selectedIds[groupId]!.add(eventId);
      } else {
        _selectedIds[groupId]!.remove(eventId);
      }
    });
  }

  bool _isDetailSelected(int groupId, int eventId) =>
      _selectedIds[groupId]?.contains(eventId) ?? false;

  int get _totalSelected =>
      _selectedIds.values.fold(0, (sum, s) => sum + s.length);

  void _clearSelection() => setState(() => _selectedIds.clear());

  List<Map<String, dynamic>> _buildPayload() => _selectedIds.entries
      .where((e) => e.value.isNotEmpty)
      .map((e) => {'group_id': e.key, 'event_ids': e.value.toList()})
      .toList();

  // ─── Actions ───────────────────────────────────────────────────────────────

  Future<void> _send() async {
    final payload = _buildPayload();
    if (payload.isEmpty) return;
    final provider = context.read<EventProvider>();
    final message = await provider.sendInvoice(payload);
    if (!mounted) return;
    if (message != null) {
      Navigator.pop(context);
      filledSuccessToast(title: "فاکتور با موفقیت ارسال شد");
    } else {
      flatErrorToast(
        title: 'خطا در ارسال فاکتور',
        description: 'لطفاً دوباره تلاش کنید',
      );
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final provider = context.watch<EventProvider>();
    final groupedEvents = _groupEvents(provider.events);
    final visible = _visibleGroups(groupedEvents);
    final isSending = provider.sendLoading;

    return Dialog(
      backgroundColor: scheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 720,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, provider),
              _buildToolbar(context),
              Flexible(
                child: _buildBody(context, provider, groupedEvents, visible),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: ModalBottomButtons(
                  saveText: _totalSelected > 0
                      ? 'ارسال ($_totalSelected مورد)'
                      : 'ارسال فاکتور',
                  isLoading: isSending,
                  onSave: (_totalSelected == 0 || isSending) ? null : _send,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, EventProvider provider) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 20, 14),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: .07),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: scheme.primary,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'افزودن فاکتور',
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  provider.eventsTotalCount > 0
                      ? '${provider.events.length} از ${provider.eventsTotalCount} رویداد بارگذاری شده'
                      : 'موارد مورد نظر را انتخاب کنید',
                  style: text.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (_totalSelected > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_totalSelected انتخاب',
                style: text.labelSmall?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
            iconSize: 20,
            tooltip: 'بستن',
          ),
        ],
      ),
    );
  }

  // ─── Toolbar: local search + selected-only + clear ─────────────────────────

  Widget _buildToolbar(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: scheme.outline.withValues(alpha: .22)),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            textInputAction: TextInputAction.search,
            style: text.labelMedium,
            decoration: InputDecoration(
              hintText: 'جستجو در عنوان، دستگاه، ایجادکننده یا متن...',
              hintStyle: text.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.close_rounded, size: 18),
                      tooltip: 'پاک کردن جستجو',
                    ),
              filled: true,
              fillColor: scheme.surfaceContainerLowest,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              border: fieldBorder,
              enabledBorder: fieldBorder,
              focusedBorder: fieldBorder.copyWith(
                borderSide: BorderSide(color: scheme.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              FilterChip(
                selected: _showSelectedOnly,
                onSelected: (v) => setState(() => _showSelectedOnly = v),
                label: Text('فقط انتخاب‌شده‌ها ($_totalSelected)'),
                avatar: Icon(
                  _showSelectedOnly
                      ? Icons.check_circle_rounded
                      : Icons.check_circle_outline_rounded,
                  size: 16,
                ),
                visualDensity: VisualDensity.compact,
              ),
              const Spacer(),
              if (_totalSelected > 0)
                TextButton.icon(
                  onPressed: _clearSelection,
                  icon: const Icon(Icons.clear_all_rounded, size: 16),
                  label: const Text('حذف انتخاب‌ها'),
                  style: TextButton.styleFrom(
                    foregroundColor: scheme.error,
                    visualDensity: VisualDensity.compact,
                    textStyle: text.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Body ──────────────────────────────────────────────────────────────────

  Widget _buildBody(
    BuildContext context,
    EventProvider provider,
    Map<int, List<Event>> groupedEvents,
    Map<int, List<Event>> visible,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    if (provider.fetchLoading && provider.events.isEmpty) {
      return const Center(
        child: Padding(padding: EdgeInsets.all(48), child: Loading(size: 28)),
      );
    }
    if (groupedEvents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inbox_outlined,
                  size: 34,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'هیچ رویدادی برای نمایش وجود ندارد',
                style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'ابتدا از تب رویدادها داده را بارگذاری کنید',
                style: text.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (visible.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 44,
                color: scheme.onSurfaceVariant.withValues(alpha: .7),
              ),
              const SizedBox(height: 12),
              Text(
                _showSelectedOnly && _totalSelected == 0
                    ? 'هنوز موردی انتخاب نشده است'
                    : 'موردی مطابق جستجو یافت نشد',
                style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _query = '';
                    _showSelectedOnly = false;
                  });
                },
                child: const Text('پاک کردن جستجو و فیلتر'),
              ),
            ],
          ),
        ),
      );
    }

    final groupIds = visible.keys.toList();
    return Scrollbar(
      controller: _scrollController,
      scrollbarOrientation: ScrollbarOrientation.right,
      thickness: 6,
      radius: const Radius.circular(4),
      thumbVisibility: true,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        // +1 for the load-more footer.
        itemCount: groupIds.length + 1,
        itemBuilder: (context, index) {
          if (index == groupIds.length) {
            return _buildLoadMoreFooter(context, provider);
          }
          final groupId = groupIds[index];
          return _buildGroupCard(context, groupId, visible[groupId]!);
        },
      ),
    );
  }

  Widget _buildLoadMoreFooter(BuildContext context, EventProvider provider) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    if (provider.eventsNextPageLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: Loading(size: 24)),
      );
    }
    if (provider.eventsPage < provider.eventsTotalPages) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: OutlinedButton.icon(
          onPressed: () => provider.eventsNextPage(),
          icon: const Icon(Icons.expand_more_rounded, size: 18),
          label: Text(
            'نمایش موارد بیشتر (صفحه ${provider.eventsPage} از ${provider.eventsTotalPages})',
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: scheme.primary,
            side: BorderSide(color: scheme.primary.withValues(alpha: .35)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        'همه موارد (${provider.events.length} رویداد) نمایش داده شد',
        textAlign: TextAlign.center,
        style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }

  // ─── Group card ────────────────────────────────────────────────────────────

  Widget _buildGroupCard(
    BuildContext context,
    int groupId,
    List<Event> groupEvents,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final fullySelected = _isGroupFullySelected(groupId, groupEvents);
    final partiallySelected = _isGroupPartiallySelected(groupId, groupEvents);
    final anySelected = fullySelected || partiallySelected;
    final firstEvent = groupEvents.first;
    final detailCount = _allIdsForGroup(groupEvents).length;
    final selectedCount = _selectedIds[groupId]?.length ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: anySelected
            ? scheme.primary.withValues(alpha: .06)
            : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: anySelected
              ? scheme.primary.withValues(alpha: .45)
              : scheme.outlineVariant.withValues(alpha: .35),
          width: anySelected ? 1.2 : 1,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          // Reset to expanded when search starts/clears so matches are visible.
          key: ValueKey('invoice_group_${groupId}_${_query.trim().isEmpty}'),
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          childrenPadding: EdgeInsets.zero,
          shape: const Border(),
          collapsedShape: const Border(),
          leading: Checkbox(
            value: partiallySelected ? null : fullySelected,
            tristate: true,
            onChanged: (_) => _toggleGroup(groupId, groupEvents),
            activeColor: scheme.primary,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      firstEvent.title,
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: anySelected
                          ? scheme.primary.withValues(alpha: .14)
                          : scheme.surfaceContainerHighest.withValues(
                              alpha: .6,
                            ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      selectedCount > 0
                          ? '$selectedCount از $detailCount انتخاب'
                          : '$detailCount مورد',
                      style: text.labelSmall?.copyWith(
                        color: anySelected
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  _meta(context, Icons.developer_board_outlined, firstEvent.deviceName),
                  _meta(context, Icons.person_outline_rounded, firstEvent.creator),
                  _meta(context, Icons.schedule_outlined, firstEvent.timestamp),
                ],
              ),
            ],
          ),
          children: [
            Divider(
              height: 1,
              thickness: 1,
              color: scheme.outlineVariant.withValues(alpha: .4),
            ),
            ...groupEvents.expand((e) => e.eventCategoryDetails).map(
                  (detail) => _buildDetailRow(context, groupId, detail),
                ),
          ],
        ),
      ),
    );
  }

  // ─── Detail row ────────────────────────────────────────────────────────────

  Widget _buildDetailRow(
    BuildContext context,
    int groupId,
    EventCategoryDetails detail,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final selected = _isDetailSelected(groupId, detail.eventId);

    return InkWell(
      onTap: () => _toggleDetail(groupId, detail.eventId, !selected),
      child: Container(
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withValues(alpha: .09)
              : Colors.transparent,
          border: Border(
            right: BorderSide(
              color: selected ? scheme.primary : Colors.transparent,
              width: 3,
            ),
            bottom: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: .3),
              width: .6,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          children: [
            Checkbox(
              value: selected,
              onChanged: (v) => _toggleDetail(groupId, detail.eventId, v),
              activeColor: scheme.primary,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail.text.isNotEmpty ? detail.text : '—',
                    style: text.bodyMedium?.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (detail.category.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      detail.category,
                      style: text.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (detail.price != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: selected
                      ? scheme.primary.withValues(alpha: .14)
                      : scheme.surfaceContainerHighest.withValues(alpha: .6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${detail.price} تومان',
                  style: text.labelSmall?.copyWith(
                    color: selected ? scheme.primary : scheme.tertiary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Info meta ─────────────────────────────────────────────────────────────

  Widget _meta(BuildContext context, IconData icon, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: scheme.onSurfaceVariant),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 150),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
