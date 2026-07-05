import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/placeholder_screen.dart';
import 'app_routes.dart';

class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (BuildContext context, GoRouterState state) {
          return const PlaceholderScreen(
            title: 'SplitMate',
            message: 'Karina so beautiful.',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (BuildContext context, GoRouterState state) {
          return const PlaceholderScreen(
            title: 'Home',
            message: 'Main app screen placeholder.',
          );
        },
      ),
    ],
  );
}