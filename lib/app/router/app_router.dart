import 'package:flutter/material.dart';

import '../../shared/widgets/placeholder_screen.dart';
import 'app_routes.dart';

class AppRouter {
  const AppRouter._();

  static Map<String, WidgetBuilder> get routes {
    return {
      AppRoutes.splash: (_) => const PlaceholderScreen(
            title: 'SplitMate',
            message: 'Karina so beautiful.',
          ),
      AppRoutes.home: (_) => const PlaceholderScreen(
            title: 'Home',
            message: 'Main app screen placeholder.',
          ),
    };
  }
}