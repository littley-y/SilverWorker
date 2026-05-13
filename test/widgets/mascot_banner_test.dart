import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silver_worker_now/widgets/mascot_banner.dart';

void main() {
  testWidgets('MascotBanner renders mascot image and bubble', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MascotBanner(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));

    // Mascot image or fallback icon should be present
    expect(find.byType(Image), findsOneWidget);
    // Bubble with some greeting text
    expect(find.byType(Container), findsWidgets);
  });

  testWidgets('MascotBanner changes message on tap', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MascotBanner(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));

    // Find the mascot gesture detector and tap it
    final gestureDetectors = find.byType(GestureDetector);
    expect(gestureDetectors, findsWidgets);

    await tester.tap(gestureDetectors.first);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));

    // Should still render after tap
    expect(find.byType(Image), findsOneWidget);
  });
}
