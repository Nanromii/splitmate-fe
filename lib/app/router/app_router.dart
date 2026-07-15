import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_state.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/expenses/screens/create_expense_screen.dart';
import '../../features/expenses/screens/edit_expense_screen.dart';
import '../../features/expenses/screens/expense_detail_screen.dart';
import '../../features/groups/screens/create_group_screen.dart';
import '../../features/groups/screens/edit_group_screen.dart';
import '../../features/groups/screens/group_detail_screen.dart';
import '../../features/groups/screens/groups_screen.dart';
import '../../features/main/screens/activity_screen.dart';
import '../../features/main/screens/dashboard_screen.dart';
import '../../features/main/screens/main_shell_screen.dart';
import '../../features/settings/screens/profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import 'app_routes.dart';

class AppRouter {
  const AppRouter._();

  static GoRouter build(AuthState authState) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainShellScreen(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.home,
                  name: 'home',
                  builder: (context, state) => const DashboardScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.groups,
                  name: 'groups',
                  builder: (context, state) => const GroupsScreen(),
                  routes: [
                    GoRoute(
                      path: 'create',
                      name: 'group-create',
                      builder: (context, state) => const CreateGroupScreen(),
                    ),
                    GoRoute(
                      path: ':groupId',
                      name: 'group-detail',
                      builder: (context, state) {
                        final groupId = state.pathParameters['groupId'] ?? '';

                        return GroupDetailScreen(groupId: groupId);
                      },
                      routes: [
                        GoRoute(
                          path: 'edit',
                          name: 'group-edit',
                          builder: (context, state) {
                            final groupId =
                                state.pathParameters['groupId'] ?? '';

                            return EditGroupScreen(groupId: groupId);
                          },
                        ),
                        GoRoute(
                          path: 'expenses/create',
                          name: 'expense-create',
                          builder: (context, state) {
                            final groupId =
                                state.pathParameters['groupId'] ?? '';

                            return CreateExpenseScreen(groupId: groupId);
                          },
                        ),
                        GoRoute(
                          path: 'expenses/:expenseId',
                          name: 'expense-detail',
                          builder: (context, state) {
                            final groupId =
                                state.pathParameters['groupId'] ?? '';
                            final expenseId =
                                state.pathParameters['expenseId'] ?? '';

                            return ExpenseDetailScreen(
                              groupId: groupId,
                              expenseId: expenseId,
                            );
                          },
                          routes: [
                            GoRoute(
                              path: 'edit',
                              name: 'expense-edit',
                              builder: (context, state) {
                                final groupId =
                                    state.pathParameters['groupId'] ?? '';
                                final expenseId =
                                    state.pathParameters['expenseId'] ?? '';

                                return EditExpenseScreen(
                                  groupId: groupId,
                                  expenseId: expenseId,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.activity,
                  name: 'activity',
                  builder: (context, state) => const ActivityScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.settings,
                  name: 'settings',
                  builder: (context, state) => const SettingsScreen(),
                  routes: [
                    GoRoute(
                      path: 'profile',
                      name: 'settings-profile',
                      builder: (context, state) => const ProfileScreen(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        final location = state.matchedLocation;
        final isSplash = location == AppRoutes.splash;
        final isLogin = location == AppRoutes.login;

        if (authState.status == AuthStatus.initial ||
            authState.status == AuthStatus.loading) {
          return isSplash ? null : AppRoutes.splash;
        }

        if (!authState.isAuthenticated) {
          return isLogin ? null : AppRoutes.login;
        }

        if (isSplash || isLogin) {
          return AppRoutes.home;
        }

        return null;
      },
    );
  }
}
