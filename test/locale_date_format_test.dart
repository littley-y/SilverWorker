import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
  });

  test('DateFormat.jm works for all supported locales', () {
    final dt = DateTime(2026, 4, 22, 15, 30);
    for (final locale in ['en', 'ja', 'zh', 'es', 'fr', 'ko']) {
      expect(() => DateFormat.jm(locale).format(dt), returnsNormally,
          reason: '$locale 로케일에서 DateFormat.jm이 예외 없이 동작해야 한다');
    }
  });
}
