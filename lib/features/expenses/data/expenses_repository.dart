import '../models/expense.dart';
import '../models/expense_requests.dart';
import 'expenses_api.dart';

class ExpensesRepository {
  ExpensesRepository(this._api);

  final ExpensesApi _api;

  Future<List<Expense>> listExpenses({
    required String groupId,
  }) async {
    final items = await _api.listExpenses(
      groupId: groupId,
    );

    return items.map(Expense.fromJson).toList();
  }

  Future<Expense> createExpense({
    required String groupId,
    required String title,
    required int amount,
    required String paidByUserId,
    required List<String> participantIds,
    String? description,
    DateTime? expenseDate,
  }) async {
    final data = await _api.createExpense(
      groupId: groupId,
      request: CreateExpenseRequest(
        title: title,
        description: description,
        amount: amount,
        paidByUserId: paidByUserId,
        participantIds: participantIds,
        expenseDate: expenseDate,
      ),
    );

    return Expense.fromJson(data);
  }

  Future<Expense> getExpense({
    required String groupId,
    required String expenseId,
  }) async {
    final data = await _api.getExpense(
      groupId: groupId,
      expenseId: expenseId,
    );

    return Expense.fromJson(data);
  }

  Future<Expense> updateExpense({
    required String groupId,
    required String expenseId,
    required String title,
    required int amount,
    required String paidByUserId,
    required List<String> participantIds,
    String? description,
    DateTime? expenseDate,
  }) async {
    final data = await _api.updateExpense(
      groupId: groupId,
      expenseId: expenseId,
      request: UpdateExpenseRequest(
        title: title,
        description: description,
        amount: amount,
        paidByUserId: paidByUserId,
        participantIds: participantIds,
        expenseDate: expenseDate,
      ),
    );

    return Expense.fromJson(data);
  }

  Future<String> deleteExpense({
    required String groupId,
    required String expenseId,
  }) async {
    final data = await _api.deleteExpense(
      groupId: groupId,
      expenseId: expenseId,
    );

    return (data['message'] ?? 'Đã xóa khoản chi.').toString();
  }
}
