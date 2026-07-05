import 'package:flutter/material.dart';

import '../core/config/app_config.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class SplitMateApp extends StatelessWidget {
  const SplitMateApp({
    super.key,
    required this.config,
  });

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SplitMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}