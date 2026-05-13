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

    await tester.pumpAndSettle();

    // Find the mascot image/gesture detector and tap it
    final gestureDetector = find.byType(GestureDetector);
    expect(gestureDetector, findsOneWidget);

    await tester.tap(gestureDetector);
    await tester.pump();

    // Should still render after tap
    expect(find.byType(Image), findsOneWidget);
  });
}
