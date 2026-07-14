import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../models/expense.dart';
import '../providers/expenses_providers.dart';
import 'expense_formatters.dart';

class ExpenseListSection extends ConsumerStatefulWidget {
  const ExpenseListSection({
    required this.groupId,
    required this.currency,
    super.key,
  });

  final String groupId;
  final String currency;

  @override
  ConsumerState<ExpenseListSection> createState() => _ExpenseListSectionState();
}

class _ExpenseListSectionState extends ConsumerState<ExpenseListSection> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref
          .read(expenseListControllerProvider(widget.groupId).notifier)
          .load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = expenseListControllerProvider(widget.groupId);
    final state = ref.watch(provider);

    ref.listen(provider, (previous, next) {
      final error = next.errorMessage;

      if (error != null && error != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    });

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Expenses',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Tải lại khoản chi',
                  onPressed: state.isLoading
                      ? null
                      : () => ref.read(provider.notifier).load(refresh: true),
                  icon: const Icon(Icons.refresh),
                ),
                FilledButton.icon(
                  onPressed: () async {
                    final changed = await context.push<bool>(
                      AppRoutes.expenseCreate(widget.groupId),
                    );

                    if (changed == true && context.mounted) {
                      ref.read(provider.notifier).load(refresh: true);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (state.isLoading && state.expenses.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.errorMessage != null && state.expenses.isEmpty)
              _ExpenseListError(
                message: state.errorMessage!,
                onRetry: () => ref.read(provider.notifier).load(),
              )
            else if (state.expenses.isEmpty)
              const _ExpenseEmptyState()
            else
              ...state.expenses.map(
                (expense) => _ExpenseTile(
                  expense: expense,
                  fallbackCurrency: widget.currency,
                  onTap: () async {
                    final changed = await context.push<bool>(
                      AppRoutes.expenseDetail(widget.groupId, expense.id),
                    );

                    if (changed == true && context.mounted) {
                      ref.read(provider.notifier).load(refresh: true);
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({
    required this.expense,
    required this.fallbackCurrency,
    required this.onTap,
  });

  final Expense expense;
  final String fallbackCurrency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final currency = expense.currency.isEmpty ? fallbackCurrency : expense.currency;
    final payer = expense.paidByUser?.name.isNotEmpty == true
        ? expense.paidByUser!.name
        : expense.paidByUser?.email ?? 'Cần xác nhận';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.receipt_long_outlined),
      title: Text(expense.title),
      subtitle: Text(
        'Paid by $payer • ${expense.participantCount} participants • ${formatExpenseDate(expense.expenseDate)}',
      ),
      trailing: Text(formatExpenseAmount(expense.amount, currency)),
      onTap: onTap,
    );
  }
}

class _ExpenseEmptyState extends StatelessWidget {
  const _ExpenseEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Text('Nhóm này chưa có khoản chi. Hãy tạo khoản chi đầu tiên.'),
    );
  }
}

class _ExpenseListError extends StatelessWidget {
  const _ExpenseListError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
