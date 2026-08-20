import 'package:flutter/material.dart';
import 'package:shooka_flutter/(tabs)/event%20page/event_page.dart';
import 'package:shooka_flutter/models/event_data_class.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';

class EventTile extends StatefulWidget {
  final String title;
  final String author;
  final String device;
  final Color? color;
  final String timeCreated;
  final List<EventCategoryDetails> message;
  final double? borderRadius;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool compactMode;
  final int? eventGroupId;
  final String? factorId;
  final bool isCompleted;
  final String? completedAt;
  final bool isSent;
  final String? sentAt;
  final bool canEdit;
  final VoidCallback? onEditPressed;
  final String detailBackRoute;
  final String detailBackLabel;
  final String detailRouteName;

  const EventTile({
    super.key,
    required this.title,
    required this.author,
    required this.device,
    this.color,
    this.borderRadius,
    required this.timeCreated,
    required this.message,
    this.isSelected = false,
    this.onTap,
    this.compactMode = false,
    this.eventGroupId,
    this.factorId,
    this.isCompleted = false,
    this.completedAt,
    this.isSent = false,
    this.sentAt,
    this.canEdit = true,
    this.onEditPressed,
    this.detailBackRoute = "/events",
    this.detailBackLabel = "رویدادها",
    this.detailRouteName = "/event_page",
  });

  @override
  State<EventTile> createState() => _EventTileState();
}

class _EventTileState extends State<EventTile> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final selectedTextColor = (widget.isSelected && isLight)
        ? colorScheme.onPrimaryContainer
        : null;

    return ContainerButton(
      borderRadius: widget.borderRadius,
      color: widget.isSelected
          ? colorScheme.primaryContainer
          : widget.color,
      onPressed:
          widget.onTap ??
          () => Navigator.push(
            context,
            MaterialPageRoute(
              settings: RouteSettings(name: widget.detailRouteName),
              builder: (_) => EventPage(
                creator: widget.author,
                device: widget.device,
                title: widget.title,
                timeCreated: widget.timeCreated,
                message: widget.message,
                eventGroupId: widget.eventGroupId,
                factorId: widget.factorId,
                isCompleted: widget.isCompleted,
                completedAt: widget.completedAt,
                isSent: widget.isSent,
                sentAt: widget.sentAt,
                canEdit: widget.canEdit,
                onEditPressed: widget.onEditPressed,
                backRoute: widget.detailBackRoute,
                backLabel: widget.detailBackLabel,
              ),
            ),
          ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.apply(
                  color: selectedTextColor,
                ),
              ),
            ),
            Expanded(
              child: Row(
                spacing: 2,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      widget.author,
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.labelSmall?.apply(
                        color: selectedTextColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    color: selectedTextColor ?? colorScheme.secondary,
                    Icons.person,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Text("دستگاه: ${widget.device}"),
        subtitleTextStyle: Theme.of(context).textTheme.labelSmall?.apply(
          overflow: TextOverflow.ellipsis,
          color: selectedTextColor,
        ),
      ),
    );
  }
}
