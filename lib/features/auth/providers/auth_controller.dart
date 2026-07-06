import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart' show StateNotifier;
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/storage/secure_storage_service.dart';
import '../data/auth_repository.dart';
import '../models/auth_session.dart';
import 'auth_state.dart';

class AuthController extends StateNotifier<AuthState> {
  AuthController({
    required this._repository,
    required this._storage,
    required this._googleSignIn,
    required this._googleServerClientId,
  }) : super(AuthState.initial()) {
    Future<void>.microtask(bootstrap);
  }

  final AuthRepository _repository;
  final SecureStorageService _storage;
  final GoogleSignIn _googleSignIn;
  final String _googleServerClientId;

  bool _googleInitialized = false;

  Future<void> bootstrap() async {
    state = AuthState.loading();

    final accessToken = await _storage.getAccessToken();
    final refreshToken = await _storage.getRefreshToken();

    if (_isBlank(accessToken) || _isBlank(refreshToken)) {
      await _clearLocalSession();
      state = AuthState.unauthenticated();
      return;
    }

    try {
      final user = await _repository.getMe(accessToken!);

      state = AuthState.authenticated(
        AuthSession(
          user: user,
          accessToken: accessToken,
          refreshToken: refreshToken!,
          sessionId: '',
          expiresIn: 0,
        ),
      );
    } catch (error) {
      if (_isUnauthorized(error)) {
        await _tryRefresh(refreshToken!);
        return;
      }

      state = AuthState.failure(
        _readableMessage(
          error,
          fallback: 'Không thể kiểm tra phiên đăng nhập hiện tại.',
        ),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = AuthState.loading();

    try {
      await _ensureGoogleInitialized();

      if (!_googleSignIn.supportsAuthenticate()) {
        state = AuthState.failure(
          'Nền tảng hiện tại không hỗ trợ Google authenticate theo flow này.',
        );
        return;
      }

      final account = await _googleSignIn.authenticate();
      final authentication = account.authentication;
      final idToken = authentication.idToken;

      if (_isBlank(idToken)) {
        state = AuthState.failure('Google không trả về ID token hợp lệ.');
        return;
      }

      final session = await _repository.loginWithGoogle(
        idToken: idToken!,
      );

      await _persistSession(session);
      state = AuthState.authenticated(session);
    } on GoogleSignInException catch (error) {
      state = AuthState.failure(_googleErrorMessage(error));
    } catch (error) {
      state = AuthState.failure(
        _readableMessage(
          error,
          fallback: 'Đăng nhập Google thất bại.',
        ),
      );
    }
  }

  Future<void> loginWithPassword({
    required String email,
    required String password,
  }) async {
    state = AuthState.loading();

    try {
      final session = await _repository.login(
        email: email.trim(),
        password: password,
      );

      await _persistSession(session);
      state = AuthState.authenticated(session);
    } catch (error) {
      state = AuthState.failure(
        _readableMessage(
          error,
          fallback: 'Đăng nhập bằng tài khoản thất bại.',
        ),
      );
    }
  }

  Future<void> registerWithPassword({
    required String email,
    required String displayName,
    required String password,
  }) async {
    state = AuthState.loading();

    try {
      final session = await _repository.register(
        email: email.trim(),
        displayName: displayName.trim(),
        password: password,
      );

      await _persistSession(session);
      state = AuthState.authenticated(session);
    } catch (error) {
      state = AuthState.failure(
        _readableMessage(
          error,
          fallback: 'Đăng ký tài khoản thất bại.',
        ),
      );
    }
  }

  Future<void> logout() async {
    final currentSession = state.session;
    state = AuthState.loading();

    try {
      final accessToken = currentSession?.accessToken;

      if (!_isBlank(accessToken)) {
        await _repository.logout(accessToken!);
      }
    } catch (_) {
      // Backend logout lỗi thì vẫn phải xóa session local.
    } finally {
      await _clearLocalSession();

      try {
        await _ensureGoogleInitialized();
        await _googleSignIn.signOut();
      } catch (_) {}

      state = AuthState.unauthenticated();
    }
  }

  Future<void> _tryRefresh(String refreshToken) async {
    try {
      final refreshedSession = await _repository.refresh(
        refreshToken: refreshToken,
      );

      await _persistSession(refreshedSession);

      final user = await _repository.getMe(refreshedSession.accessToken);

      state = AuthState.authenticated(
        refreshedSession.copyWith(user: user),
      );
    } catch (error) {
      if (_isUnauthorized(error)) {
        await _clearLocalSession();
        state = AuthState.unauthenticated();
        return;
      }

      state = AuthState.failure(
        _readableMessage(
          error,
          fallback: 'Không thể làm mới phiên đăng nhập.',
        ),
      );
    }
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) {
      return;
    }

    await _googleSignIn.initialize(
      serverClientId: _googleServerClientId,
    );

    _googleInitialized = true;
  }

  Future<void> _persistSession(AuthSession session) async {
    await _storage.saveAccessToken(session.accessToken);
    await _storage.saveRefreshToken(session.refreshToken);
  }

  Future<void> _clearLocalSession() {
    return _storage.clearSession();
  }

  bool _isUnauthorized(Object error) {
    return error is DioException &&
        (error.response?.statusCode == 401 || error.response?.statusCode == 403);
  }

  bool _isBlank(String? value) {
    return value == null || value.trim().isEmpty;
  }

  String _googleErrorMessage(GoogleSignInException error) {
    switch (error.code) {
      case GoogleSignInExceptionCode.canceled:
        return 'Bạn đã hủy đăng nhập Google.';
      default:
        return error.description ?? 'Đăng nhập Google thất bại.';
    }
  }

  String _readableMessage(
    Object error, {
    required String fallback,
  }) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }

      return fallback;
    }

    return error.toString().replaceFirst('Exception: ', '');
  }
}
