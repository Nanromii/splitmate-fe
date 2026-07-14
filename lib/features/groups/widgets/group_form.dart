import 'package:flutter/material.dart';

const groupCurrencies = ['VND', 'USD', 'EUR'];

class GroupFormData {
  const GroupFormData({
    required this.name,
    required this.currency,
    this.description,
  });

  final String name;
  final String? description;
  final String currency;
}

class GroupForm extends StatefulWidget {
  const GroupForm({
    required this.submitLabel,
    required this.onSubmit,
    this.initialName = '',
    this.initialDescription,
    this.initialCurrency = 'VND',
    this.isSubmitting = false,
    super.key,
  });

  final String initialName;
  final String? initialDescription;
  final String initialCurrency;
  final String submitLabel;
  final bool isSubmitting;
  final Future<void> Function(GroupFormData data) onSubmit;

  @override
  State<GroupForm> createState() => _GroupFormState();
}

class _GroupFormState extends State<GroupForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late String _currency;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController = TextEditingController(
      text: widget.initialDescription ?? '',
    );
    _currency = groupCurrencies.contains(widget.initialCurrency)
        ? widget.initialCurrency
        : 'VND';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            enabled: !widget.isSubmitting,
            decoration: const InputDecoration(
              labelText: 'Tên nhóm',
              prefixIcon: Icon(Icons.groups_outlined),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập tên nhóm.';
              }

              if (value.trim().length > 255) {
                return 'Tên nhóm tối đa 255 ký tự.';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            enabled: !widget.isSubmitting,
            decoration: const InputDecoration(
              labelText: 'Mô tả',
              prefixIcon: Icon(Icons.notes_outlined),
            ),
            minLines: 2,
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _currency,
            decoration: const InputDecoration(
              labelText: 'Tiền tệ',
              prefixIcon: Icon(Icons.payments_outlined),
            ),
            items: groupCurrencies
                .map(
                  (currency) => DropdownMenuItem(
                    value: currency,
                    child: Text(currency),
                  ),
                )
                .toList(),
            onChanged: widget.isSubmitting
                ? null
                : (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() => _currency = value);
                  },
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: widget.isSubmitting ? null : _submit,
            icon: widget.isSubmitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final description = _descriptionController.text.trim();

    await widget.onSubmit(
      GroupFormData(
        name: _nameController.text.trim(),
        description: description.isEmpty ? null : description,
        currency: _currency,
      ),
    );
  }
}
