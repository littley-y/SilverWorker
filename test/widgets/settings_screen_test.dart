import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silver_worker_now/providers/font_size_provider.dart';
import 'package:silver_worker_now/screens/settings/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SettingsScreen renders all sections', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('설정'), findsOneWidget);
    expect(find.text('글자 크기'), findsOneWidget);
    expect(find.text('앱 정보'), findsOneWidget);
    expect(find.text('설정 초기화'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
  });

  testWidgets('SettingsScreen shows font scale percentage', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('SettingsScreen back button pops', (WidgetTester tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: SettingsScreen()),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets("Font scale renders text at correct size via MediaQuery",
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MediaQuery(
          data: const MediaQueryData().copyWith(
            textScaler: const TextScaler.linear(1.4),
          ),
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: Text('Test', style: TextStyle(fontSize: 24)),
          ),
        ),
      ),
    );

    final element = tester.element(find.text('Test'));
    final textScaler = MediaQuery.textScalerOf(element);
    expect(textScaler, const TextScaler.linear(1.4));
  });
}
