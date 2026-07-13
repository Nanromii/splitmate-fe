import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).session?.user;
    final displayName = user?.fullName ?? user?.email ?? 'SplitMate user';

    return Scaffold(
      appBar: AppBar(
        title: const Text('SplitMate'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Xin chào, $displayName',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Khung app chính đã sẵn sàng. Phase tiếp theo sẽ kết nối danh sách nhóm từ backend.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          _SummaryPanel(
            title: 'Groups',
            value: '0',
            message: 'Chưa tải dữ liệu nhóm trong phase này.',
            icon: Icons.groups_outlined,
          ),
          const SizedBox(height: 12),
          _SummaryPanel(
            title: 'Recent activity',
            value: '0',
            message: 'Expense và activity sẽ được mở rộng sau Groups.',
            icon: Icons.receipt_long_outlined,
          ),
          const SizedBox(height: 24),
          _EmptyState(
            icon: Icons.add_circle_outline,
            title: 'Bắt đầu từ Groups',
            message:
                'Phase 5 sẽ thêm API, state và màn hình quản lý group. Navigation hiện tại đã mở đường cho bước đó.',
          ),
        ],
      ),
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({
    required this.title,
    required this.value,
    required this.message,
    required this.icon,
  });

  final String title;
  final String value;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(message),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(icon, size: 56),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
