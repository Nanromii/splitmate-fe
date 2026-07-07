import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../providers/auth_state.dart';

enum _AuthMode {
  login,
  register,
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();

  _AuthMode _mode = _AuthMode.login;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 72,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'SplitMate',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _mode == _AuthMode.login
                        ? 'Đăng nhập bằng tài khoản hoặc Google.'
                        : 'Tạo tài khoản mới để bắt đầu sử dụng.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SegmentedButton<_AuthMode>(
                    segments: const [
                      ButtonSegment<_AuthMode>(
                        value: _AuthMode.login,
                        label: Text('Đăng nhập'),
                        icon: Icon(Icons.login),
                      ),
                      ButtonSegment<_AuthMode>(
                        value: _AuthMode.register,
                        label: Text('Đăng ký'),
                        icon: Icon(Icons.person_add_alt_1),
                      ),
                    ],
                    selected: {_mode},
                    onSelectionChanged: isLoading
                        ? null
                        : (selection) {
                            setState(() {
                              _mode = selection.first;
                            });
                          },
                  ),
                  const SizedBox(height: 24),
                  if (_mode == _AuthMode.register) ...[
                    TextFormField(
                      controller: _displayNameController,
                      enabled: !isLoading,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Tên hiển thị',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (_mode == _AuthMode.register &&
                            (value == null || value.trim().isEmpty)) {
                          return 'Vui lòng nhập tên hiển thị.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _emailController,
                    enabled: !isLoading,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';

                      if (email.isEmpty) {
                        return 'Vui lòng nhập email.';
                      }

                      if (!email.contains('@') || !email.contains('.')) {
                        return 'Email không hợp lệ.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    enabled: !isLoading,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu',
                      border: OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (_) => _submit(),
                    validator: (value) {
                      final password = value ?? '';

                      if (password.isEmpty) {
                        return 'Vui lòng nhập mật khẩu.';
                      }

                      if (_mode == _AuthMode.register && password.length < 8) {
                        return 'Mật khẩu phải có ít nhất 8 ký tự.';
                      }

                      return null;
                    },
                  ),
                  if (authState.status == AuthStatus.failure &&
                      authState.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      authState.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: isLoading ? null : _submit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        isLoading
                            ? 'Đang xử lý...'
                            : _mode == _AuthMode.login
                                ? 'Đăng nhập'
                                : 'Tạo tài khoản',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'hoặc',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () {
                            ref
                                .read(authControllerProvider.notifier)
                                .signInWithGoogle();
                          },
                    icon: const Icon(Icons.g_mobiledata),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Tiếp tục với Google'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = ref.read(authControllerProvider.notifier);

    if (_mode == _AuthMode.login) {
      await controller.loginWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      return;
    }

    await controller.registerWithPassword(
      email: _emailController.text,
      displayName: _displayNameController.text,
      password: _passwordController.text,
    );
  }
}
