class FlowchartItem {
  final int? itemId;
  final int order;
  final String label;
  final String description;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  FlowchartItem({
    this.itemId,
    this.order = 0,
    required this.label,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  static int _asInt(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  factory FlowchartItem.fromJson(Map<String, dynamic> json) {
    return FlowchartItem(
      itemId:
          json['item_id'] == null ? null : _asInt(json['item_id']),
      order: _asInt(json['order']),
      label: json['label'] ?? '',
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    if (itemId != null) 'item_id': itemId,
    'order': order,
    'label': label,
    'description': description,
    'is_active': isActive,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
