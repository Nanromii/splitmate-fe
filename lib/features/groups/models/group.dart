enum GroupRole {
  owner('OWNER'),
  admin('ADMIN'),
  member('MEMBER');

  const GroupRole(this.value);

  final String value;

  static GroupRole? fromJson(Object? value) {
    final text = value?.toString();

    for (final role in GroupRole.values) {
      if (role.value == text) {
        return role;
      }
    }

    return null;
  }
}

class Group {
  const Group({
    required this.id,
    required this.name,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.role,
    this.ownerId,
  });

  final String id;
  final String name;
  final String? description;
  final String currency;
  final GroupRole? role;
  final String? ownerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isOwner => role == GroupRole.owner;

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      currency: (json['currency'] ?? '').toString(),
      role: GroupRole.fromJson(json['role']),
      ownerId: json['ownerId']?.toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()),
    );
  }
}
