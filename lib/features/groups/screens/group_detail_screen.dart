import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../models/group_member.dart';
import '../providers/groups_providers.dart';
import '../widgets/group_member_tile.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  const GroupDetailScreen({
    required this.groupId,
    super.key,
  });

  final String groupId;

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
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
      final action = next.actionMessage;

      if (action != null && action != previous?.actionMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(action)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(group?.name ?? 'Chi tiết nhóm'),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed:
                state.isLoading ? null : () => ref.read(provider.notifier).load(),
            icon: const Icon(Icons.refresh),
          ),
          if (state.isOwner)
            IconButton(
              tooltip: 'Sửa nhóm',
              onPressed: state.isSaving
                  ? null
                  : () async {
                      final changed = await context.push<bool>(
                        AppRoutes.groupEdit(widget.groupId),
                      );

                      if (changed == true) {
                        ref.read(provider.notifier).load();
                        ref
                            .read(groupListControllerProvider.notifier)
                            .load(refresh: true);
                      }
                    },
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading && group == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (group == null) {
            return _DetailErrorState(
              message: state.errorMessage ?? 'Không tìm thấy nhóm.',
              onRetry: () => ref.read(provider.notifier).load(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(provider.notifier).load(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                _GroupHeader(
                  name: group.name,
                  description: group.description,
                  currency: group.currency,
                  role: group.role?.value ?? 'Cần xác nhận',
                  ownerId: group.ownerId,
                ),
                const SizedBox(height: 20),
                _ActionPanel(
                  isOwner: state.isOwner,
                  isSaving: state.isSaving,
                  onAddMember: _showAddMemberDialog,
                  onDelete: () => _confirmAndRun(
                    title: 'Xóa nhóm?',
                    message:
                        'Backend sẽ xóa mềm nhóm này. Hành động này chỉ dành cho owner.',
                    actionLabel: 'Xóa nhóm',
                    action: ref.read(provider.notifier).deleteGroup,
                    onSuccess: () {
                      ref
                          .read(groupListControllerProvider.notifier)
                          .load(refresh: true);
                      context.go(AppRoutes.groups);
                    },
                  ),
                  onLeave: () => _confirmAndRun(
                    title: 'Rời nhóm?',
                    message:
                        'Owner cần chuyển quyền sở hữu trước khi rời nhóm.',
                    actionLabel: 'Rời nhóm',
                    action: ref.read(provider.notifier).leaveGroup,
                    onSuccess: () {
                      ref
                          .read(groupListControllerProvider.notifier)
                          .load(refresh: true);
                      context.go(AppRoutes.groups);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                _MembersSection(
                  members: state.members,
                  isOwner: state.isOwner,
                  onTransferOwner: (member) => _confirmAndRun(
                    title: 'Chuyển quyền chủ nhóm?',
                    message:
                        'Quyền owner sẽ được chuyển cho ${member.name.isEmpty ? member.email : member.name}.',
                    actionLabel: 'Chuyển quyền',
                    action: () {
                      return ref
                          .read(provider.notifier)
                          .transferOwner(member.userId);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                _PhaseSixHint(currency: group.currency),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAddMemberDialog() async {
    final provider = groupDetailControllerProvider(widget.groupId);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return _AddMemberDialog(
          onSubmit: (email) async {
            final success = await ref.read(provider.notifier).addMember(email);

            if (success) {
              return null;
            }

            return _friendlyAddMemberError(ref.read(provider).errorMessage);
          },
        );
      },
    );
  }

  Future<void> _confirmAndRun({
    required String title,
    required String message,
    required String actionLabel,
    required Future<bool> Function() action,
    VoidCallback? onSuccess,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(actionLabel),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final success = await action();

    if (success && mounted) {
      onSuccess?.call();
    }
  }
}

class _AddMemberDialog extends StatefulWidget {
  const _AddMemberDialog({
    required this.onSubmit,
  });

  final Future<String?> Function(String email) onSubmit;

  @override
  State<_AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<_AddMemberDialog> {
  final _controller = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm thành viên'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Email thành viên',
              hintText: 'member@example.com',
            ),
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            enabled: !_isSubmitting,
            onChanged: (_) {
              if (_errorMessage != null) {
                setState(() => _errorMessage = null);
              }
            },
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            _DialogErrorMessage(
              message: _errorMessage!,
              onClose: () => setState(() => _errorMessage = null),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Thêm'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final email = _controller.text.trim();

    if (!_isValidEmail(email)) {
      setState(() => _errorMessage = 'Email thành viên chưa hợp lệ.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final errorMessage = await widget.onSubmit(email);

    if (!mounted) {
      return;
    }

    if (errorMessage == null) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isSubmitting = false;
      _errorMessage = errorMessage;
    });
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
  }
}

class _DialogErrorMessage extends StatelessWidget {
  const _DialogErrorMessage({
    required this.message,
    required this.onClose,
  });

  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.error_outline,
                color: colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: colorScheme.onErrorContainer),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onClose,
              child: const Text('Đóng'),
            ),
          ),
        ],
      ),
    );
  }
}

String _friendlyAddMemberError(String? message) {
  if (message == null || message.trim().isEmpty) {
    return 'Người dùng không tồn tại.';
  }

  final normalized = message.toLowerCase();

  if (normalized.contains('không tìm thấy người dùng')) {
    return 'Người dùng không tồn tại.';
  }

  return message;
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.name,
    required this.currency,
    required this.role,
    required this.ownerId,
    this.description,
  });

  final String name;
  final String? description;
  final String currency;
  final String role;
  final String? ownerId;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.groups_outlined, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
            if (description != null && description!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(description!),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(currency)),
                Chip(label: Text(role)),
                if (ownerId != null && ownerId!.trim().isNotEmpty)
                  Chip(label: Text('Owner ID: $ownerId')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({
    required this.isOwner,
    required this.isSaving,
    required this.onAddMember,
    required this.onDelete,
    required this.onLeave,
  });

  final bool isOwner;
  final bool isSaving;
  final VoidCallback onAddMember;
  final VoidCallback onDelete;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            if (isOwner) ...[
              ListTile(
                leading: const Icon(Icons.person_add_alt_outlined),
                title: const Text('Thêm thành viên'),
                subtitle: const Text('Nhập email tài khoản SplitMate.'),
                enabled: !isSaving,
                onTap: onAddMember,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Xóa nhóm'),
                subtitle: const Text('Chỉ owner được xóa mềm nhóm.'),
                enabled: !isSaving,
                onTap: onDelete,
              ),
            ] else
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Rời nhóm'),
                subtitle: const Text('Owner cần chuyển quyền trước khi rời.'),
                enabled: !isSaving,
                onTap: onLeave,
              ),
          ],
        ),
      ),
    );
  }
}

class _MembersSection extends StatelessWidget {
  const _MembersSection({
    required this.members,
    required this.isOwner,
    required this.onTransferOwner,
  });

  final List<GroupMember> members;
  final bool isOwner;
  final void Function(GroupMember member) onTransferOwner;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Members',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (members.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Chưa có dữ liệu thành viên.'),
              )
            else
              ...members.map(
                (member) => GroupMemberTile(
                  member: member,
                  canTransferOwner: isOwner && !member.isOwner,
                  onTransferOwner: () => onTransferOwner(member),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PhaseSixHint extends StatelessWidget {
  const _PhaseSixHint({
    required this.currency,
  });

  final String currency;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: const Icon(Icons.receipt_long_outlined),
        title: const Text('Expenses'),
        subtitle: Text(
          'Phase 6 sẽ dùng nhóm này làm ngữ cảnh tạo chi tiêu bằng $currency.',
        ),
      ),
    );
  }
}

class _DetailErrorState extends StatelessWidget {
  const _DetailErrorState({
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
