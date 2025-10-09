import 'dart:convert';

class CompleteDeviceInfo {
  final String phoneNumber1;
  final String phoneNumber2;
  final String linkerPerson1;
  final String linkerPerson2;
  final int buildingMetrage;
  final String meterSubscriptionNumber;
  final String lastEditedBy;
  final String buildingImage;
  final String device;
  final String installedDeviceModel;
  final String connectionType;
  final String modemModel;
  final bool hasSimcard;
  final String modemSimcardNumber;
  final String installationDate;
  final String modemSimcardSerialNumberImage;
  final String deviceSerialNumberImage;
  final String usage;
  final bool hasExchanger;
  final int numberOfPoolExchangers;
  final int numberOfJaccuziExchangers;
  final int numberOfFloorHeatingExchangers;
  final int numberOfBoilers;
  final int numberOfCirculatingPumps;
  final int numberOfCoilSources;
  final int numberOfCoilSourcesPumps;
  final int numberOfHotWaterPumps;
  final List<EngineroomImage> engineroomImages;

  CompleteDeviceInfo({
    required this.phoneNumber1,
    required this.phoneNumber2,
    required this.linkerPerson1,
    required this.linkerPerson2,
    required this.buildingMetrage,
    required this.meterSubscriptionNumber,
    required this.lastEditedBy,
    required this.buildingImage,
    required this.device,
    required this.installedDeviceModel,
    required this.connectionType,
    required this.modemModel,
    required this.hasSimcard,
    required this.modemSimcardNumber,
    required this.installationDate,
    required this.modemSimcardSerialNumberImage,
    required this.deviceSerialNumberImage,
    required this.usage,
    required this.hasExchanger,
    required this.numberOfPoolExchangers,
    required this.numberOfJaccuziExchangers,
    required this.numberOfFloorHeatingExchangers,
    required this.numberOfBoilers,
    required this.numberOfCirculatingPumps,
    required this.numberOfCoilSources,
    required this.numberOfCoilSourcesPumps,
    required this.numberOfHotWaterPumps,
    required this.engineroomImages,
  });

  factory CompleteDeviceInfo.fromJson(Map<String, dynamic> json) {
    return CompleteDeviceInfo(
      phoneNumber1: json['phone_number1'] ?? '',
      phoneNumber2: json['phone_number2'] ?? '',
      linkerPerson1: json['linker_person1'] ?? '',
      linkerPerson2: json['linker_person2'] ?? '',
      buildingMetrage: json['building_metrage'] ?? 0,
      meterSubscriptionNumber: json['meter_subscription_number'] ?? '',
      lastEditedBy: json['last_edited_by'] ?? '',
      buildingImage: json['building_image'] ?? '',
      device: json['device'] ?? '',
      installedDeviceModel: json['installed_device_model'] ?? '',
      connectionType: json['connection_type'] ?? '',
      modemModel: json['modem_model'] ?? '',
      hasSimcard: json['has_simcard'] ?? false,
      modemSimcardNumber: json['modem_simcard_number'] ?? '',
      installationDate: json['installation_date'] ?? '',
      modemSimcardSerialNumberImage:
          json['modem_simcard_serial_number_image'] ?? '',
      deviceSerialNumberImage: json['device_serial_number_image'] ?? '',
      usage: json['usage'] ?? '',
      hasExchanger: json['has_exchanger'] ?? false,
      numberOfPoolExchangers: json['number_of_pool_exchangers'] ?? 0,
      numberOfJaccuziExchangers: json['number_of_jaccuzi_exchangers'] ?? 0,
      numberOfFloorHeatingExchangers:
          json['number_of_floor_heating_exchangers'] ?? 0,
      numberOfBoilers: json['number_of_boilers'] ?? 0,
      numberOfCirculatingPumps: json['number_of_circulating_pumps'] ?? 0,
      numberOfCoilSources: json['number_of_coil_sources'] ?? 0,
      numberOfCoilSourcesPumps: json['number_of_coil_sources_pumps'] ?? 0,
      numberOfHotWaterPumps: json['number_of_hot_water_pumps'] ?? 0,
      engineroomImages: (json['engineroom_images'] as List<dynamic>? ?? [])
          .map((e) => EngineroomImage.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'phone_number1': phoneNumber1,
    'phone_number2': phoneNumber2,
    'linker_person1': linkerPerson1,
    'linker_person2': linkerPerson2,
    'building_metrage': buildingMetrage,
    'meter_subscription_number': meterSubscriptionNumber,
    'last_edited_by': lastEditedBy,
    'building_image': buildingImage,
    'device': device,
    'installed_device_model': installedDeviceModel,
    'connection_type': connectionType,
    'modem_model': modemModel,
    'has_simcard': hasSimcard,
    'modem_simcard_number': modemSimcardNumber,
    'installation_date': installationDate,
    'modem_simcard_serial_number_image': modemSimcardSerialNumberImage,
    'device_serial_number_image': deviceSerialNumberImage,
    'usage': usage,
    'has_exchanger': hasExchanger,
    'number_of_pool_exchangers': numberOfPoolExchangers,
    'number_of_jaccuzi_exchangers': numberOfJaccuziExchangers,
    'number_of_floor_heating_exchangers': numberOfFloorHeatingExchangers,
    'number_of_boilers': numberOfBoilers,
    'number_of_circulating_pumps': numberOfCirculatingPumps,
    'number_of_coil_sources': numberOfCoilSources,
    'number_of_coil_sources_pumps': numberOfCoilSourcesPumps,
    'number_of_hot_water_pumps': numberOfHotWaterPumps,
    'engineroom_images': engineroomImages.map((e) => e.toJson()).toList(),
  };

  static CompleteDeviceInfo fromJsonString(String str) =>
      CompleteDeviceInfo.fromJson(json.decode(str));

  String toJsonString() => json.encode(toJson());
}

class EngineroomImage {
  final String device;
  final int imageId;
  final String uploadedBy;
  final String image;
  final String createdAt;
  final String updatedAt;

  EngineroomImage({
    required this.device,
    required this.imageId,
    required this.uploadedBy,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EngineroomImage.fromJson(Map<String, dynamic> json) {
    return EngineroomImage(
      device: json['device'] ?? '',
      imageId: json['image_id'] ?? 0,
      uploadedBy: json['uploaded_by'] ?? '',
      image: json['image'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updateed_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'device': device,
    'image_id': imageId,
    'uploaded_by': uploadedBy,
    'image': image,
    'created_at': createdAt,
    'updateed_at': updatedAt,
  };
}
