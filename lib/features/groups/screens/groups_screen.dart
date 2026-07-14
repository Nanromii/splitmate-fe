import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../providers/groups_providers.dart';
import '../widgets/group_card.dart';
import '../widgets/groups_empty_state.dart';

class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({super.key});

  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref.read(groupListControllerProvider.notifier).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(groupListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: state.isLoading || state.isRefreshing
                ? null
                : () {
                    ref
                        .read(groupListControllerProvider.notifier)
                        .load(refresh: true);
                  },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _GroupsBody(
        onRefresh: () {
          return ref
              .read(groupListControllerProvider.notifier)
              .load(refresh: true);
        },
        onCreate: () => context.push(AppRoutes.groupCreate),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.groupCreate),
        icon: const Icon(Icons.add),
        label: const Text('Tạo nhóm'),
      ),
    );
  }
}

class _GroupsBody extends ConsumerWidget {
  const _GroupsBody({
    required this.onRefresh,
    required this.onCreate,
  });

  final Future<void> Function() onRefresh;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(groupListControllerProvider);

    if (state.isLoading && state.groups.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.groups.isEmpty) {
      return _GroupsErrorState(
        message: state.errorMessage!,
        onRetry: () {
          ref.read(groupListControllerProvider.notifier).load();
        },
      );
    }

    if (state.groups.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.65,
              child: GroupsEmptyState(onCreate: onCreate),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: state.groups.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                '${state.meta.total} nhóm',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          final group = state.groups[index - 1];

          return GroupCard(
            group: group,
            onTap: () => context.push(AppRoutes.groupDetail(group.id)),
          );
        },
      ),
    );
  }
}

class _GroupsErrorState extends StatelessWidget {
  const _GroupsErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
