import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show StateNotifierProvider;

import '../../../core/network/dio.provider.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/expenses_api.dart';
import '../data/expenses_repository.dart';
import 'expenses_controllers.dart';
import 'expenses_state.dart';

final expensesApiProvider = Provider<ExpensesApi>((ref) {
  final dio = ref.watch(dioProvider);
  return ExpensesApi(dio);
});

final expensesRepositoryProvider = Provider<ExpensesRepository>((ref) {
  final api = ref.watch(expensesApiProvider);
  return ExpensesRepository(api);
});

final expenseListControllerProvider =
    StateNotifierProvider.family<ExpenseListController, ExpenseListState, String>(
  (ref, groupId) {
    final authState = ref.watch(authControllerProvider);

    return ExpenseListController(
      ref.watch(expensesRepositoryProvider),
      authState.session?.accessToken,
      groupId,
    );
  },
);

final expenseDetailControllerProvider = StateNotifierProvider.family<
    ExpenseDetailController, ExpenseDetailState, ExpenseDetailParams>(
  (ref, params) {
    final authState = ref.watch(authControllerProvider);

    return ExpenseDetailController(
      ref.watch(expensesRepositoryProvider),
      authState.session?.accessToken,
      params.groupId,
      params.expenseId,
    );
  },
);

class ExpenseDetailParams {
  const ExpenseDetailParams({
    required this.groupId,
    required this.expenseId,
  });

  final String groupId;
  final String expenseId;

  @override
  bool operator ==(Object other) {
    return other is ExpenseDetailParams &&
        other.groupId == groupId &&
        other.expenseId == expenseId;
  }

  @override
  int get hashCode => Object.hash(groupId, expenseId);
}
