/// Per-device flowchart progress row from
/// POST /api/shouka/objects/flowchart/retrieve/ `{"id": deviceId}`.
class DeviceFlowchartStep {
  final int id;
  final int flowchartItemId;
  final String label;
  final int order;
  final bool isDone;
  final String? doneAt;
  final dynamic doneBy;
  final String note;
  final String createdAt;
  final String updatedAt;

  DeviceFlowchartStep({
    required this.id,
    required this.flowchartItemId,
    required this.label,
    required this.order,
    required this.isDone,
    required this.doneAt,
    required this.doneBy,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  static int _asInt(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static String? _asNullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  factory DeviceFlowchartStep.fromJson(Map<String, dynamic> json) {
    return DeviceFlowchartStep(
      id: _asInt(json['id']),
      flowchartItemId: _asInt(json['flowchart_item_id']),
      label: (json['label'] ?? '').toString(),
      order: _asInt(json['order']),
      isDone: json['is_done'] == true,
      doneAt: _asNullableString(json['done_at']),
      doneBy: json['done_by'],
      note: (json['note'] ?? '').toString(),
      createdAt: (json['created_at'] ?? '').toString(),
      updatedAt: (json['updated_at'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'flowchart_item_id': flowchartItemId,
    'label': label,
    'order': order,
    'is_done': isDone,
    'done_at': doneAt,
    'done_by': doneBy,
    'note': note,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
