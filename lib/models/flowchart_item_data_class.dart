class FlowchartItem {
  final String label;
  final String description;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  FlowchartItem({
    required this.label,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FlowchartItem.fromJson(Map<String, dynamic> json) {
    return FlowchartItem(
      label: json['label'] ?? '',
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'description': description,
    'is_active': isActive,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
