import 'package:flutter/material.dart';

import '../models/group.dart';

class GroupCard extends StatelessWidget {
  const GroupCard({
    required this.group,
    required this.onTap,
    super.key,
  });

  final Group group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          child: const Icon(Icons.groups_outlined),
        ),
        title: Text(
          group.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            _subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  String get _subtitle {
    final role = group.role?.value ?? 'Cần xác nhận role';
    final description = group.description;

    if (description == null || description.trim().isEmpty) {
      return '${group.currency} - $role';
    }

    return '${group.currency} - $role - $description';
  }
}
