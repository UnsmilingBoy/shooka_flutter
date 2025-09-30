class Event {
  final String creator;
  final String deviceName;
  final String title;
  final String timestamp; // Example: "1404-07-08 06:35:27"
  final List<EventCategoryDetails> eventCategoryDetails;

  Event({
    required this.creator,
    required this.deviceName,
    required this.title,
    required this.timestamp,
    required this.eventCategoryDetails,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      creator: json['creator'] ?? '',
      deviceName: json['device_name'] ?? '',
      title: json['title'] ?? '',
      timestamp: json['timestamp'] ?? '',
      eventCategoryDetails: (json['event_category_details'] as List<dynamic>)
          .map((item) => EventCategoryDetails.fromJson(item))
          .toList(),
    );
  }
}

class EventCategoryDetails {
  final int eventId;
  final String category;
  final bool isChecked;
  final String text;

  EventCategoryDetails({
    required this.eventId,
    required this.category,
    required this.isChecked,
    required this.text,
  });

  factory EventCategoryDetails.fromJson(Map<String, dynamic> json) {
    return EventCategoryDetails(
      eventId: json['event_id'] as int,
      category: json['category'] ?? '',
      isChecked: json['is_checked'] ?? false,
      text: json['text'] ?? '',
    );
  }
}
