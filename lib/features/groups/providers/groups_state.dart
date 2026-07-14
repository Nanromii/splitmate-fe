import '../models/group.dart';
import '../models/group_member.dart';
import '../models/pagination_meta.dart';

class GroupListState {
  const GroupListState({
    required this.groups,
    required this.meta,
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
  });

  final List<Group> groups;
  final PaginationMeta meta;
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;

  bool get isEmpty => groups.isEmpty;

  factory GroupListState.initial() {
    return GroupListState(
      groups: const [],
      meta: PaginationMeta.empty(),
    );
  }

  GroupListState copyWith({
    List<Group>? groups,
    PaginationMeta? meta,
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GroupListState(
      groups: groups ?? this.groups,
      meta: meta ?? this.meta,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class GroupDetailState {
  const GroupDetailState({
    this.group,
    this.members = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.actionMessage,
  });

  final Group? group;
  final List<GroupMember> members;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? actionMessage;

  bool get hasGroup => group != null;
  bool get isOwner => group?.isOwner ?? false;

  factory GroupDetailState.initial() {
    return const GroupDetailState();
  }

  GroupDetailState copyWith({
    Group? group,
    List<GroupMember>? members,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? actionMessage,
    bool clearError = false,
    bool clearAction = false,
  }) {
    return GroupDetailState(
      group: group ?? this.group,
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      actionMessage: clearAction ? null : actionMessage ?? this.actionMessage,
    );
  }
}
