import '../models/auth_session.dart';
import '../models/auth_user.dart';
import '../models/google_login_request.dart';
import '../models/login_request.dart';
import '../models/refresh_token_request.dart';
import '../models/register_request.dart';
import 'auth_api.dart';

class AuthRepository {
  AuthRepository(this._api);

  final AuthApi _api;

  Future<AuthSession> register({
    required String email,
    required String displayName,
    required String password,
    String? deviceId,
    String? deviceName,
  }) async {
    final data = await _api.register(
      RegisterRequest(
        email: email,
        displayName: displayName,
        password: password,
        deviceId: deviceId,
        deviceName: deviceName,
      ),
    );

    return AuthSession.fromJson(data);
  }

  Future<AuthSession> login({
    required String email,
    required String password,
    String? deviceId,
    String? deviceName,
  }) async {
    final data = await _api.login(
      LoginRequest(
        email: email,
        password: password,
        deviceId: deviceId,
        deviceName: deviceName,
      ),
    );

    return AuthSession.fromJson(data);
  }

  Future<AuthSession> loginWithGoogle({
    required String idToken,
    String? deviceId,
    String? deviceName,
  }) async {
    final data = await _api.loginWithGoogle(
      GoogleLoginRequest(
        idToken: idToken,
        deviceId: deviceId,
        deviceName: deviceName,
      ),
    );

    return AuthSession.fromJson(data);
  }

  Future<AuthSession> refresh({
    required String refreshToken,
  }) async {
    final data = await _api.refresh(
      RefreshTokenRequest(refreshToken: refreshToken),
    );

    return AuthSession.fromJson(data);
  }

  Future<AuthUser> getMe(String accessToken) async {
    final data = await _api.me(accessToken);
    return AuthUser.fromJson(data);
  }

  Future<void> logout(String accessToken) {
    return _api.logout(accessToken);
  }
}
