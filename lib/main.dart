import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:silver_worker_now/l10n/app_localizations.dart';
import 'providers/alarm_provider.dart';
import 'providers/theme_provider.dart';
import 'services/alarm_scheduler_service.dart';
import 'views/splash_screen.dart';

/// 전역 네비게이터 키 — 알림 탭 시 화면 전환에 사용
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 알림 탭 콜백 등록: 콜드스타트 이벤트 손실 방지를 위해 initialize() 이전에 등록
  AlarmSchedulerService.onNotificationTap = () {
    final context = navigatorKey.currentContext;
    if (context != null && context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SplashScreen()),
        (route) => false,
      );
    }
  };

  // 독립적인 초기화 작업 병렬 실행
  await Future.wait([
    AlarmSchedulerService().initialize(),
    if (!kIsWeb) MobileAds.instance.initialize(),
    initializeDateFormatting(), // 인자 없음 → 모든 로케일 데이터 로드
  ]);

  runApp(const ProviderScope(child: SilverWorkerApp()));
}

class SilverWorkerApp extends ConsumerWidget {
  const SilverWorkerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(alarmProvider);
    final themeMode = ref.watch(themeModeProvider);

    // 설정된 언어 코드 (auto인 경우 null을 반환하여 시스템 설정을 따름)
    final languageCode = state.userConfig?.languageCode;
    final locale = (languageCode == null || languageCode == 'auto')
        ? null
        : Locale(languageCode);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: '나갈준비 알리미',
      debugShowCheckedModeBanner: false,
      // 언어 설정 적용
      locale: locale,
      // 자동 생성된 다국어 델리게이트 사용
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // ARB 파일 기반으로 자동 지원되는 로케일 목록
      supportedLocales: AppLocalizations.supportedLocales,
      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF), // Apple Blue
          brightness: Brightness.light,
          surface: Colors.white,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor:
            const Color(0xFFF2F2F7), // iOS System Background Gray
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
          iconTheme: IconThemeData(color: Color(0xFF1C1C1E)),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A84FF), // Apple Dark Blue
          brightness: Brightness.dark,
          surface: const Color(0xFF1C1C1E),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black, // iOS Dark Background
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
