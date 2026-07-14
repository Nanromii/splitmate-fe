import 'package:flutter/material.dart';

import '../../groups/models/group_member.dart';
import '../models/expense.dart';
import 'expense_formatters.dart';

class ExpenseFormData {
  const ExpenseFormData({
    required this.title,
    required this.amount,
    required this.paidByUserId,
    required this.participantIds,
    this.description,
    this.expenseDate,
  });

  final String title;
  final String? description;
  final int amount;
  final String paidByUserId;
  final List<String> participantIds;
  final DateTime? expenseDate;
}

class ExpenseForm extends StatefulWidget {
  const ExpenseForm({
    required this.members,
    required this.currency,
    required this.submitLabel,
    required this.isSubmitting,
    required this.onSubmit,
    this.initialExpense,
    super.key,
  });

  final List<GroupMember> members;
  final String currency;
  final String submitLabel;
  final bool isSubmitting;
  final Expense? initialExpense;
  final Future<void> Function(ExpenseFormData data) onSubmit;

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  late String? _paidByUserId;
  late Set<String> _participantIds;
  late DateTime _expenseDate;

  @override
  void initState() {
    super.initState();
    final expense = widget.initialExpense;

    _titleController = TextEditingController(text: expense?.title ?? '');
    _descriptionController = TextEditingController(
      text: expense?.description ?? '',
    );
    _amountController = TextEditingController(
      text: expense == null || expense.amount == 0 ? '' : '${expense.amount}',
    );
    _paidByUserId = expense?.paidByUserId ??
        (widget.members.isEmpty ? null : widget.members.first.userId);
    _participantIds = expense?.splits.map((split) => split.userId).toSet() ??
        widget.members.map((member) => member.userId).toSet();
    _expenseDate = expense?.expenseDate?.toLocal() ?? DateTime.now();
  }

  @override
  void didUpdateWidget(covariant ExpenseForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_paidByUserId == null && widget.members.isNotEmpty) {
      setState(() {
        _paidByUserId = widget.members.first.userId;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Tên khoản chi',
              hintText: 'Dinner',
            ),
            textInputAction: TextInputAction.next,
            enabled: !widget.isSubmitting,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Tên khoản chi không được rỗng.';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Mô tả',
              hintText: 'Ghi chú khoản chi',
            ),
            minLines: 2,
            maxLines: 4,
            enabled: !widget.isSubmitting,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: 'Số tiền',
              suffixText: widget.currency,
            ),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            enabled: !widget.isSubmitting,
            validator: (value) {
              final amount = int.tryParse((value ?? '').trim());

              if (amount == null || amount <= 0) {
                return 'Số tiền phải lớn hơn 0.';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          _ExpenseDateTile(
            date: _expenseDate,
            enabled: !widget.isSubmitting,
            onPick: _pickDate,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _memberExists(_paidByUserId) ? _paidByUserId : null,
            decoration: const InputDecoration(
              labelText: 'Người trả tiền',
            ),
            items: widget.members
                .map(
                  (member) => DropdownMenuItem<String>(
                    value: member.userId,
                    child: Text(_memberLabel(member)),
                  ),
                )
                .toList(),
            onChanged: widget.isSubmitting
                ? null
                : (value) => setState(() => _paidByUserId = value),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Cần chọn người trả tiền.';
              }

              return null;
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Participants',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (widget.members.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Chưa có active member để tạo khoản chi.',
                style: TextStyle(color: colorScheme.onErrorContainer),
              ),
            )
          else
            ...widget.members.map(
              (member) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _participantIds.contains(member.userId),
                title: Text(_memberLabel(member)),
                subtitle: Text(member.email),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: widget.isSubmitting
                    ? null
                    : (selected) {
                        setState(() {
                          if (selected == true) {
                            _participantIds.add(member.userId);
                          } else {
                            _participantIds.remove(member.userId);
                          }
                        });
                      },
              ),
            ),
          const SizedBox(height: 12),
          InputDecorator(
            decoration: const InputDecoration(labelText: 'Split type'),
            child: const Text('EQUAL'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: widget.isSubmitting ? null : _submit,
            child: widget.isSubmitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expenseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked == null) {
      return;
    }

    setState(() => _expenseDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_participantIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cần chọn ít nhất một participant.')),
      );
      return;
    }

    if (_participantIds.length != _participantIds.toList().toSet().length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Participant không được trùng.')),
      );
      return;
    }

    final paidByUserId = _paidByUserId;
    if (paidByUserId == null || paidByUserId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cần chọn người trả tiền.')),
      );
      return;
    }

    await widget.onSubmit(
      ExpenseFormData(
        title: _titleController.text.trim(),
        description: _nullableText(_descriptionController.text),
        amount: int.parse(_amountController.text.trim()),
        paidByUserId: paidByUserId,
        participantIds: _participantIds.toList(),
        expenseDate: _expenseDate,
      ),
    );
  }

  bool _memberExists(String? userId) {
    if (userId == null) {
      return false;
    }

    return widget.members.any((member) => member.userId == userId);
  }
}

class _ExpenseDateTile extends StatelessWidget {
  const _ExpenseDateTile({
    required this.date,
    required this.enabled,
    required this.onPick,
  });

  final DateTime date;
  final bool enabled;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event_outlined),
      title: const Text('Ngày chi tiêu'),
      subtitle: Text(formatExpenseDate(date)),
      trailing: const Icon(Icons.chevron_right),
      enabled: enabled,
      onTap: onPick,
    );
  }
}

String _memberLabel(GroupMember member) {
  return member.name.trim().isEmpty ? member.email : member.name;
}

String? _nullableText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
