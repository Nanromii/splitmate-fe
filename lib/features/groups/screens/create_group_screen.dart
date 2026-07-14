import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../providers/groups_providers.dart';
import '../widgets/group_form.dart';

class CreateGroupScreen extends ConsumerWidget {
  const CreateGroupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(groupListControllerProvider);

    ref.listen(groupListControllerProvider, (previous, next) {
      final error = next.errorMessage;

      if (error != null && error != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo nhóm'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GroupForm(
            submitLabel: 'Tạo nhóm',
            isSubmitting: state.isLoading,
            onSubmit: (data) async {
              final group = await ref
                  .read(groupListControllerProvider.notifier)
                  .createGroup(
                    name: data.name,
                    description: data.description,
                    currency: data.currency,
                  );

              if (!context.mounted || group == null) {
                return;
              }

              context.go(AppRoutes.groupDetail(group.id));
            },
          ),
        ],
      ),
    );
  }
}
