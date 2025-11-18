class Device {
  final int id;
  final String name;
  final String organization;
  final String? latLong;
  final int? engineRoomFeature;
  final int? location;
  final DeviceDetails details;
  final String? status;
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
    this.engineRoomFeature,
    this.location,
    required this.details,
    this.status,
    required this.administration,
    required this.creator,
    required this.isConnected,
    required this.createdAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      organization: json['organization'] ?? '',
      latLong: json['lat_long'],
      engineRoomFeature: json['engine_room_feature'],
      location: json['location_id'],
      details: DeviceDetails.fromJson(json['details'] ?? {}),
      status: json['status'] == true
          ? "تایید شده"
          : "رد شده", // can be true / false / null
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
