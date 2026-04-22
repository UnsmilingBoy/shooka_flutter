import 'package:shooka_flutter/models/event_data_class.dart';

class Factor {
  final int factorId;
  final String factorNumber;
  final String? note;
  final bool isPrinted;
  final String? printedAt;
  final String createdAt;
  final String createdBy;
  final double totalPrice;
  final List<FactorGroup> groups;

  Factor({
    required this.factorId,
    required this.factorNumber,
    this.note,
    required this.isPrinted,
    this.printedAt,
    required this.createdAt,
    required this.createdBy,
    required this.totalPrice,
    required this.groups,
  });

  factory Factor.fromJson(Map<String, dynamic> json) {
    return Factor(
      factorId: json['factor_id'] ?? 0,
      factorNumber: json['factor_number'] ?? '',
      note: json['note']?.toString(),
      isPrinted: json['is_printed'] ?? false,
      printedAt: json['printed_at']?.toString(),
      createdAt: json['created_at'] ?? '',
      createdBy: json['created_by'] ?? '',
      totalPrice: (json['total_price'] is int)
          ? (json['total_price'] as int).toDouble()
          : (json['total_price'] ?? 0.0).toDouble(),
      groups: (json['groups'] as List<dynamic>? ?? [])
          .map((g) => FactorGroup.fromJson(g))
          .toList(),
    );
  }
}

class FactorGroup {
  final int eventGroupId;
  final String title;
  final String deviceName;
  final String creator;
  final int userId;
  final String timestamp;
  final bool isSent;
  final String? sentAt;
  final bool isCompleted;
  final String? completedAt;
  final double groupTotalPrice;
  final List<EventCategoryDetails> events;

  FactorGroup({
    required this.eventGroupId,
    required this.title,
    required this.deviceName,
    required this.creator,
    required this.userId,
    required this.timestamp,
    required this.isSent,
    this.sentAt,
    required this.isCompleted,
    this.completedAt,
    required this.groupTotalPrice,
    required this.events,
  });

  factory FactorGroup.fromJson(Map<String, dynamic> json) {
    return FactorGroup(
      eventGroupId: json['event_group_id'] ?? 0,
      title: json['title'] ?? '',
      deviceName: json['device_name'] ?? '',
      creator: json['creator'] ?? '',
      userId: json['user_id'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      isSent: json['is_sent'] ?? false,
      sentAt: json['sent_at']?.toString(),
      isCompleted: json['is_completed'] ?? false,
      completedAt: json['completed_at']?.toString(),
      groupTotalPrice: (json['group_total_price'] is int)
          ? (json['group_total_price'] as int).toDouble()
          : (json['group_total_price'] ?? 0.0).toDouble(),
      events: (json['events'] as List<dynamic>? ?? [])
          .map((e) => EventCategoryDetails.fromJson(e))
          .toList(),
    );
  }
}
