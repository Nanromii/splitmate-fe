import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/groups_providers.dart';
import '../widgets/group_form.dart';

class EditGroupScreen extends ConsumerStatefulWidget {
  const EditGroupScreen({
    required this.groupId,
    super.key,
  });

  final String groupId;

  @override
  ConsumerState<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends ConsumerState<EditGroupScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref
          .read(groupDetailControllerProvider(widget.groupId).notifier)
          .load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = groupDetailControllerProvider(widget.groupId);
    final state = ref.watch(provider);
    final group = state.group;

    ref.listen(provider, (previous, next) {
      final error = next.errorMessage;

      if (error != null && error != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sửa nhóm'),
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading && group == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (group == null) {
            return _EditErrorState(
              message: state.errorMessage ?? 'Không tìm thấy dữ liệu nhóm.',
              onRetry: () => ref.read(provider.notifier).load(),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              GroupForm(
                initialName: group.name,
                initialDescription: group.description,
                initialCurrency: group.currency,
                submitLabel: 'Lưu thay đổi',
                isSubmitting: state.isSaving,
                onSubmit: (data) async {
                  final success = await ref.read(provider.notifier).updateGroup(
                        name: data.name,
                        description: data.description,
                        currency: data.currency,
                      );

                  if (success && context.mounted) {
                    Navigator.of(context).pop(true);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EditErrorState extends StatelessWidget {
  const _EditErrorState({
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
            Text(message, textAlign: TextAlign.center),
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
