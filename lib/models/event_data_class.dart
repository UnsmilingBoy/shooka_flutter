class Event {
  final String creator;
  final String deviceName;
  final String title;
  final String timestamp; // Example: "1404-07-08 06:35:27"
  final List<EventCategoryDetails> eventCategoryDetails;
  final int? eventGroupId;
  final String? factorId;
  final bool isCompleted;
  final String? completedAt;
  final bool isSent;
  final String? sentAt;
  final bool isSelected;

  Event({
    required this.creator,
    required this.deviceName,
    required this.title,
    required this.timestamp,
    required this.eventCategoryDetails,
    this.eventGroupId,
    this.factorId,
    this.isCompleted = false,
    this.completedAt,
    this.isSent = false,
    this.sentAt,
    this.isSelected = false,
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
      eventGroupId: json['event_group_id'] != null
          ? int.tryParse(json['event_group_id'].toString())
          : null,
      factorId: json['factor_id']?.toString(),
      isCompleted: json['is_completed'] ?? false,
      completedAt: json['completed_at']?.toString(),
      isSent: json['is_sent'] ?? false,
      sentAt: json['sent_at']?.toString(),
      isSelected: json['is_selected'] ?? false,
    );
  }
}

class EventCategoryDetails {
  final int eventId;
  final String category;
  final bool isChecked;
  final String text;
  final int? price;
  final bool isSelected;

  EventCategoryDetails({
    required this.eventId,
    required this.category,
    required this.isChecked,
    required this.text,
    this.price,
    this.isSelected = false,
  });

  factory EventCategoryDetails.fromJson(Map<String, dynamic> json) {
    return EventCategoryDetails(
      eventId: int.tryParse(json['event_id'].toString()) ?? 0,
      category: json['category'] ?? '',
      isChecked: json['is_checked'] ?? false,
      text: json['text'] ?? '',
      price: json['price'] != null
          ? int.tryParse(json['price'].toString())
          : null,
      isSelected: json['is_selected'] ?? false,
    );
  }
}
