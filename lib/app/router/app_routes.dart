class AppRoutes {
  const AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const groups = '/groups';
  static const groupCreate = '/groups/create';
  static const activity = '/activity';
  static const settings = '/settings';

  static String groupDetail(String groupId) {
    return '/groups/$groupId';
  }

  static String groupEdit(String groupId) {
    return '/groups/$groupId/edit';
  }
}
