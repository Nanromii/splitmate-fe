import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/models/auth_user.dart';
import '../../auth/providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).session?.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: user == null
          ? const Center(
              child: Text('Không tìm thấy thông tin người dùng hiện tại.'),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _ProfileHeader(user: user),
                const SizedBox(height: 24),
                Card(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _ProfileField(
                        label: 'ID',
                        value: user.id,
                      ),
                      const Divider(height: 1),
                      _ProfileField(
                        label: 'Email',
                        value: user.email,
                      ),
                      const Divider(height: 1),
                      _ProfileField(
                        label: 'Full name',
                        value: user.fullName,
                      ),
                      const Divider(height: 1),
                      _ProfileField(
                        label: 'Avatar URL',
                        value: user.avatarUrl,
                      ),
                      const Divider(height: 1),
                      _ProfileField(
                        label: 'Role',
                        value: user.role,
                      ),
                      const Divider(height: 1),
                      _ProfileField(
                        label: 'Status',
                        value: user.status,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Profile hiện chỉ đọc vì backend contract hiện tại chưa có API update profile.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.user,
  });

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    final name = _valueOrFallback(user.fullName, 'SplitMate user');

    return Column(
      children: [
        CircleAvatar(
          radius: 42,
          backgroundImage: _avatarProvider(user.avatarUrl),
          child: _avatarProvider(user.avatarUrl) == null
              ? const Icon(Icons.person_outline, size: 42)
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  ImageProvider? _avatarProvider(String? avatarUrl) {
    final value = avatarUrl?.trim();

    if (value == null || value.isEmpty) {
      return null;
    }

    return NetworkImage(value);
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.value,
  });

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text(_valueOrFallback(value, 'Chưa có dữ liệu')),
    );
  }
}

String _valueOrFallback(String? value, String fallback) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? fallback : trimmed;
}
