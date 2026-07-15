import 'dart:async';

import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';

class DioClient {
  const DioClient._();

  static Dio create(
    AppConfig config, {
    SecureStorageService? storage,
    void Function()? onSessionExpired,
  }) {
    final baseOptions = BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    final dio = Dio(
      baseOptions,
    );

    if (storage != null) {
      dio.interceptors.add(
        AuthTokenInterceptor(
          dio,
          Dio(baseOptions),
          storage,
          onSessionExpired: onSessionExpired,
        ),
      );
    }

    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );

    return dio;
  }
}

class AuthTokenInterceptor extends Interceptor {
  AuthTokenInterceptor(
    this._dio,
    this._refreshDio,
    this._storage, {
    this._onSessionExpired,
  });

  final Dio _dio;
  final Dio _refreshDio;
  final SecureStorageService _storage;
  final void Function()? _onSessionExpired;

  Future<String?>? _refreshFuture;

  static const _publicAuthPaths = <String>{
    '/auth/register',
    '/auth/login',
    '/auth/google/login',
    '/auth/refresh',
  };

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_shouldSkipAuth(options)) {
      handler.next(options);
      return;
    }

    final accessToken = await _storage.getAccessToken();

    if (!_isBlank(accessToken)) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final requestOptions = err.requestOptions;

    if (!_shouldRefresh(err) ||
        _shouldSkipAuth(requestOptions) ||
        requestOptions.extra['authRetry'] == true) {
      handler.next(err);
      return;
    }

    final accessToken = await _refreshAccessToken();

    if (_isBlank(accessToken)) {
      handler.next(err);
      return;
    }

    try {
      requestOptions.extra['authRetry'] = true;
      requestOptions.headers['Authorization'] = 'Bearer $accessToken';

      final response = await _dio.fetch<dynamic>(requestOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    } catch (retryError) {
      handler.next(err);
    }
  }

  bool _shouldRefresh(DioException error) {
    final statusCode = error.response?.statusCode;
    return statusCode == 401 || statusCode == 403;
  }

  bool _shouldSkipAuth(RequestOptions options) {
    if (options.extra['skipAuth'] == true) {
      return true;
    }

    return _publicAuthPaths.contains(options.path);
  }

  Future<String?> _refreshAccessToken() {
    final runningRefresh = _refreshFuture;

    if (runningRefresh != null) {
      return runningRefresh;
    }

    final refreshFuture = _doRefreshToken().whenComplete(() {
      _refreshFuture = null;
    });

    _refreshFuture = refreshFuture;
    return refreshFuture;
  }

  Future<String?> _doRefreshToken() async {
    final refreshToken = await _storage.getRefreshToken();

    if (_isBlank(refreshToken)) {
      await _expireSession();
      return null;
    }

    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {
          'refreshToken': refreshToken,
        },
        options: Options(
          extra: {
            'skipAuth': true,
          },
        ),
      );

      final data = response.data ?? <String, dynamic>{};
      final accessToken = data['accessToken']?.toString();
      final newRefreshToken = data['refreshToken']?.toString();

      if (_isBlank(accessToken) || _isBlank(newRefreshToken)) {
        await _expireSession();
        return null;
      }

      await _storage.saveAccessToken(accessToken!);
      await _storage.saveRefreshToken(newRefreshToken!);

      return accessToken;
    } catch (_) {
      await _expireSession();
      return null;
    }
  }

  Future<void> _expireSession() async {
    await _storage.clearSession();
    _onSessionExpired?.call();
  }

  bool _isBlank(String? value) {
    return value == null || value.trim().isEmpty;
  }
}
