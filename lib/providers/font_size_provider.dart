import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>((ref) {
  return FontSizeNotifier();
});

class FontSizeNotifier extends StateNotifier<double> {
  FontSizeNotifier() : super(1.0) {
    _loadFuture = _load();
  }

  static const String _key = 'font_scale';
  static const double minScale = 1.0;   // 축소 비허용 (spec_09 §1: 최소 14pt)
  static const double maxScale = 1.33;  // headline 24pt × 1.33 ≈ 32pt 상한
  late final Future<void> _loadFuture;

  Future<void> get initialized => _loadFuture;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble(_key);
    if (saved != null) {
      state = saved.clamp(minScale, maxScale);
    }
  }

  Future<void> setScale(double value) async {
    final clamped = value.clamp(minScale, maxScale);
    if ((state - clamped).abs() < 1e-9) return;
    state = clamped;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, clamped);
  }
}
