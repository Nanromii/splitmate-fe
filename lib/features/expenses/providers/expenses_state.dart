import '../models/expense.dart';

class ExpenseListState {
  const ExpenseListState({
    required this.expenses,
    this.isLoading = false,
    this.isRefreshing = false,
    this.isSaving = false,
    this.errorMessage,
    this.actionMessage,
  });

  final List<Expense> expenses;
  final bool isLoading;
  final bool isRefreshing;
  final bool isSaving;
  final String? errorMessage;
  final String? actionMessage;

  bool get isEmpty => expenses.isEmpty;

  factory ExpenseListState.initial() {
    return const ExpenseListState(expenses: []);
  }

  ExpenseListState copyWith({
    List<Expense>? expenses,
    bool? isLoading,
    bool? isRefreshing,
    bool? isSaving,
    String? errorMessage,
    String? actionMessage,
    bool clearError = false,
    bool clearAction = false,
  }) {
    return ExpenseListState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      actionMessage: clearAction ? null : actionMessage ?? this.actionMessage,
    );
  }
}

class ExpenseDetailState {
  const ExpenseDetailState({
    this.expense,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.actionMessage,
  });

  final Expense? expense;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? actionMessage;

  bool get hasExpense => expense != null;

  factory ExpenseDetailState.initial() {
    return const ExpenseDetailState();
  }

  ExpenseDetailState copyWith({
    Expense? expense,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? actionMessage,
    bool clearError = false,
    bool clearAction = false,
  }) {
    return ExpenseDetailState(
      expense: expense ?? this.expense,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      actionMessage: clearAction ? null : actionMessage ?? this.actionMessage,
    );
  }
}
