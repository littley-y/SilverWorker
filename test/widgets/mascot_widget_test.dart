import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silver_worker_now/widgets/mascot_widget.dart';

void main() {
  testWidgets('MascotWidget renders with default size',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MascotWidget(),
        ),
      ),
    );

    expect(find.byType(MascotWidget), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('MascotWidget renders fallback on error',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MascotWidget(),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(TweenAnimationBuilder<double>), findsOneWidget);
  });

  testWidgets('MascotWidget respects size parameter',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MascotWidget(size: 120),
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.width, 120);
    expect(image.height, 120);
  });

  testWidgets('MascotWidget non-animated mode', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MascotWidget(animated: false),
        ),
      ),
    );

    expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
    expect(find.byType(Image), findsOneWidget);
  });
}
