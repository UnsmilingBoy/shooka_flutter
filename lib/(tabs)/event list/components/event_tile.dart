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
  });

  @override
  State<EventTile> createState() => _EventTileState();
}

class _EventTileState extends State<EventTile> {
  @override
  Widget build(BuildContext context) {
    return ContainerButton(
      borderRadius: widget.borderRadius,
      color: widget.isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : widget.color,

      // If onTap is provided (split view mode), use it. Otherwise navigate normally.
      onPressed:
          widget.onTap ??
          () => Navigator.push(
            context,
            MaterialPageRoute(
              settings: RouteSettings(name: "/event_page"),
              builder: (_) => EventPage(
                creator: widget.author,
                device: widget.device,
                title: widget.title,
                timeCreated: widget.timeCreated,
                message: widget.message,
              ),
            ),
          ),

      //
      // The actual tile.
      //
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
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Expanded(
              child: Row(
                spacing: 2,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      textAlign: TextAlign.left,
                      widget.author,
                      style: Theme.of(context).textTheme.labelSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    color: Theme.of(context).colorScheme.secondary,
                    Icons.person,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Text("دستگاه: ${widget.device}"),
        subtitleTextStyle: Theme.of(
          context,
        ).textTheme.labelSmall?.apply(overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
