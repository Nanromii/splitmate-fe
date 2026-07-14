import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show StateNotifierProvider;

import '../../../core/network/dio.provider.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/groups_api.dart';
import '../data/groups_repository.dart';
import 'groups_controllers.dart';
import 'groups_state.dart';

final groupsApiProvider = Provider<GroupsApi>((ref) {
  final dio = ref.watch(dioProvider);
  return GroupsApi(dio);
});

final groupsRepositoryProvider = Provider<GroupsRepository>((ref) {
  final api = ref.watch(groupsApiProvider);
  return GroupsRepository(api);
});

final groupListControllerProvider =
    StateNotifierProvider<GroupListController, GroupListState>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GroupListController(
    ref.watch(groupsRepositoryProvider),
    authState.session?.accessToken,
  );
});

final groupDetailControllerProvider = StateNotifierProvider.family<
    GroupDetailController, GroupDetailState, String>((ref, groupId) {
  final authState = ref.watch(authControllerProvider);

  return GroupDetailController(
    ref.watch(groupsRepositoryProvider),
    authState.session?.accessToken,
    groupId,
  );
});
