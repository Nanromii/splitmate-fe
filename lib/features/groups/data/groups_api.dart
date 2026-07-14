import 'package:dio/dio.dart';

import '../models/group_requests.dart';

class GroupsApi {
  GroupsApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> listGroups({
    required String accessToken,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/groups',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
      options: _authOptions(accessToken),
    );

    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> createGroup({
    required String accessToken,
    required CreateGroupRequest request,
  }) async {
    final response = await _dio.post(
      '/groups',
      data: request.toJson(),
      options: _authOptions(accessToken),
    );

    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> getGroup({
    required String accessToken,
    required String groupId,
  }) async {
    final response = await _dio.get(
      '/groups/$groupId',
      options: _authOptions(accessToken),
    );

    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> updateGroup({
    required String accessToken,
    required String groupId,
    required UpdateGroupRequest request,
  }) async {
    final response = await _dio.patch(
      '/groups/$groupId',
      data: request.toJson(),
      options: _authOptions(accessToken),
    );

    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> deleteGroup({
    required String accessToken,
    required String groupId,
  }) async {
    final response = await _dio.delete(
      '/groups/$groupId',
      options: _authOptions(accessToken),
    );

    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> leaveGroup({
    required String accessToken,
    required String groupId,
  }) async {
    final response = await _dio.post(
      '/groups/$groupId/leave',
      options: _authOptions(accessToken),
    );

    return _asMap(response.data);
  }

  Future<List<Map<String, dynamic>>> listMembers({
    required String accessToken,
    required String groupId,
  }) async {
    final response = await _dio.get(
      '/groups/$groupId/members',
      options: _authOptions(accessToken),
    );

    return _asMapList(response.data);
  }

  Future<Map<String, dynamic>> addMember({
    required String accessToken,
    required String groupId,
    required AddGroupMemberRequest request,
  }) async {
    final response = await _dio.post(
      '/groups/$groupId/members',
      data: request.toJson(),
      options: _authOptions(accessToken),
    );

    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> transferOwner({
    required String accessToken,
    required String groupId,
    required TransferGroupOwnerRequest request,
  }) async {
    final response = await _dio.post(
      '/groups/$groupId/transfer-owner',
      data: request.toJson(),
      options: _authOptions(accessToken),
    );

    return _asMap(response.data);
  }

  Options _authOptions(String accessToken) {
    return Options(
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception('Unexpected response format from groups API');
  }

  List<Map<String, dynamic>> _asMapList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    throw Exception('Unexpected response format from groups API');
  }
}
