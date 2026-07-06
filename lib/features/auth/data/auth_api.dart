import 'package:dio/dio.dart';

import '../models/google_login_request.dart';
import '../models/login_request.dart';
import '../models/refresh_token_request.dart';
import '../models/register_request.dart';

class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> register(
    RegisterRequest request,
  ) async {
    final response = await _dio.post(
      '/auth/register',
      data: request.toJson(),
    );

    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> login(
    LoginRequest request,
  ) async {
    final response = await _dio.post(
      '/auth/login',
      data: request.toJson(),
    );

    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> loginWithGoogle(
    GoogleLoginRequest request,
  ) async {
    final response = await _dio.post(
      '/auth/google/login',
      data: request.toJson(),
    );

    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> refresh(
    RefreshTokenRequest request,
  ) async {
    final response = await _dio.post(
      '/auth/refresh',
      data: request.toJson(),
    );

    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> me(String accessToken) async {
    final response = await _dio.get(
      '/auth/me',
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );

    return _asMap(response.data);
  }

  Future<void> logout(String accessToken) async {
    await _dio.post(
      '/auth/logout',
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception('Unexpected response format from auth API');
  }
}
