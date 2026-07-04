import 'package:flutter/material.dart';

import '../core/config/app_config.dart';
import 'router/app_router.dart';
import 'router/app_routes.dart';
import 'theme/app_theme.dart';

class SplitMateApp extends StatelessWidget {
  const SplitMateApp({
    required this.config,
    super.key,
  });

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: config.appName,
      debugShowCheckedModeBanner: config.isDevelopment,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      routes: AppRouter.routes,
    );
  }
}