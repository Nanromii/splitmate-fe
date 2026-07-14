class PaginationMeta {
  const PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory PaginationMeta.empty() {
    return const PaginationMeta(
      page: 1,
      limit: 20,
      total: 0,
      totalPages: 0,
    );
  }

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: int.tryParse((json['page'] ?? '1').toString()) ?? 1,
      limit: int.tryParse((json['limit'] ?? '20').toString()) ?? 20,
      total: int.tryParse((json['total'] ?? '0').toString()) ?? 0,
      totalPages: int.tryParse((json['totalPages'] ?? '0').toString()) ?? 0,
    );
  }
}
