class UserRole {
  final int userAccessLevel;
  final String userRoleName;
  final String userRoleLabel;
  final String userRoleDescription;
  final bool userCanSendCommand;
  final List<AccessiblePanel> accessiblePanels;

  UserRole({
    required this.userAccessLevel,
    required this.userRoleName,
    required this.userRoleLabel,
    required this.userRoleDescription,
    required this.userCanSendCommand,
    required this.accessiblePanels,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      userAccessLevel: json['user_access_level'] ?? 0,
      userRoleName: json['user_role_name'] ?? "",
      userRoleLabel: json['user_role_label'] ?? "",
      userRoleDescription: json['user_role_description'] ?? "",
      userCanSendCommand: json['user_can_send_command'] ?? false,
      accessiblePanels:
          (json['accessible_panels'] as List<dynamic>?)
              ?.map((e) => AccessiblePanel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class AccessiblePanel {
  final String name;
  final String label;
  final String description;

  AccessiblePanel({
    required this.name,
    required this.label,
    required this.description,
  });

  factory AccessiblePanel.fromJson(Map<String, dynamic> json) {
    return AccessiblePanel(
      name: json['name'] ?? "",
      label: json['label'] ?? "",
      description: json['description'] ?? "",
    );
  }
}

class LoginHistory {
  final String createdAt;
  final String ipAddress;
  final bool success;
  final String category;
  final String domainName;
  final String userAgent;
  final String message;

  LoginHistory({
    required this.createdAt,
    required this.ipAddress,
    required this.success,
    required this.category,
    required this.domainName,
    required this.userAgent,
    required this.message,
  });

  factory LoginHistory.fromJson(Map<String, dynamic> json) {
    return LoginHistory(
      createdAt: json['created_at'] ?? "",
      ipAddress: json['ip_address'] ?? "",
      success: json['success'] ?? false,
      category: json['category'] ?? "",
      domainName: json['domain_name'] ?? "",
      userAgent: json['user_agent'] ?? "",
      message: json['message'] ?? "",
    );
  }
}

class ActiveToken {
  final String token;
  final String userAgent;
  final String ipAddress;
  final String lastUsed;
  final String created;

  ActiveToken({
    required this.token,
    required this.userAgent,
    required this.ipAddress,
    required this.lastUsed,
    required this.created,
  });

  factory ActiveToken.fromJson(Map<String, dynamic> json) {
    return ActiveToken(
      token: json['token'] ?? "",
      userAgent: json['user_agent'] ?? "",
      ipAddress: json['ip_address'] ?? "",
      lastUsed: json['last_used'] ?? "",
      created: json['created'] ?? "",
    );
  }
}

class User {
  final int userId;
  final bool isAdmin;
  final String username;
  final String? email;
  final String firstName;
  final String lastName;
  final bool isActive;
  final String createdAt;
  final String phoneNumber;
  final int accessLevel;
  final String accessApps;
  final UserRole userRole;
  final int maxAllowableActiveTokens;
  final String identificationNumber;
  final int tokenExpiresIn;
  final int failedLoginCount;
  final String? lastFailedLogin;
  final String lastLoginIpAddress;
  final String lastSuccessfulLogin;
  final String ipPolicyType;
  final String allowedIps;
  final List<LoginHistory> lastLogin;
  final List<ActiveToken> activeTokens;

  User({
    required this.userId,
    required this.isAdmin,
    required this.username,
    this.email,
    required this.firstName,
    required this.lastName,
    required this.isActive,
    required this.createdAt,
    required this.phoneNumber,
    required this.accessLevel,
    required this.accessApps,
    required this.userRole,
    required this.maxAllowableActiveTokens,
    required this.identificationNumber,
    required this.tokenExpiresIn,
    required this.failedLoginCount,
    this.lastFailedLogin,
    required this.lastLoginIpAddress,
    required this.lastSuccessfulLogin,
    required this.ipPolicyType,
    required this.allowedIps,
    required this.lastLogin,
    required this.activeTokens,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? 0,
      isAdmin: json['is_admin'] ?? false,
      username: json['username'] ?? "",
      email: json['email'],
      firstName: json['first_name'] ?? "بدون نام",
      lastName: json['last_name'] ?? "",
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] ?? "",
      phoneNumber: json['phone_number']?.toString() ?? "0",
      accessLevel: json['access_level'] ?? 0,
      accessApps: json['access_apps'] ?? "",
      userRole: UserRole.fromJson(json['user_role'] ?? {}),
      maxAllowableActiveTokens: json['max_allowable_active_tokens'] ?? 0,
      identificationNumber: json['identification_number']?.toString() ?? "0",
      tokenExpiresIn: json['token_expires_in'] ?? 0,
      failedLoginCount: json['failed_login_count'] ?? 0,
      lastFailedLogin: json['last_failed_login'],
      lastLoginIpAddress: json['last_login_ip_address'] ?? "",
      lastSuccessfulLogin: json['last_successful_login'] ?? "",
      ipPolicyType: json['ip_policy_type'] ?? "",
      allowedIps: json['allowed_ips'] ?? "",
      lastLogin:
          (json['last_login'] as List<dynamic>?)
              ?.map((e) => LoginHistory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      activeTokens:
          (json['active_tokens'] as List<dynamic>?)
              ?.map((e) => ActiveToken.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
