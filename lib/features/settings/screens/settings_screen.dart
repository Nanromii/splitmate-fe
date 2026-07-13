import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.session?.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              child: Icon(Icons.person_outline),
            ),
            title: Text(user?.fullName ?? 'SplitMate user'),
            subtitle: Text(user?.email ?? 'No email available'),
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.account_circle_outlined),
                  title: const Text('Profile'),
                  subtitle: const Text('Profile editing sẽ được thêm sau.'),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  subtitle: const Text('Xóa session local và quay về login.'),
                  enabled: !authState.isLoading,
                  onTap: authState.isLoading
                      ? null
                      : () {
                          ref.read(authControllerProvider.notifier).logout();
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
