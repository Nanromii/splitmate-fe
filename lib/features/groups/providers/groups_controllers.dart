import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart' show StateNotifier;

import '../data/groups_repository.dart';
import '../models/group.dart';
import 'groups_state.dart';

class GroupListController extends StateNotifier<GroupListState> {
  GroupListController(
    this._repository,
    this._accessToken,
  ) : super(GroupListState.initial());

  final GroupsRepository _repository;
  final String? _accessToken;

  Future<void> load({bool refresh = false}) async {
    final token = _requireAccessToken();

    if (token == null) {
      return;
    }

    state = state.copyWith(
      isLoading: !refresh,
      isRefreshing: refresh,
      clearError: true,
    );

    try {
      final result = await _repository.listGroups(accessToken: token);

      state = state.copyWith(
        groups: result.items,
        meta: result.meta,
        isLoading: false,
        isRefreshing: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        errorMessage: _readableMessage(
          error,
          fallback: 'Không thể tải danh sách nhóm.',
        ),
      );
    }
  }

  Future<Group?> createGroup({
    required String name,
    String? description,
    String? currency,
  }) async {
    final token = _requireAccessToken();

    if (token == null) {
      return null;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final group = await _repository.createGroup(
        accessToken: token,
        name: name,
        description: description,
        currency: currency,
      );

      await load(refresh: true);
      return group;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _readableMessage(
          error,
          fallback: 'Không thể tạo nhóm.',
        ),
      );
      return null;
    }
  }

  String? _requireAccessToken() {
    if (_accessToken == null || _accessToken.trim().isEmpty) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        errorMessage: 'Bạn cần đăng nhập lại để tải dữ liệu nhóm.',
      );
      return null;
    }

    return _accessToken;
  }
}

class GroupDetailController extends StateNotifier<GroupDetailState> {
  GroupDetailController(
    this._repository,
    this._accessToken,
    this._groupId,
  ) : super(GroupDetailState.initial());

  final GroupsRepository _repository;
  final String? _accessToken;
  final String _groupId;

  Future<void> load() async {
    final token = _requireAccessToken();

    if (token == null) {
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearAction: true,
    );

    try {
      final group = await _repository.getGroup(
        accessToken: token,
        groupId: _groupId,
      );
      final members = await _repository.listMembers(
        accessToken: token,
        groupId: _groupId,
      );

      state = state.copyWith(
        group: group,
        members: members,
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _readableMessage(
          error,
          fallback: 'Không thể tải chi tiết nhóm.',
        ),
      );
    }
  }

  Future<bool> updateGroup({
    required String name,
    String? description,
    String? currency,
  }) async {
    final token = _requireAccessToken();

    if (token == null) {
      return false;
    }

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final group = await _repository.updateGroup(
        accessToken: token,
        groupId: _groupId,
        name: name,
        description: description,
        currency: currency,
      );

      state = state.copyWith(
        group: group,
        isSaving: false,
        actionMessage: 'Đã cập nhật nhóm.',
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: _readableMessage(
          error,
          fallback: 'Không thể cập nhật nhóm.',
        ),
      );
      return false;
    }
  }

  Future<bool> deleteGroup() async {
    final token = _requireAccessToken();

    if (token == null) {
      return false;
    }

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final message = await _repository.deleteGroup(
        accessToken: token,
        groupId: _groupId,
      );

      state = state.copyWith(
        isSaving: false,
        actionMessage: message,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: _readableMessage(
          error,
          fallback: 'Không thể xóa nhóm.',
        ),
      );
      return false;
    }
  }

  Future<bool> leaveGroup() async {
    final token = _requireAccessToken();

    if (token == null) {
      return false;
    }

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final message = await _repository.leaveGroup(
        accessToken: token,
        groupId: _groupId,
      );

      state = state.copyWith(
        isSaving: false,
        actionMessage: message,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: _readableMessage(
          error,
          fallback: 'Không thể rời nhóm.',
        ),
      );
      return false;
    }
  }

  Future<bool> addMember(String userId) async {
    final token = _requireAccessToken();

    if (token == null) {
      return false;
    }

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      await _repository.addMember(
        accessToken: token,
        groupId: _groupId,
        userId: userId,
      );

      final members = await _repository.listMembers(
        accessToken: token,
        groupId: _groupId,
      );

      state = state.copyWith(
        members: members,
        isSaving: false,
        actionMessage: 'Đã thêm thành viên.',
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: _readableMessage(
          error,
          fallback: 'Không thể thêm thành viên.',
        ),
      );
      return false;
    }
  }

  Future<bool> transferOwner(String newOwnerUserId) async {
    final token = _requireAccessToken();

    if (token == null) {
      return false;
    }

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final message = await _repository.transferOwner(
        accessToken: token,
        groupId: _groupId,
        newOwnerUserId: newOwnerUserId,
      );

      await load();
      state = state.copyWith(
        isSaving: false,
        actionMessage: message,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: _readableMessage(
          error,
          fallback: 'Không thể chuyển quyền chủ nhóm.',
        ),
      );
      return false;
    }
  }

  String? _requireAccessToken() {
    if (_accessToken == null || _accessToken.trim().isEmpty) {
      state = state.copyWith(
        isLoading: false,
        isSaving: false,
        errorMessage: 'Bạn cần đăng nhập lại để thao tác với nhóm.',
      );
      return null;
    }

    return _accessToken;
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
