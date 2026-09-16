enum InventoryFormType { pack, parts, returned }

extension InventoryFormTypeX on InventoryFormType {
  String get label => switch (this) {
    InventoryFormType.pack => 'ارسال پک',
    InventoryFormType.parts => 'ارسال قطعات',
    InventoryFormType.returned => 'برگشتی',
  };
}

bool _flagOf(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
  }
  return false;
}

class InventoryLineItem {
  final int formItemId;
  final String itemType;
  final int quantity;
  const InventoryLineItem({
    required this.itemType,
    required this.quantity,
    this.formItemId = 0,
  });
  factory InventoryLineItem.fromJson(Map<String, dynamic> json) =>
      InventoryLineItem(
        formItemId:
            int.tryParse(
              (json['form_item_id'] ??
                      json['id'] ??
                      json['item_id'] ??
                      json['formItemId'] ??
                      0)
                  .toString(),
            ) ??
            0,
        itemType: json['item_type']?.toString() ?? '',
        quantity: int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
      );
}

class InventoryInstallItemOption {
  final String name;
  final String label;
  final String description;
  final bool isActive;

  const InventoryInstallItemOption({
    required this.name,
    required this.label,
    this.description = '',
    this.isActive = true,
  });

  factory InventoryInstallItemOption.fromJson(Map<String, dynamic> json) =>
      InventoryInstallItemOption(
        name: json['name']?.toString() ?? '',
        label: json['label']?.toString() ?? json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        isActive: json['is_active'] != false,
      );
}

class InventorySettlement {
  final int id;
  final String settlementType;
  final String amount;
  final String sourceBank;
  final String destinationBank;
  final String sentTo;
  final String createdBy;
  final String? receiptImage;
  final String note;
  final String createdAt;

  const InventorySettlement({
    required this.id,
    required this.settlementType,
    this.amount = '',
    this.sourceBank = '',
    this.destinationBank = '',
    this.sentTo = '',
    this.createdBy = '',
    this.receiptImage,
    this.note = '',
    this.createdAt = '',
  });

  /// Normalizes both API values (`device` / `representatives`) and the
  /// Persian labels returned by get-by-id (`تسویه حساب ...`).
  bool get isRepresentative {
    final normalized = settlementType.trim().toLowerCase();
    if (normalized == 'representatives' || normalized == 'representative') {
      return true;
    }
    // Persian labels: «تسویه حساب با نماینده» vs «تسویه حساب شرکت / دستگاه»
    if (settlementType.contains('نماینده')) return true;
    return false;
  }

  bool get isDevice => !isRepresentative;

  String get typeLabel => isRepresentative
      ? 'تسویه حساب با نماینده'
      : 'تسویه حساب دستگاه (شرکت)';

  factory InventorySettlement.fromJson(Map<String, dynamic> json) =>
      InventorySettlement(
        id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
        settlementType:
            json['settlement_type']?.toString() ??
            json['settlementType']?.toString() ??
            '',
        amount: json['amount']?.toString() ?? '',
        sourceBank: json['source_bank']?.toString() ?? '',
        destinationBank: json['destination_bank']?.toString() ?? '',
        sentTo: json['sent_to']?.toString() ?? '',
        createdBy: json['created_by']?.toString() ?? '',
        receiptImage: json['receipt_image']?.toString(),
        note: json['note']?.toString() ?? '',
        createdAt: json['created_at']?.toString() ?? '',
      );
}

