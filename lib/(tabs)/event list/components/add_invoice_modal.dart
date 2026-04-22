import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/models/event_data_class.dart';
import 'package:shooka_flutter/services/providers/event_provider.dart';
import 'package:shooka_flutter/utils/toastifications/toasts.dart';

class AddInvoiceModal extends StatefulWidget {
  const AddInvoiceModal({super.key});

  @override
  State<AddInvoiceModal> createState() => _AddInvoiceModalState();
}

class _AddInvoiceModalState extends State<AddInvoiceModal> {
  // key: eventGroupId → set of selected EventCategoryDetails.eventId values
  final Map<int, Set<int>> _selectedIds = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    final provider = context.watch<EventProvider>();
    final groupedEvents = _groupEvents(provider.events);
    final isSending = provider.sendLoading;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              _buildHeader(context),
              Flexible(child: _buildBody(context, groupedEvents)),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'افزودن فاکتور',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'گروه‌های رویداد و موارد مورد نظر را انتخاب کنید',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  // ─── Body ──────────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context, Map<int, List<Event>> groupedEvents) {
    if (groupedEvents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'هیچ رویدادی برای نمایش وجود ندارد',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: Scrollbar(
        controller: _scrollController,
        scrollbarOrientation: ScrollbarOrientation.right,
        thickness: 5,
        radius: const Radius.circular(5),
        thumbVisibility: true,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemCount: groupedEvents.length,
          itemBuilder: (context, index) {
            final groupId = groupedEvents.keys.elementAt(index);
            final groupEvents = groupedEvents[groupId]!;
            return _buildGroupCard(context, groupId, groupEvents);
          },
        ),
      ),
    );
  }

  // ─── Group card ────────────────────────────────────────────────────────────

  Widget _buildGroupCard(
    BuildContext context,
    int groupId,
    List<Event> groupEvents,
  ) {
    final fullySelected = _isGroupFullySelected(groupId, groupEvents);
    final partiallySelected = _isGroupPartiallySelected(groupId, groupEvents);
    final anySelected = fullySelected || partiallySelected;
    final firstEvent = groupEvents.first;

    // Collect all detail rows across all events in the group
    final allDetails = groupEvents
        .expand((e) => e.eventCategoryDetails)
        .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: anySelected ? 1 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: anySelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.6)
                : Theme.of(context).colorScheme.outlineVariant.withOpacity(0.2),
            width: anySelected ? 1.5 : 1,
          ),
        ),
        color: anySelected
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.15)
            : Theme.of(context).colorScheme.surface,
        clipBehavior: Clip.hardEdge,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            childrenPadding: EdgeInsets.zero,
            // Group-level checkbox
            leading: Checkbox(
              value: partiallySelected ? null : fullySelected,
              tristate: true,
              onChanged: (_) => _toggleGroup(groupId, groupEvents),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            title: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstEvent.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          _chip(
                            context,
                            Icons.developer_board_outlined,
                            firstEvent.deviceName,
                          ),
                          const SizedBox(width: 10),
                          _chip(
                            context,
                            Icons.person_outline,
                            firstEvent.creator,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'گروه #$groupId',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                firstEvent.timestamp,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            children: [
              Divider(
                height: 1,
                thickness: 1,
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withOpacity(0.5),
              ),
              if (allDetails.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'هیچ جزئیاتی در این گروه وجود ندارد',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                ...allDetails.map(
                  (detail) => _buildDetailRow(context, groupId, detail),
                ),
            ],
          ),
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
    final selected = _isDetailSelected(groupId, detail.eventId);

    return InkWell(
      onTap: () => _toggleDetail(groupId, detail.eventId, !selected),
      child: Container(
        color: selected
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.25)
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            const SizedBox(width: 4),
            Checkbox(
              value: selected,
              onChanged: (v) => _toggleDetail(groupId, detail.eventId, v),
              activeColor: Theme.of(context).colorScheme.primary,
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
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (detail.category.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      detail.category,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (detail.price != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${detail.price} تومان',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Info chip ─────────────────────────────────────────────────────────────

  Widget _chip(BuildContext context, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 3),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 120),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
