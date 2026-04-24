import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';

/// 루틴 아이템 이름 등 l10n: 접두사가 붙은 문자열을 번역하고
/// 국가별 시간/날짜 포맷을 처리하는 유틸리티
class L10nUtils {
  /// 문자열 기반 동적 번역 (루틴 이름 등)
  static String translate(BuildContext context, String text) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return text;
    if (!text.startsWith('l10n:')) return text;

    final fullKey = text.replaceFirst('l10n:', '');
    final parts = fullKey.split(' ');
    final key = parts[0];
    final suffix = parts.length > 1 ? ' ${parts[1]}' : '';

    switch (key) {
      case 'routine_1':
        return l10n.routine_1;
      case 'routine_2':
        return l10n.routine_2;
      case 'routine_ui_test':
        return l10n.routine_ui_test;
      case 'item_step':
        return '${l10n.item_step}$suffix';
      default:
        return fullKey;
    }
  }

  /// 국가별 설정을 준수한 시간 포맷팅 (글로벌 대응 필수)
  static String formatTime(BuildContext context, DateTime dateTime) {
    final locale = Localizations.localeOf(context).toString();
    if (locale.startsWith('ko')) {
      final ampm = dateTime.hour < 12 ? '오전' : '오후';
      int h = dateTime.hour % 12;
      if (h == 0) h = 12;
      return '$ampm $h시 ${dateTime.minute.toString().padLeft(2, '0')}분';
    }
    // 'jm' 패턴은 각 국가의 표준 시간 형식(12/24시 자동 선택)을 따름
    return DateFormat.jm(locale).format(dateTime);
  }

  /// 단순 HH:mm 문자열을 로컬라이즈된 시간 문자열로 변환 (예: '08:00' -> '오전 8:00')
  static String formatTimeString(BuildContext context, String timeStr) {
    try {
      final parts = timeStr.split(':');
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, int.parse(parts[0]),
          int.parse(parts[1]));
      return formatTime(context, dt);
    } catch (_) {
      return timeStr;
    }
  }
}
