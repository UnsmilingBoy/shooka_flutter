class Organization {
  final int id;
  final String name;
  final String administration;

  Organization({
    required this.id,
    required this.name,
    required this.administration,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json["id"],
      name: json["organization"],
      administration: json["administration"],
    );
  }
}
