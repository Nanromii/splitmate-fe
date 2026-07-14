enum ExpenseSplitType {
  equal('EQUAL');

  const ExpenseSplitType(this.value);

  final String value;

  static ExpenseSplitType? fromJson(Object? value) {
    final text = value?.toString();

    for (final type in ExpenseSplitType.values) {
      if (type.value == text) {
        return type;
      }
    }

    return null;
  }
}

class ExpenseUser {
  const ExpenseUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  factory ExpenseUser.fromJson(Map<String, dynamic> json) {
    return ExpenseUser(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }
}

class ExpenseSplit {
  const ExpenseSplit({
    required this.splitId,
    required this.userId,
    required this.user,
    required this.amount,
  });

  final String splitId;
  final String userId;
  final ExpenseUser user;
  final int amount;

  factory ExpenseSplit.fromJson(Map<String, dynamic> json) {
    return ExpenseSplit(
      splitId: (json['splitId'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      user: ExpenseUser.fromJson(_asMap(json['user'])),
      amount: _asInt(json['amount']),
    );
  }
}

class Expense {
  const Expense({
    required this.id,
    required this.groupId,
    required this.title,
    required this.amount,
    required this.currency,
    required this.paidByUserId,
    required this.participantCount,
    required this.splits,
    this.description,
    this.splitType,
    this.paidByUser,
    this.expenseDate,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String groupId;
  final String title;
  final String? description;
  final int amount;
  final String currency;
  final ExpenseSplitType? splitType;
  final String paidByUserId;
  final ExpenseUser? paidByUser;
  final int participantCount;
  final DateTime? expenseDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ExpenseSplit> splits;

  bool get hasSplits => splits.isNotEmpty;

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: (json['id'] ?? '').toString(),
      groupId: (json['groupId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      amount: _asInt(json['amount']),
      currency: (json['currency'] ?? '').toString(),
      splitType: ExpenseSplitType.fromJson(json['splitType']),
      paidByUserId: (json['paidByUserId'] ?? '').toString(),
      paidByUser: json['paidByUser'] == null
          ? null
          : ExpenseUser.fromJson(_asMap(json['paidByUser'])),
      participantCount: _asInt(json['participantCount']),
      expenseDate: DateTime.tryParse((json['expenseDate'] ?? '').toString()),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()),
      splits: _asMapList(json['splits']).map(ExpenseSplit.fromJson).toList(),
    );
  }
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return const {};
}

List<Map<String, dynamic>> _asMapList(Object? value) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  return const [];
}

int _asInt(Object? value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse((value ?? '0').toString()) ?? 0;
}
