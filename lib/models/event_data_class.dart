class Event {
  final String creator;
  final int? creatorId;
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

  // Support-event specific fields (from /api/shouka/support-events/list/)
  final dynamic registeredRequester;
  final String? externalRequester;
  final String? requesterPhoneNumber;
  final String? domain;

  Event({
    required this.creator,
    required this.deviceName,
    required this.title,
    required this.timestamp,
    required this.eventCategoryDetails,
    this.creatorId,
    this.eventGroupId,
    this.factorId,
    this.isCompleted = false,
    this.completedAt,
    this.isSent = false,
    this.sentAt,
    this.isSelected = false,
    this.registeredRequester,
    this.externalRequester,
    this.requesterPhoneNumber,
    this.domain,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      creator: json['creator'] ?? '',
      creatorId: json['creator_id'] != null
          ? int.tryParse(json['creator_id'].toString())
          : null,
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
      registeredRequester: json['registered_requester'],
      externalRequester: json['external_requester']?.toString(),
      requesterPhoneNumber: json['requester_phone_number']?.toString(),
      domain: json['domain']?.toString(),
    );
  }

  /// Whether this event was reported by someone outside the system.
  bool get isExternalRequester =>
      (externalRequester?.trim().isNotEmpty ?? false);

  /// Display name of the requester of a support event.
  ///
  /// Prefers the free-text external name, then falls back to the registered
  /// user object (`registered_requester`), which the API returns either as a
  /// plain string or as `{id, username, full_name}`.
  /// Returns `null` for regular (non-support) events that have no requester.
  String? get requesterDisplayName {
    final external = externalRequester?.trim();
    if (external != null && external.isNotEmpty) return external;

    final registered = registeredRequester;
    if (registered == null) return null;
    if (registered is String) {
      final value = registered.trim();
      return value.isEmpty ? null : value;
    }
    if (registered is Map) {
      for (final key in ['full_name', 'name', 'first_name', 'username']) {
        final value = registered[key]?.toString().trim();
        if (value != null && value.isNotEmpty) return value;
      }
      return null;
    }
    final value = registered.toString().trim();
    return value.isEmpty ? null : value;
  }

  /// Requester phone number, or `null` when none was recorded.
  String? get requesterPhone {
    final phone = requesterPhoneNumber?.trim();
    return (phone == null || phone.isEmpty) ? null : phone;
  }

  /// True when the event carries any requester information.
  bool get hasRequester =>
      requesterDisplayName != null || requesterPhone != null;
}

class EventCategoryDetails {
  final int eventId;
  final String category;
  final bool isChecked;
  final String text;
  final int? price;
  final bool isSelected;
  final String? updatedAt;

  EventCategoryDetails({
    required this.eventId,
    required this.category,
    required this.isChecked,
    required this.text,
    this.price,
    this.isSelected = false,
    this.updatedAt,
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
      updatedAt: json['updated_at']?.toString(),
    );
  }
}
