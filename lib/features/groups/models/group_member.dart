import 'group.dart';

class GroupMember {
  const GroupMember({
    required this.memberId,
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.joinedAt,
  });

  final String memberId;
  final String userId;
  final String name;
  final String email;
  final String? avatarUrl;
  final GroupRole? role;
  final DateTime? joinedAt;

  bool get isOwner => role == GroupRole.owner;

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      memberId: (json['memberId'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      role: GroupRole.fromJson(json['role']),
      joinedAt: DateTime.tryParse((json['joinedAt'] ?? '').toString()),
    );
  }
}
