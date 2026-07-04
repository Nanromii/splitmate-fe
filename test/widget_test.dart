import 'package:flutter_test/flutter_test.dart';
import 'package:splitmate/app/app.dart';
import 'package:splitmate/core/config/app_config.dart';

void main() {
  testWidgets('renders flutter foundation placeholder screen', (tester) async {
    const config = AppConfig(
      appName: 'SplitMate',
      apiBaseUrl: 'http://localhost:5000',
      environment: 'development',
    );

    await tester.pumpWidget(
      const SplitMateApp(
        config: config,
      ),
    );

    expect(find.text('SplitMate'), findsWidgets);
    expect(find.text('Flutter foundation is ready.'), findsOneWidget);
  });
}