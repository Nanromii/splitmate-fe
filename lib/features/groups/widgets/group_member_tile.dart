import 'package:flutter/material.dart';

import '../models/group_member.dart';

class GroupMemberTile extends StatelessWidget {
  const GroupMemberTile({
    required this.member,
    required this.canTransferOwner,
    required this.onTransferOwner,
    super.key,
  });

  final GroupMember member;
  final bool canTransferOwner;
  final VoidCallback onTransferOwner;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        child: Text(_initial),
      ),
      title: Text(member.name.isEmpty ? member.email : member.name),
      subtitle: Text(member.email),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Chip(
            label: Text(member.role?.value ?? 'Cần xác nhận'),
          ),
          if (canTransferOwner) ...[
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Chuyển quyền chủ nhóm',
              onPressed: onTransferOwner,
              icon: const Icon(Icons.workspace_premium_outlined),
            ),
          ],
        ],
      ),
    );
  }

  String get _initial {
    final source = member.name.isEmpty ? member.email : member.name;

    if (source.isEmpty) {
      return '?';
    }

    return source.substring(0, 1).toUpperCase();
  }
}
