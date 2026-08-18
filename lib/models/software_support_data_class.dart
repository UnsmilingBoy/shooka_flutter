import 'package:shooka_flutter/models/event_data_class.dart';

/// A user that can be selected as the requester of a support event.
/// Shape returned by `/api/shouka/support-events/users/`.
class SupportEventUser {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final bool isActive;

  SupportEventUser({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.isActive,
  });

  factory SupportEventUser.fromJson(Map<String, dynamic> json) {
    return SupportEventUser(
      id: int.tryParse(json['id'].toString()) ?? 0,
      username: (json['username'] ?? '').toString(),
      firstName: (json['first_name'] ?? '').toString(),
      lastName: (json['last_name'] ?? '').toString(),
      isActive: json['is_active'] ?? false,
    );
  }

  String get fullName {
    final name = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
    return name.isNotEmpty ? name : username;
  }
}

class SoftwareSupportEvent {
  final int? id;
  final String title;
  final String phoneNumber;
  final String userName;
  final String creator;
  final String timestamp;
  final String description;
  final int? eventGroupId;

  SoftwareSupportEvent({
    this.id,
    required this.title,
    required this.phoneNumber,
    required this.userName,
    required this.creator,
    required this.timestamp,
    required this.description,
    this.eventGroupId,
  });

  factory SoftwareSupportEvent.fromJson(Map<String, dynamic> json) {
    final dynamic user = json['user'] ?? json['customer'] ?? json['client'];
    final String parsedUserName = user is Map<String, dynamic>
        ? (user['first_name'] ??
                  user['name'] ??
                  user['username'] ??
                  user['full_name'] ??
                  '')
              .toString()
        : (json['user_name'] ??
                  json['customer_name'] ??
                  json['client_name'] ??
                  json['name'] ??
                  '')
              .toString();

    final dynamic creator = json['creator'] ?? json['created_by'];
    final String parsedCreator = creator is Map<String, dynamic>
        ? (creator['first_name'] ??
                  creator['username'] ??
                  creator['name'] ??
                  '')
              .toString()
        : (creator ?? json['creator_name'] ?? '').toString();

    return SoftwareSupportEvent(
      id: int.tryParse((json['id'] ?? json['event_id'] ?? '').toString()),
      title: (json['title'] ?? '').toString(),
      phoneNumber:
          (json['phone_number'] ?? json['phone'] ?? json['mobile'] ?? '')
              .toString(),
      userName: parsedUserName,
      creator: parsedCreator,
      timestamp:
          (json['timestamp'] ??
                  json['created_at'] ??
                  json['time_created'] ??
                  '')
              .toString(),
      description:
          (json['description'] ?? json['text'] ?? json['message'] ?? '')
              .toString(),
      eventGroupId: int.tryParse(
        (json['event_group_id'] ?? json['group_id'] ?? '').toString(),
      ),
    );
  }

  Event toEvent() {
    return Event(
      creator: creator,
      deviceName: userName,
      title: title,
      timestamp: timestamp,
      eventGroupId: eventGroupId ?? id,
      eventCategoryDetails: [
        if (phoneNumber.isNotEmpty)
          EventCategoryDetails(
            eventId: id ?? 0,
            category: 'شماره تلفن',
            isChecked: true,
            text: phoneNumber,
          ),
        EventCategoryDetails(
          eventId: id ?? 0,
          category: 'توضیحات',
          isChecked: true,
          text: description,
        ),
      ],
    );
  }
}
