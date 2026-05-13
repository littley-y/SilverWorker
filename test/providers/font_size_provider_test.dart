import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silver_worker_now/providers/font_size_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('FontSizeNotifier initial value is 1.0', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final scale = container.read(fontSizeProvider);
    expect(scale, 1.0);
  });

  test('FontSizeNotifier setScale updates state', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(fontSizeProvider.notifier).setScale(1.2);
    expect(container.read(fontSizeProvider), 1.2);
  });

  test('FontSizeNotifier clamps to minScale', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(fontSizeProvider.notifier).setScale(0.5);
    expect(container.read(fontSizeProvider), 1.0);
  });

  test('FontSizeNotifier clamps to maxScale', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(fontSizeProvider.notifier).setScale(2.0);
    expect(container.read(fontSizeProvider), 1.33);
  });

  test('FontSizeNotifier persists to SharedPreferences', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(fontSizeProvider.notifier).setScale(1.2);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getDouble('font_scale'), 1.2);
  });

  test('FontSizeNotifier ignores out-of-range saved value', () async {
    SharedPreferences.setMockInitialValues({'font_scale': 5.0});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(fontSizeProvider.notifier).initialized;
    expect(container.read(fontSizeProvider), 1.33);
  });

  test('FontSizeNotifier loads saved value', () async {
    SharedPreferences.setMockInitialValues({'font_scale': 1.15});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(fontSizeProvider.notifier).initialized;
    expect(container.read(fontSizeProvider), 1.15);
  });
}
