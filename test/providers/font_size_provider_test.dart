import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silver_worker_now/providers/font_size_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('FontSizeNotifier initial value is 1.3', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final scale = container.read(fontSizeProvider);
    expect(scale, 1.3);
  });

  test('FontSizeNotifier setScale stays at fixedScale', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(fontSizeProvider.notifier).setScale(1.2);
    expect(container.read(fontSizeProvider), 1.3);
  });

  test('FontSizeNotifier ignores below fixedScale', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(fontSizeProvider.notifier).setScale(0.5);
    expect(container.read(fontSizeProvider), 1.3);
  });

  test('FontSizeNotifier ignores above fixedScale', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(fontSizeProvider.notifier).setScale(2.0);
    expect(container.read(fontSizeProvider), 1.3);
  });

  test('FontSizeNotifier persists fixedScale to SharedPreferences', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(fontSizeProvider.notifier).setScale(1.2);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getDouble('font_scale'), 1.3);
  });

  test('FontSizeNotifier resets out-of-range saved value to fixedScale',
      () async {
    SharedPreferences.setMockInitialValues({'font_scale': 5.0});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(fontSizeProvider.notifier).initialized;
    expect(container.read(fontSizeProvider), 1.3);
  });

  test('FontSizeNotifier resets saved value to fixedScale', () async {
    SharedPreferences.setMockInitialValues({'font_scale': 1.15});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(fontSizeProvider.notifier).initialized;
    expect(container.read(fontSizeProvider), 1.3);
  });
}
