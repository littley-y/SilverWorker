import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>((ref) {
  return FontSizeNotifier();
});

class FontSizeNotifier extends StateNotifier<double> {
  FontSizeNotifier() : super(1.3) {
    _loadFuture = _load();
  }

  static const String _key = 'font_scale';
  static const double fixedScale = 1.3; // 고정 130% (spec_12 확정)
  static const double minScale = 1.3; // 축소 비허용, 고정값과 동일
  static const double maxScale = 1.3; // 고정값과 동일
  late final Future<void> _loadFuture;

  Future<void> get initialized => _loadFuture;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble(_key);
    if (saved != null) {
      state = fixedScale;
    } else {
      state = fixedScale;
      await prefs.setDouble(_key, fixedScale);
    }
  }

  Future<void> setScale(double value) async {
    // Font scale is fixed at 130% — no user adjustment allowed
    if ((state - fixedScale).abs() < 1e-9) return;
    state = fixedScale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, fixedScale);
  }
}
