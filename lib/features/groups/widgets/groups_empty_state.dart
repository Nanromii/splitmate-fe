import 'package:flutter/material.dart';

class GroupsEmptyState extends StatelessWidget {
  const GroupsEmptyState({
    required this.onCreate,
    super.key,
  });

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.groups_outlined, size: 72),
            const SizedBox(height: 20),
            Text(
              'Chưa có nhóm nào',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Tạo nhóm đầu tiên để bắt đầu quản lý chi tiêu chung.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Tạo nhóm'),
            ),
          ],
        ),
      ),
    );
  }
}
