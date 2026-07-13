import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitmate/app/app.dart';
import 'package:splitmate/core/config/app_confg_provider.dart';
import 'package:splitmate/core/config/app_config.dart';

void main() {
  testWidgets('renders session bootstrap screen', (tester) async {
    const config = AppConfig(
      appName: 'SplitMate',
      apiBaseUrl: 'http://localhost:5000',
      environment: 'development',
      googleServerClientId: 'test-client-id.apps.googleusercontent.com',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(config),
        ],
        child: const SplitMateApp(
          config: config,
        ),
      ),
    );

    expect(find.text('Đang kiểm tra phiên đăng nhập...'), findsOneWidget);
  });
}
