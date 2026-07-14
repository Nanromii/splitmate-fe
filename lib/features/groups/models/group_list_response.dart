import 'group.dart';
import 'pagination_meta.dart';

class GroupListResponse {
  const GroupListResponse({
    required this.items,
    required this.meta,
  });

  final List<Group> items;
  final PaginationMeta meta;

  factory GroupListResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final rawMeta = json['meta'];

    return GroupListResponse(
      items: rawItems is List
          ? rawItems
              .whereType<Map>()
              .map((item) => Group.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : const [],
      meta: rawMeta is Map
          ? PaginationMeta.fromJson(Map<String, dynamic>.from(rawMeta))
          : PaginationMeta.empty(),
    );
  }
}
