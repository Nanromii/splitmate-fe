import 'auth_user.dart';

class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.sessionId,
    required this.expiresIn,
  });

  final AuthUser user;
  final String accessToken;
  final String refreshToken;
  final String sessionId;
  final int expiresIn;

  AuthSession copyWith({
    AuthUser? user,
    String? accessToken,
    String? refreshToken,
    String? sessionId,
    int? expiresIn,
  }) {
    return AuthSession(
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      sessionId: sessionId ?? this.sessionId,
      expiresIn: expiresIn ?? this.expiresIn,
    );
  }

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      user: AuthUser.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
      accessToken: (json['accessToken'] ?? '').toString(),
      refreshToken: (json['refreshToken'] ?? '').toString(),
      sessionId: (json['sessionId'] ?? '').toString(),
      expiresIn: int.tryParse((json['expiresIn'] ?? '0').toString()) ?? 0,
    );
  }
}