import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../groups/providers/groups_providers.dart';
import '../providers/expenses_providers.dart';
import '../widgets/expense_form.dart';

class EditExpenseScreen extends ConsumerStatefulWidget {
  const EditExpenseScreen({
    required this.groupId,
    required this.expenseId,
    super.key,
  });

  final String groupId;
  final String expenseId;

  @override
  ConsumerState<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends ConsumerState<EditExpenseScreen> {
  ExpenseDetailParams get _params => ExpenseDetailParams(
        groupId: widget.groupId,
        expenseId: widget.expenseId,
      );

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref.read(groupDetailControllerProvider(widget.groupId).notifier).load();
      ref.read(expenseDetailControllerProvider(_params).notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = groupDetailControllerProvider(widget.groupId);
    final groupState = ref.watch(groupProvider);
    final expenseProvider = expenseDetailControllerProvider(_params);
    final expenseState = ref.watch(expenseProvider);
    final group = groupState.group;
    final expense = expenseState.expense;

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
        title: const Text('Sửa khoản chi'),
      ),
      body: Builder(
        builder: (context) {
          if ((groupState.isLoading && group == null) ||
              (expenseState.isLoading && expense == null)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (group == null || expense == null) {
            return _ExpenseScreenError(
              message: expenseState.errorMessage ??
                  groupState.errorMessage ??
                  'Không tìm thấy khoản chi.',
              onRetry: () {
                ref.read(groupProvider.notifier).load();
                ref.read(expenseProvider.notifier).load();
              },
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              ExpenseForm(
                members: groupState.members,
                currency: group.currency,
                submitLabel: 'Lưu thay đổi',
                isSubmitting: expenseState.isSaving,
                initialExpense: expense,
                onSubmit: (data) async {
                  final success =
                      await ref.read(expenseProvider.notifier).updateExpense(
                            title: data.title,
                            description: data.description,
                            amount: data.amount,
                            paidByUserId: data.paidByUserId,
                            participantIds: data.participantIds,
                            expenseDate: data.expenseDate,
                          );

                  if (success && context.mounted) {
                    ref
                        .read(expenseListControllerProvider(widget.groupId)
                            .notifier)
                        .load(refresh: true);
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
