class Device {
  final int id;
  final String name;
  final String organization;
  final String? latLong;
  final int engineRoomFeature;
  final int location;
  final DeviceDetails details;
  final bool? status;
  final String administration;
  final String creator;
  final bool isConnected;
  final String createdAt; // Jalali date string

  Device({
    required this.id,
    required this.name,
    required this.organization,
    this.latLong,
    required this.engineRoomFeature,
    required this.location,
    required this.details,
    this.status,
    required this.administration,
    required this.creator,
    required this.isConnected,
    required this.createdAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as int,
      name: json['name'] ?? '',
      organization: json['organization'] ?? '',
      latLong: json['lat_long'],
      engineRoomFeature: json['engine_room_feature'] ?? 0,
      location: json['location'] ?? 0,
      details: DeviceDetails.fromJson(json['details'] ?? {}),
      status: json['status'], // can be true / false / null
      administration: json['administration'] ?? '',
      creator: json['creator'] ?? '',
      isConnected: json['is_connected'] ?? false,
      createdAt: json['created_at'] ?? '',
    );
  }
}

class DeviceDetails {
  final Map<String, dynamic> data;

  DeviceDetails({required this.data});

  factory DeviceDetails.fromJson(Map<String, dynamic> json) {
    return DeviceDetails(data: json);
  }
}
