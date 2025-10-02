class Location {
  final int id;
  final String city;
  final String province;

  Location({required this.id, required this.city, required this.province});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json["id"],
      city: json["city"],
      province: json["province"],
    );
  }
}
