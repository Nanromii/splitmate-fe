class AppRoutes {
  const AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const groups = '/groups';
  static const groupCreate = '/groups/create';
  static const activity = '/activity';
  static const settings = '/settings';
  static const settingsProfile = '/settings/profile';

  static String groupDetail(String groupId) {
    return '/groups/$groupId';
  }

  static String groupEdit(String groupId) {
    return '/groups/$groupId/edit';
  }

  static String expenseCreate(String groupId) {
    return '/groups/$groupId/expenses/create';
  }

  static String expenseDetail(String groupId, String expenseId) {
    return '/groups/$groupId/expenses/$expenseId';
  }

  static String expenseEdit(String groupId, String expenseId) {
    return '/groups/$groupId/expenses/$expenseId/edit';
  }
}
