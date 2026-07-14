import '../models/group.dart';
import '../models/group_list_response.dart';
import '../models/group_member.dart';
import '../models/group_requests.dart';
import 'groups_api.dart';

class GroupsRepository {
  GroupsRepository(this._api);

  final GroupsApi _api;

  Future<GroupListResponse> listGroups({
    required String accessToken,
    int page = 1,
    int limit = 20,
  }) async {
    final data = await _api.listGroups(
      accessToken: accessToken,
      page: page,
      limit: limit,
    );

    return GroupListResponse.fromJson(data);
  }

  Future<Group> createGroup({
    required String accessToken,
    required String name,
    String? description,
    String? currency,
  }) async {
    final data = await _api.createGroup(
      accessToken: accessToken,
      request: CreateGroupRequest(
        name: name,
        description: description,
        currency: currency,
      ),
    );

    return Group.fromJson(data);
  }

  Future<Group> getGroup({
    required String accessToken,
    required String groupId,
  }) async {
    final data = await _api.getGroup(
      accessToken: accessToken,
      groupId: groupId,
    );

    return Group.fromJson(data);
  }

  Future<Group> updateGroup({
    required String accessToken,
    required String groupId,
    String? name,
    String? description,
    String? currency,
  }) async {
    final data = await _api.updateGroup(
      accessToken: accessToken,
      groupId: groupId,
      request: UpdateGroupRequest(
        name: name,
        description: description,
        currency: currency,
      ),
    );

    return Group.fromJson(data);
  }

  Future<String> deleteGroup({
    required String accessToken,
    required String groupId,
  }) async {
    final data = await _api.deleteGroup(
      accessToken: accessToken,
      groupId: groupId,
    );

    return (data['message'] ?? 'Đã xóa nhóm.').toString();
  }

  Future<String> leaveGroup({
    required String accessToken,
    required String groupId,
  }) async {
    final data = await _api.leaveGroup(
      accessToken: accessToken,
      groupId: groupId,
    );

    return (data['message'] ?? 'Đã rời nhóm.').toString();
  }

  Future<List<GroupMember>> listMembers({
    required String accessToken,
    required String groupId,
  }) async {
    final items = await _api.listMembers(
      accessToken: accessToken,
      groupId: groupId,
    );

    return items.map(GroupMember.fromJson).toList();
  }

  Future<GroupMember> addMember({
    required String accessToken,
    required String groupId,
    required String userId,
  }) async {
    final data = await _api.addMember(
      accessToken: accessToken,
      groupId: groupId,
      request: AddGroupMemberRequest(userId: userId),
    );

    return GroupMember.fromJson(data);
  }

  Future<String> transferOwner({
    required String accessToken,
    required String groupId,
    required String newOwnerUserId,
  }) async {
    final data = await _api.transferOwner(
      accessToken: accessToken,
      groupId: groupId,
      request: TransferGroupOwnerRequest(newOwnerUserId: newOwnerUserId),
    );

    return (data['message'] ?? 'Đã chuyển quyền chủ nhóm.').toString();
  }
}
