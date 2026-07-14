import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../models/expense.dart';
import '../providers/expenses_providers.dart';
import '../widgets/expense_formatters.dart';

class ExpenseDetailScreen extends ConsumerStatefulWidget {
  const ExpenseDetailScreen({
    required this.groupId,
    required this.expenseId,
    super.key,
  });

  final String groupId;
  final String expenseId;

  @override
  ConsumerState<ExpenseDetailScreen> createState() =>
      _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends ConsumerState<ExpenseDetailScreen> {
  ExpenseDetailParams get _params => ExpenseDetailParams(
        groupId: widget.groupId,
        expenseId: widget.expenseId,
      );

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref.read(expenseDetailControllerProvider(_params).notifier).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = expenseDetailControllerProvider(_params);
    final state = ref.watch(provider);
    final expense = state.expense;

    ref.listen(provider, (previous, next) {
      final action = next.actionMessage;
      final error = next.errorMessage;

      if (action != null && action != previous?.actionMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(action)),
        );
      }

      if (error != null && error != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(expense?.title ?? 'Chi tiết khoản chi'),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed:
                state.isLoading ? null : () => ref.read(provider.notifier).load(),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Sửa khoản chi',
            onPressed: state.isSaving
                ? null
                : () async {
                    final changed = await context.push<bool>(
                      AppRoutes.expenseEdit(widget.groupId, widget.expenseId),
                    );

                    if (changed == true && context.mounted) {
                      ref.read(provider.notifier).load();
                    }
                  },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading && expense == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (expense == null) {
            return _ExpenseDetailError(
              message: state.errorMessage ?? 'Không tìm thấy khoản chi.',
              onRetry: () => ref.read(provider.notifier).load(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(provider.notifier).load(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                _ExpenseSummary(expense: expense),
                const SizedBox(height: 20),
                _SplitsSection(expense: expense),
                const SizedBox(height: 20),
                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: const Text('Xóa khoản chi'),
                    subtitle: const Text('Backend sẽ xóa mềm khoản chi này.'),
                    enabled: !state.isSaving,
                    onTap: _confirmDelete,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa khoản chi?'),
          content: const Text(
            'Backend sẽ xóa mềm khoản chi và các splits liên quan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final success = await ref
        .read(expenseDetailControllerProvider(_params).notifier)
        .deleteExpense();

    if (success && mounted) {
      ref
          .read(expenseListControllerProvider(widget.groupId).notifier)
          .load(refresh: true);
      Navigator.of(context).pop(true);
    }
  }
}

class _ExpenseSummary extends StatelessWidget {
  const _ExpenseSummary({
    required this.expense,
  });

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    final payer = expense.paidByUser?.name.isNotEmpty == true
        ? expense.paidByUser!.name
        : expense.paidByUser?.email ?? 'Cần xác nhận';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long_outlined, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    expense.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
            if (expense.description != null &&
                expense.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(expense.description!),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(
                    formatExpenseAmount(expense.amount, expense.currency),
                  ),
                ),
                Chip(label: Text('Paid by $payer')),
                Chip(label: Text(expense.splitType?.value ?? 'Cần xác nhận')),
                Chip(label: Text(formatExpenseDate(expense.expenseDate))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SplitsSection extends StatelessWidget {
  const _SplitsSection({
    required this.expense,
  });

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Splits',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (expense.splits.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Backend chưa trả splits cho khoản chi này.'),
              )
            else
              ...expense.splits.map(
                (split) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.account_circle_outlined),
                  title: Text(
                    split.user.name.isEmpty ? split.user.email : split.user.name,
                  ),
                  subtitle: Text(split.user.email),
                  trailing: Text(
                    formatExpenseAmount(split.amount, expense.currency),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseDetailError extends StatelessWidget {
  const _ExpenseDetailError({
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
