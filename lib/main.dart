import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';

void main() {
  const config = AppConfig.fromEnvironment();

  runApp(
    SplitMateApp(
      config: config,
    ),
  );
}