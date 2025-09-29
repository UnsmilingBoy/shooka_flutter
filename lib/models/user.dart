class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String profileHref;
  final bool isActive;
  final String dateJoined;
  final String lastLogin;
  final dynamic phoneNumber;

  User({
    required this.phoneNumber,
    required this.role,
    required this.profileHref,
    required this.isActive,
    required this.dateJoined,
    required this.lastLogin,
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? "",
      email: json['email'] ?? "",
      firstName: json['first_name'] == ""
          ? "بدون نام"
          : json['first_name'] ?? "بدون نام",
      lastName: json['last_name'] ?? "",
      role: json['role'] ?? "بدون نقش",
      profileHref: json['profile_image'] ?? "",
      isActive: json['is_active'],
      dateJoined: json['date_joined'],
      lastLogin: json['last_login'],
      phoneNumber: json["phone_number"] ?? "بدون شماره همراه",
    );
  }
}
