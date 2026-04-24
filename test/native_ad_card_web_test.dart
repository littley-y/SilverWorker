import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silver_worker_now/views/widgets/native_ad_card.dart';

void main() {
  testWidgets('NativeAdCard builds without throwing (Web-safe path)',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: NativeAdCard(keyword: 'test'),
        ),
      ),
    );
    expect(find.byType(NativeAdCard), findsOneWidget);
    // Ad not loaded in test env; widget should render SizedBox.shrink without exception.
    expect(tester.takeException(), isNull);
    // Platform guard prevents _loadAd() on Linux host → _isLoaded=false → SizedBox.shrink().
    expect(find.byType(SizedBox), findsOneWidget);
  });
}
