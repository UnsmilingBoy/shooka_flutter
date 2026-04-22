class Device {
  final int id;
  final String name;
  final String organization;
  final String? latLong;
  final int? engineRoomFeature;
  final int? location;
  final dynamic details;
  final String? status;
  final bool? rawStatus; // true = approved, false = rejected, null = pending
  final String? rejectionNote; // Rejection reason when rawStatus is false
  final String administration;
  final String creator;
  final String isConnected;
  final String serialNumber;
  final String? address;
  final String? city;
  final String? province;
  final String? plan;
  final String createdAt; // Jalali date string

  Device({
    required this.address,
    required this.city,
    required this.plan,
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
    this.rawStatus,
    this.rejectionNote,
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
      engineRoomFeature: json['engineroomfeature_id'],
      location: json['location_id'],
      details: "cat",
      rawStatus: json['status'],
      status: json['status'] == true
          ? "تایید شده"
          : json['status'] == false
          ? "رد شده"
          : "در حال بررسی",
      rejectionNote: json['rejection_note'],
      administration: json['administration'] ?? '',
      creator: json['creator'] ?? '',
      isConnected: json['is_connected'] == true ? "متصل" : "قطع",
      createdAt: json['created_at'] ?? '',
      address: json["installation_address"] ?? "",
      city: json["city"] ?? "",
      province: json["province"] ?? "",
      serialNumber: json["serial_number"] ?? "",
      plan: json["plan"] == "free" ? "آزاد" : "طرح بهینه سازی",
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
