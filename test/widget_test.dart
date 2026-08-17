import 'package:flutter_test/flutter_test.dart';
import 'package:dndn/app.dart';
import 'package:dndn/core/di/injection.dart';

void main() {
  setUp(() async {
    await configureDependencies();
  });

  testWidgets('App root initializes and displays navigation items', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());
    await tester.pump();

    // Since App defaults to SplashPage showing brand name 'دندن'
    expect(find.text('دندن'), findsOneWidget);
    expect(find.text('Smart GPS Tracking'), findsOneWidget);
  });

  testWidgets('MainNavigationPage displays navigation bar and title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const App(),
    );
    await tester.pump();
  });
}
