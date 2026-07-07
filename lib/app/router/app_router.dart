import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_state.dart';
import '../../features/auth/screens/home_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
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
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
      ],
      redirect: (context, state) {
        final location = state.matchedLocation;
        final isSplash = location == AppRoutes.splash;
        final isLogin = location == AppRoutes.login;

        if (authState.status == AuthStatus.initial ||
            authState.status == AuthStatus.loading ||
            authState.status == AuthStatus.failure) {
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