import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../groups/providers/groups_providers.dart';
import '../providers/expenses_providers.dart';
import '../widgets/expense_form.dart';

class CreateExpenseScreen extends ConsumerStatefulWidget {
  const CreateExpenseScreen({
    required this.groupId,
    super.key,
  });

  final String groupId;

  @override
  ConsumerState<CreateExpenseScreen> createState() =>
      _CreateExpenseScreenState();
}

class _CreateExpenseScreenState extends ConsumerState<CreateExpenseScreen> {
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
    final groupProvider = groupDetailControllerProvider(widget.groupId);
    final expenseProvider = expenseListControllerProvider(widget.groupId);
    final groupState = ref.watch(groupProvider);
    final expenseState = ref.watch(expenseProvider);
    final group = groupState.group;

    ref.listen(expenseProvider, (previous, next) {
      final error = next.errorMessage;

      if (error != null && error != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo khoản chi'),
      ),
      body: Builder(
        builder: (context) {
          if (groupState.isLoading && group == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (group == null) {
            return _ExpenseScreenError(
              message: groupState.errorMessage ?? 'Không tìm thấy nhóm.',
              onRetry: () => ref.read(groupProvider.notifier).load(),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              ExpenseForm(
                members: groupState.members,
                currency: group.currency,
                submitLabel: 'Tạo khoản chi',
                isSubmitting: expenseState.isSaving,
                onSubmit: (data) async {
                  final expense =
                      await ref.read(expenseProvider.notifier).createExpense(
                            title: data.title,
                            description: data.description,
                            amount: data.amount,
                            paidByUserId: data.paidByUserId,
                            participantIds: data.participantIds,
                            expenseDate: data.expenseDate,
                          );

                  if (expense != null && context.mounted) {
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

class _ExpenseScreenError extends StatelessWidget {
  const _ExpenseScreenError({
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