List<InventorySettlement> _settlementsOf(Map<String, dynamic> json) =>
    (json['settlements'] as List? ?? [])
        .whereType<Map>()
        .map(
          (item) =>
              InventorySettlement.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();

class InventoryDevice {
  final int id;
  final String code;
  final String serialNumber;
  final String deviceType;
  final bool isInstalled;
  final bool isReturned;
  final bool isSent;
  final List<InventoryLineItem> items;
  final List<InventorySettlement> settlements;
  const InventoryDevice({
    required this.id,
    required this.code,
    required this.serialNumber,
    required this.deviceType,
    this.isInstalled = false,
    this.isReturned = false,
    this.isSent = false,
    this.items = const [],
    this.settlements = const [],
  });
  factory InventoryDevice.fromJson(Map<String, dynamic> json) =>
      InventoryDevice(
        id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
        code: json['code']?.toString() ?? '',
        serialNumber: json['serial_number']?.toString() ?? '',
        deviceType: json['device_type']?.toString() ?? '',
        isInstalled: _flagOf(json, const ['is_installed']),
        isReturned: _flagOf(json, const ['is_returned']),
        isSent: _flagOf(json, const ['is_sent']),
        items: (json['items'] as List? ?? [])
            .whereType<Map>()
            .map(
              (item) =>
                  InventoryLineItem.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(),
        settlements: _settlementsOf(json),
      );
}

class InventoryReturnEntry {
  final String type;
  final int id;
  final String code;
  final String serialNumber;
  final String deviceType;
  final int sourceFormId;
  final int quantity;
  final String itemType;
  final String returnedBy;
  final String returnedAt;
  final String note;

  const InventoryReturnEntry({
    required this.type,
    required this.id,
    this.code = '',
    this.serialNumber = '',
    this.deviceType = '',
    this.sourceFormId = 0,
    this.quantity = 0,
    this.itemType = '',
    this.returnedBy = '',
    this.returnedAt = '',
    this.note = '',
  });

  bool get isDevice => type == 'device';

  String get title => isDevice
      ? (code.isEmpty ? 'دستگاه #$id' : code)
      : (itemType.isEmpty ? 'قلم #$id' : itemType);

  String get subtitle => isDevice
      ? '$deviceType • $serialNumber'
      : quantity > 0
      ? '$quantity عدد'
      : '';

  factory InventoryReturnEntry.fromJson(Map<String, dynamic> json) =>
      InventoryReturnEntry(
        type: json['type']?.toString() ?? 'device',
        id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
        code: json['code']?.toString() ?? '',
        serialNumber: json['serial_number']?.toString() ?? '',
        deviceType: json['device_type']?.toString() ?? '',
        sourceFormId:
            int.tryParse(json['source_form_id']?.toString() ?? '') ?? 0,
        quantity: int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
        itemType:
            json['item_type']?.toString() ?? json['itemType']?.toString() ?? '',
        returnedBy:
            json['returned_by']?.toString() ??
            json['created_by']?.toString() ??
            '',
        returnedAt:
            json['returned_at']?.toString() ??
            json['created_at']?.toString() ??
            '',
        note: json['note']?.toString() ?? '',
      );
}

class InventoryFormItem {
  final int id;
  final String destination,
      exportUnit,
      postingType,
      sourceBank,
      destinationBank;
  final String amount, createdAt, dateOfReceipt, note, sentTo, createdBy;
  final String source;
  final bool isReturned;
  final String? receiptImage;
  final List<InventoryDevice> devices;
  final List<InventoryLineItem> installItems;
  final List<InventoryReturnEntry> returnData;
  final List<InventorySettlement> settlements;
  const InventoryFormItem({
    required this.id,
    required this.destination,
    required this.exportUnit,
    required this.postingType,
    required this.sourceBank,
    required this.destinationBank,
    required this.amount,
    required this.receiptImage,
    required this.createdAt,
    required this.dateOfReceipt,
    required this.note,
    required this.sentTo,
    required this.createdBy,
    this.source = '',
    this.isReturned = false,
    this.returnData = const [],
    required this.devices,
    required this.installItems,
    this.settlements = const [],
  });
  factory InventoryFormItem.fromJson(Map<String, dynamic> json) =>
      InventoryFormItem(
        id: int.tryParse((json['form_id'] ?? json['id']).toString()) ?? 0,
        destination: json['destination']?.toString() ?? '',
        exportUnit: json['export_unit']?.toString() ?? '',
        postingType: json['posting_type']?.toString() ?? '',
        sourceBank: json['source_bank']?.toString() ?? '',
        destinationBank: json['destination_bank']?.toString() ?? '',
        amount: json['amount']?.toString() ?? '',
        receiptImage: json['receipt_image']?.toString(),
        createdAt: json['created_at']?.toString() ?? '',
        dateOfReceipt: json['date_of_receipt']?.toString() ?? '',
        note: json['note']?.toString() ?? '',
        sentTo: json['sent_to']?.toString() ?? '',
        createdBy: (json['created_by'] ?? json['creator'])?.toString() ?? '',
        source: json['source']?.toString() ?? '',
        isReturned: _flagOf(json, const ['is_returned']),
        returnData: (json['return_data'] as List? ?? [])
            .whereType<Map>()
            .map(
              (item) => InventoryReturnEntry.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(),
        devices: (json['devices'] as List? ?? [])
            .whereType<Map>()
            .map(
              (item) =>
                  InventoryDevice.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(),
        installItems: (json['install_items'] as List? ?? [])
            .whereType<Map>()
            .map(
              (item) =>
                  InventoryLineItem.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(),
        settlements: _settlementsOf(json),
      );
  int get deviceCount => devices.length;
  int get itemCount =>
      devices.fold(0, (sum, device) => sum + device.items.length);

  /// All settlements for this form: form-level ones plus per-device ones
  /// (deduplicated by id, since the API nests the same settlement under
  /// every device it covers).
  List<InventorySettlement> get allSettlements {
    final merged = <int, InventorySettlement>{};
    for (final settlement in settlements) {
      merged[settlement.id] = settlement;
    }
    for (final device in devices) {
      for (final settlement in device.settlements) {
        merged.putIfAbsent(settlement.id, () => settlement);
      }
    }
    return merged.values.toList()
      ..sort((a, b) => a.id.compareTo(b.id));
  }

  List<InventorySettlement> get deviceSettlements =>
      allSettlements.where((s) => s.isDevice).toList();

  List<InventorySettlement> get representativeSettlements =>
      allSettlements.where((s) => s.isRepresentative).toList();

  /// Maps settlement id -> device codes it covers. The get-by-id API nests
  /// the same settlement object under every device it covers, so coverage
  /// is inferred from that nesting. Form-level-only settlements map to [].
  Map<int, List<String>> get settlementDeviceCodes {
    final map = <int, List<String>>{};
    for (final settlement in settlements) {
      map.putIfAbsent(settlement.id, () => []);
    }
    for (final device in devices) {
      for (final settlement in device.settlements) {
        map.putIfAbsent(settlement.id, () => []);
        if (!map[settlement.id]!.contains(device.code)) {
          map[settlement.id]!.add(device.code);
        }
      }
    }
    return map;
  }

  List<String> deviceCodesForSettlement(int settlementId) =>
      settlementDeviceCodes[settlementId] ?? [];

  /// Device codes already settled for the given type.
  Set<String> settledCodes({required bool representative}) {
    final result = <String>{};
    for (final device in devices) {
      final hasType = device.settlements.any(
        (s) => s.isRepresentative == representative,
      );
      if (hasType) result.add(device.code);
    }
    return result;
  }

  bool isDeviceSettled(String code, {required bool representative}) =>
      settledCodes(representative: representative).contains(code);

  /// Form kind used for the «نوع فرم» column: a form flagged as returned
  /// wins, otherwise a form carrying devices is a device pack and a
  /// devices-less form is an install-items form.
  InventoryFormType get kind {
    if (isReturned) return InventoryFormType.returned;
    if (devices.isNotEmpty) return InventoryFormType.pack;
    return InventoryFormType.parts;
  }

  String get searchText => [
    id,
    destination,
    exportUnit,
    postingType,
    sourceBank,
    destinationBank,
    source,
    note,
    sentTo,
    createdBy,
    kind.label,
    ...devices.expand((d) => [d.code, d.serialNumber, d.deviceType]),
  ].join(' ').toLowerCase();
}
