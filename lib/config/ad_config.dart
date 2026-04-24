import 'dart:io';
import 'package:flutter/foundation.dart';

/// AdMob 광고 단위 ID 설정
///
/// 테스트 환경(kDebugMode)에서는 Google 공식 테스트 ID를 사용하고,
/// 프로덕션 빌드에서는 환경변수(ADMOB_BANNER_ANDROID 등)를 통해 주입받는다.
/// 환경변수가 없는 프로덕션 빌드는 빈 문자열을 반환하므로,
/// 광고 로드가 실패(AdError)하며 UI는 SizedBox.shrink()로 숨겨진다.
class AdConfig {
  AdConfig._();

  // -----------------------------------------------------------------------
  // Google 공식 테스트 ID (디버그 전용)
  // https://developers.google.com/admob/android/test-ads
  // -----------------------------------------------------------------------
  static const String _testBannerAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testNativeAndroid =
      'ca-app-pub-3940256099942544/2247696110';
  static const String _testNativeIos = 'ca-app-pub-3940256099942544/3986624511';

  // -----------------------------------------------------------------------
  // 프로덕션 ID (환경변수 주입, --dart-define 방식)
  // 빌드 명령 예시:
  //   flutter build apk \
  //     --dart-define=ADMOB_BANNER_ANDROID=ca-app-pub-XXXX/YYYY \
  //     --dart-define=ADMOB_BANNER_IOS=ca-app-pub-XXXX/ZZZZ \
  //     --dart-define=ADMOB_NATIVE_ANDROID=ca-app-pub-XXXX/AAAA \
  //     --dart-define=ADMOB_NATIVE_IOS=ca-app-pub-XXXX/BBBB
  // -----------------------------------------------------------------------
  static const String _prodBannerAndroid =
      String.fromEnvironment('ADMOB_BANNER_ANDROID', defaultValue: '');
  static const String _prodBannerIos =
      String.fromEnvironment('ADMOB_BANNER_IOS', defaultValue: '');
  static const String _prodNativeAndroid =
      String.fromEnvironment('ADMOB_NATIVE_ANDROID', defaultValue: '');
  static const String _prodNativeIos =
      String.fromEnvironment('ADMOB_NATIVE_IOS', defaultValue: '');

  // -----------------------------------------------------------------------
  // 공개 접근자 — 호출부에서는 이 값만 참조한다
  // -----------------------------------------------------------------------

  /// 배너 광고 단위 ID (현재 플랫폼)
  static String get bannerAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid ? _testBannerAndroid : _testBannerIos;
    }
    return Platform.isAndroid ? _prodBannerAndroid : _prodBannerIos;
  }

  /// 네이티브 광고 단위 ID (현재 플랫폼)
  static String get nativeAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid ? _testNativeAndroid : _testNativeIos;
    }
    return Platform.isAndroid ? _prodNativeAndroid : _prodNativeIos;
  }
}
