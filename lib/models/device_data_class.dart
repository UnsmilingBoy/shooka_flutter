class Device {
  final int id;
  final String name;
  final String organization;
  final String? latLong;
  final int engineRoomFeature;
  final int location;
  final DeviceDetails details;
  final String status;
  final String administration;
  final String creator;
  final String isConnected;
  final String serialNumber;
  final String? address;
  final String? city;
  final String? province;
  final String createdAt; // Jalali date string

  Device({
    required this.address,
    required this.city,
    required this.province,
    required this.serialNumber,
    required this.id,
    required this.name,
    required this.organization,
    this.latLong,
    required this.engineRoomFeature,
    required this.location,
    required this.details,
    required this.status,
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
      status: json['status'] == true
          ? "فعال"
          : "غیرفعال", // can be true / false / null
      administration: json['administration'] ?? '',
      creator: json['creator'] ?? '',
      isConnected: json['is_connected'] == true ? "متصل" : "قطع",
      createdAt: json['created_at'] ?? '',
      address: json["installation_address"] ?? "",
      city: json["city"] ?? "",
      province: json["province"] ?? "",
      serialNumber: json["serial_number"] ?? "",
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
