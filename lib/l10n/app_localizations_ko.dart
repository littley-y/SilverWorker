// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '나갈준비';

  @override
  String get mustLeaveTime => '집에서 나갈 시간';

  @override
  String get tapToChangeTime => '탭하여 시간 변경';

  @override
  String get preparationStartTime => '준비 시작 알림';

  @override
  String get totalPreparationTime => '총 준비 시간';

  @override
  String get minutes => '분';

  @override
  String get noRoutine => '루틴 없음';

  @override
  String get editSteps => '단계 편집';

  @override
  String get alarmRepeat => '알람 반복';

  @override
  String get everyday => '매일';

  @override
  String get none => '안 함';

  @override
  String get weekdays => '평일';

  @override
  String get weekends => '주말';

  @override
  String get routineManagement => '루틴 관리';

  @override
  String get newRoutine => '새 루틴';

  @override
  String get freeLimitMessage => '무료 버전은 최대 2개까지만 가능합니다. 프리미엄을 구독하세요!';

  @override
  String get maxStepLimitMessage => '단계는 최대 10개까지만 추가할 수 있습니다.';

  @override
  String get cancel => '취소';

  @override
  String get stepName => '단계 이름';

  @override
  String get confirm => '확인';

  @override
  String get setDepartureTime => '집에서 나갈 시간 설정';

  @override
  String get setRepeatDays => '반복 요일 설정';

  @override
  String get startPreparation => '알람 예약 / 시작하기';

  @override
  String get preparationStep => '준비 단계';

  @override
  String get splashSubtitle => '당신의 아침을 역산합니다';

  @override
  String get settings => '환경 설정';

  @override
  String get language => '언어 설정';

  @override
  String get systemDefault => '시스템 기본';

  @override
  String get korean => '한국어';

  @override
  String get english => '영어';

  @override
  String get japanese => '일본어';

  @override
  String get chineseSimplified => '중국어 (간체)';

  @override
  String get spanish => '스페인어';

  @override
  String get french => '프랑스어';

  @override
  String get monday => '월';

  @override
  String get tuesday => '화';

  @override
  String get wednesday => '수';

  @override
  String get thursday => '목';

  @override
  String get friday => '금';

  @override
  String get saturday => '토';

  @override
  String get sunday => '일';

  @override
  String get routine_1 => '루틴 1';

  @override
  String get routine_2 => '루틴 2';

  @override
  String get routine_ui_test => '테스트';

  @override
  String get item_step => '단계';

  @override
  String get add_step => '단계 추가';

  @override
  String get edit_step => '단계 수정';

  @override
  String get delete_step => '단계 삭제';

  @override
  String get preparationTimeline => '준비 타임라인';

  @override
  String get delayOccurred => '지연 발생';

  @override
  String get hurryUp => '서두르세요!';

  @override
  String get completed => '완료';

  @override
  String get preparationResult => '준비 결과';

  @override
  String get preparationFinished => '준비 완료!';

  @override
  String get resultDescription => '오늘의 외출 준비 결과입니다';

  @override
  String get totalScore => '전체 준비 성적';

  @override
  String lateByMinutes(Object minutes) {
    return '$minutes분 지각';
  }

  @override
  String get onTimeDeparture => '정시 출발 가능';

  @override
  String get planned => '계획';

  @override
  String get actual => '실제';

  @override
  String delayedFeedback(Object minutes) {
    return '계획보다 $minutes분 더 소요되었습니다.';
  }

  @override
  String get earlyFeedback => '축하합니다! 계획보다 일찍 마치셨네요.\n여유로운 마음으로 출발하세요.';

  @override
  String plannedActualRatio(Object actual, Object planned, Object seconds) {
    return '계획 $planned분 / 실제 $actual분 $seconds초';
  }

  @override
  String get returnToMain => '메인으로 돌아가기';

  @override
  String get routinePresetSelection => '루틴/프리셋 선택';

  @override
  String get systemPreset => '시스템 기본 프리셋';

  @override
  String get userRoutine => '사용자 정의 루틴';

  @override
  String errorOccurred(Object error) {
    return '에러 발생: $error';
  }

  @override
  String get preparing => '준비 중';

  @override
  String get stop => '중단';

  @override
  String get extendOneMinute => '+ 1분 연장 (현재 단계)';

  @override
  String finalDepartureExpected(Object time) {
    return '최종 외출 예정: $time';
  }

  @override
  String get freeModeSwitched => 'Free Mode 전환됨';

  @override
  String get proModeSwitched => 'Pro Mode 전환됨 (무제한 루틴)';

  @override
  String get themeMode => '테마';

  @override
  String get themeLight => '라이트';

  @override
  String get themeDark => '다크';

  @override
  String get themeSystem => '시스템';

  @override
  String leaveAt(String time) {
    return '$time 나감';
  }

  @override
  String get alarmNotSet => '알람 미설정';

  @override
  String get alarmSet => '알람 설정됨';

  @override
  String get wakeUpAt => '기상';

  @override
  String get departureAt => '출발';

  @override
  String get deleteRoutineConfirm => '이 루틴을 삭제하시겠습니까?';
}
