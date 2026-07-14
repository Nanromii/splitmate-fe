class CreateExpenseRequest {
  const CreateExpenseRequest({
    required this.title,
    required this.amount,
    required this.paidByUserId,
    required this.participantIds,
    this.description,
    this.expenseDate,
    this.splitType = 'EQUAL',
  });

  final String title;
  final String? description;
  final int amount;
  final String paidByUserId;
  final List<String> participantIds;
  final DateTime? expenseDate;
  final String splitType;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (description != null) 'description': description,
      'amount': amount,
      'paidByUserId': paidByUserId,
      'participantIds': participantIds,
      if (expenseDate != null) 'expenseDate': expenseDate!.toUtc().toIso8601String(),
      'splitType': splitType,
    };
  }
}

class UpdateExpenseRequest {
  const UpdateExpenseRequest({
    this.title,
    this.description,
    this.amount,
    this.paidByUserId,
    this.participantIds,
    this.expenseDate,
    this.splitType = 'EQUAL',
  });

  final String? title;
  final String? description;
  final int? amount;
  final String? paidByUserId;
  final List<String>? participantIds;
  final DateTime? expenseDate;
  final String? splitType;

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (amount != null) 'amount': amount,
      if (paidByUserId != null) 'paidByUserId': paidByUserId,
      if (participantIds != null) 'participantIds': participantIds,
      if (expenseDate != null) 'expenseDate': expenseDate!.toUtc().toIso8601String(),
      if (splitType != null) 'splitType': splitType,
    };
  }
}
