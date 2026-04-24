import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart'; // 추가
import 'package:silver_worker_now/main.dart';
import 'package:silver_worker_now/providers/alarm_provider.dart';
import 'package:silver_worker_now/services/mock_database_service.dart';
import 'package:silver_worker_now/views/splash_screen.dart';
import 'package:silver_worker_now/views/main_screen.dart';
import 'fakes/fake_alarm_scheduler.dart';

void main() {
  setUpAll(() async {
    // 테스트용 날짜 포맷 초기화 (ko_KR 로케일 에러 방지)
    await initializeDateFormatting('ko_KR', null);
  });

  testWidgets('App splash to main screen transition smoke test', (
    WidgetTester tester,
  ) async {
    // 1. 앱 실행 (ProviderScope 포함)
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseServiceProvider.overrideWithValue(MockDatabaseService()),
          alarmSchedulerProvider.overrideWithValue(FakeAlarmScheduler()),
        ],
        child: const SilverWorkerApp(),
      ),
    );

    // 2. 처음에는 SplashScreen이 떠야 함
    expect(find.byType(SplashScreen), findsOneWidget);

    // 3. 스플래시 화면의 2초 지연 시간을 강제로 건너뜀
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // 4. 이제 MainScreen으로 전환되었는지 확인
    expect(find.byType(MainScreen), findsOneWidget);

    // 5. 타이틀이 보이는지 확인 (테스트 환경의 기본 로케일에 따라 한국어 또는 영어가 나옴)
    final titleFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          (widget.data == '나갈준비' || widget.data == 'Must Go Out'),
    );
    expect(titleFinder, findsWidgets);
  });
}
