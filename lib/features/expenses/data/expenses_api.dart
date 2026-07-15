import 'package:dio/dio.dart';

import '../models/expense_requests.dart';

class ExpensesApi {
  ExpensesApi(this._dio);

  final Dio _dio;

  Future<List<Map<String, dynamic>>> listExpenses({
    required String groupId,
  }) async {
    final response = await _dio.get('/groups/$groupId/expenses');

    return _asMapList(response.data);
  }

  Future<Map<String, dynamic>> createExpense({
    required String groupId,
    required CreateExpenseRequest request,
  }) async {
    final response = await _dio.post(
      '/groups/$groupId/expenses',
      data: request.toJson(),
    );

    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> getExpense({
    required String groupId,
    required String expenseId,
  }) async {
    final response = await _dio.get('/groups/$groupId/expenses/$expenseId');

    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> updateExpense({
    required String groupId,
    required String expenseId,
    required UpdateExpenseRequest request,
  }) async {
    final response = await _dio.patch(
      '/groups/$groupId/expenses/$expenseId',
      data: request.toJson(),
    );

    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> deleteExpense({
    required String groupId,
    required String expenseId,
  }) async {
    final response = await _dio.delete('/groups/$groupId/expenses/$expenseId');

    return _asMap(response.data);
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception('Unexpected response format from expenses API');
  }

  List<Map<String, dynamic>> _asMapList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    throw Exception('Unexpected response format from expenses API');
  }
}
