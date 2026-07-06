class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.role,
    this.status,
  });

  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String? role;
  final String? status;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      fullName: (json['fullName'] ?? json['displayName'] ?? json['name'])
          ?.toString(),
      avatarUrl: (json['avatarUrl'] ?? json['picture'] ?? json['photoUrl'])
          ?.toString(),
      role: json['role']?.toString(),
      status: json['status']?.toString(),
    );
  }
}