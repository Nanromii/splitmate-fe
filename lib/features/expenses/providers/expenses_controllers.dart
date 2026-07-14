import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart' show StateNotifier;

import '../data/expenses_repository.dart';
import '../models/expense.dart';
import 'expenses_state.dart';

class ExpenseListController extends StateNotifier<ExpenseListState> {
  ExpenseListController(
    this._repository,
    this._accessToken,
    this._groupId,
  ) : super(ExpenseListState.initial());

  final ExpensesRepository _repository;
  final String? _accessToken;
  final String _groupId;

  Future<void> load({bool refresh = false}) async {
    final token = _requireAccessToken();

    if (token == null) {
      return;
    }

    state = state.copyWith(
      isLoading: !refresh,
      isRefreshing: refresh,
      clearError: true,
      clearAction: true,
    );

    try {
      final expenses = await _repository.listExpenses(
        accessToken: token,
        groupId: _groupId,
      );

      state = state.copyWith(
        expenses: expenses,
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
          fallback: 'Không thể tải danh sách khoản chi.',
        ),
      );
    }
  }

  Future<Expense?> createExpense({
    required String title,
    required int amount,
    required String paidByUserId,
    required List<String> participantIds,
    String? description,
    DateTime? expenseDate,
  }) async {
    final token = _requireAccessToken();

    if (token == null) {
      return null;
    }

    state = state.copyWith(
      isSaving: true,
      clearError: true,
      clearAction: true,
    );

    try {
      final expense = await _repository.createExpense(
        accessToken: token,
        groupId: _groupId,
        title: title,
        description: description,
        amount: amount,
        paidByUserId: paidByUserId,
        participantIds: participantIds,
        expenseDate: expenseDate,
      );

      await load(refresh: true);
      state = state.copyWith(
        isSaving: false,
        actionMessage: 'Đã tạo khoản chi.',
      );
      return expense;
    } catch (error) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: _readableMessage(
          error,
          fallback: 'Không thể tạo khoản chi.',
        ),
        clearAction: true,
      );
      return null;
    }
  }

  String? _requireAccessToken() {
    if (_accessToken == null || _accessToken.trim().isEmpty) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        isSaving: false,
        errorMessage: 'Bạn cần đăng nhập lại để tải khoản chi.',
      );
      return null;
    }

    return _accessToken;
  }
}

class ExpenseDetailController extends StateNotifier<ExpenseDetailState> {
  ExpenseDetailController(
    this._repository,
    this._accessToken,
    this._groupId,
    this._expenseId,
  ) : super(ExpenseDetailState.initial());

  final ExpensesRepository _repository;
  final String? _accessToken;
  final String _groupId;
  final String _expenseId;

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
      final expense = await _repository.getExpense(
        accessToken: token,
        groupId: _groupId,
        expenseId: _expenseId,
      );

      state = state.copyWith(
        expense: expense,
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _readableMessage(
          error,
          fallback: 'Không thể tải chi tiết khoản chi.',
        ),
      );
    }
  }

  Future<bool> updateExpense({
    required String title,
    required int amount,
    required String paidByUserId,
    required List<String> participantIds,
    String? description,
    DateTime? expenseDate,
  }) async {
    final token = _requireAccessToken();

    if (token == null) {
      return false;
    }

    state = state.copyWith(
      isSaving: true,
      clearError: true,
      clearAction: true,
    );

    try {
      final expense = await _repository.updateExpense(
        accessToken: token,
        groupId: _groupId,
        expenseId: _expenseId,
        title: title,
        description: description,
        amount: amount,
        paidByUserId: paidByUserId,
        participantIds: participantIds,
        expenseDate: expenseDate,
      );

      state = state.copyWith(
        expense: expense,
        isSaving: false,
        actionMessage: 'Đã cập nhật khoản chi.',
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: _readableMessage(
          error,
          fallback: 'Không thể cập nhật khoản chi.',
        ),
        clearAction: true,
      );
      return false;
    }
  }

  Future<bool> deleteExpense() async {
    final token = _requireAccessToken();

    if (token == null) {
      return false;
    }

    state = state.copyWith(
      isSaving: true,
      clearError: true,
      clearAction: true,
    );

    try {
      final message = await _repository.deleteExpense(
        accessToken: token,
        groupId: _groupId,
        expenseId: _expenseId,
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
          fallback: 'Không thể xóa khoản chi.',
        ),
        clearAction: true,
      );
      return false;
    }
  }

  String? _requireAccessToken() {
    if (_accessToken == null || _accessToken.trim().isEmpty) {
      state = state.copyWith(
        isLoading: false,
        isSaving: false,
        errorMessage: 'Bạn cần đăng nhập lại để thao tác với khoản chi.',
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
