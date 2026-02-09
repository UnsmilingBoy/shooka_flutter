import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/models/event_data_class.dart';
import 'package:shooka_flutter/services/providers/event_provider.dart';
import 'package:shooka_flutter/utils/loadings/loading.dart';

class AddInvoiceModal extends StatefulWidget {
  const AddInvoiceModal({super.key});

  @override
  State<AddInvoiceModal> createState() => _AddInvoiceModalState();
}

class _AddInvoiceModalState extends State<AddInvoiceModal> {
  final Set<String> _selectedEventIds = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      final provider = context.read<EventProvider>();
      if (!provider.fetchLoading && !provider.eventsNextPageLoading) {
        provider.eventsNextPage();
      }
    }
  }

  void _toggleEvent(Event event) {
    final eventId = '${event.timestamp}_${event.deviceName}';
    setState(() {
      if (_selectedEventIds.contains(eventId)) {
        _selectedEventIds.remove(eventId);
      } else {
        _selectedEventIds.add(eventId);
      }
    });
  }

  bool _isEventSelected(Event event) {
    final eventId = '${event.timestamp}_${event.deviceName}';
    return _selectedEventIds.contains(eventId);
  }

  List<Event> _getSelectedEvents(List<Event> allEvents) {
    return allEvents.where((event) {
      final eventId = '${event.timestamp}_${event.deviceName}';
      return _selectedEventIds.contains(eventId);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final eventsProvider = context.watch<EventProvider>();
    final events = eventsProvider.events;
    final nextPageLoading = eventsProvider.eventsNextPageLoading;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 700,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "افزودن فاکتور",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(
                    context,
                  ).copyWith(scrollbars: false),
                  child: Scrollbar(
                    scrollbarOrientation: ScrollbarOrientation.right,
                    controller: _scrollController,
                    thickness: 5,
                    radius: Radius.circular(5),
                    thumbVisibility: true,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(24),
                      itemCount: events.isEmpty
                          ? 1
                          : (nextPageLoading
                                ? events.length + 1
                                : events.length),
                      itemBuilder: (context, index) {
                        // Empty state
                        if (events.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Text(
                                "هیچ رویدادی برای نمایش وجود ندارد",
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          );
                        }

                        // Loading indicator
                        if (index == events.length && nextPageLoading) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(child: Loading()),
                          );
                        }

                        // Event item
                        final event = events[index];
                        final isSelected = _isEventSelected(event);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Card(
                            elevation: isSelected ? 2 : 0,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                            child: InkWell(
                              onTap: () => _toggleEvent(event),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: isSelected,
                                      onChanged: (value) => _toggleEvent(event),
                                      activeColor: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            event.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            "موتورخانه: ${event.deviceName}",
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                          Text(
                                            "سازنده: ${event.creator}",
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                          Text(
                                            "زمان: ${event.timestamp}",
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Bottom buttons
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: ModalBottomButtons(
                  saveText: "ایجاد فاکتور",
                  onSave: _selectedEventIds.isEmpty
                      ? null
                      : () {
                          // TODO: Send selected events to backend
                          final selectedEvents = _getSelectedEvents(events);
                          print(
                            "Creating invoice for ${selectedEvents.length} events",
                          );

                          // Close modal
                          Navigator.pop(context);

                          // Show success message (placeholder)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "فاکتور برای ${selectedEvents.length} رویداد ایجاد شد",
                                textDirection: TextDirection.rtl,
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
