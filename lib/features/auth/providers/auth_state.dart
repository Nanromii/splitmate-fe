import '../models/auth_session.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  failure,
}

class AuthState {
  const AuthState._({
    required this.status,
    this.session,
    this.errorMessage,
  });

  final AuthStatus status;
  final AuthSession? session;
  final String? errorMessage;

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated =>
      status == AuthStatus.authenticated && session != null;

  factory AuthState.initial() {
    return const AuthState._(status: AuthStatus.initial);
  }

  factory AuthState.loading() {
    return const AuthState._(status: AuthStatus.loading);
  }

  factory AuthState.authenticated(AuthSession session) {
    return AuthState._(
      status: AuthStatus.authenticated,
      session: session,
    );
  }

  factory AuthState.unauthenticated() {
    return const AuthState._(status: AuthStatus.unauthenticated);
  }

  factory AuthState.failure(String message) {
    return AuthState._(
      status: AuthStatus.failure,
      errorMessage: message,
    );
  }
}