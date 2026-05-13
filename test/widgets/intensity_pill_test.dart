import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silver_worker_now/widgets/intensity_pill.dart';

void main() {
  testWidgets(
      'IntensityPill renders light intensity with correct label and color',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: IntensityPill(physicalIntensity: 'light'),
        ),
      ),
    );

    expect(find.text('앉아서 일해요'), findsOneWidget);

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.border, isA<Border>());
  });

  testWidgets('IntensityPill renders moderate intensity', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: IntensityPill(physicalIntensity: 'moderate'),
        ),
      ),
    );

    expect(find.text('서서 근무해요'), findsOneWidget);
  });

  testWidgets('IntensityPill renders heavy intensity', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: IntensityPill(physicalIntensity: 'heavy'),
        ),
      ),
    );

    expect(find.text('무거운 짐 있어요'), findsOneWidget);
  });

  testWidgets('IntensityPill renders fallback for unknown intensity',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: IntensityPill(physicalIntensity: 'unknown'),
        ),
      ),
    );

    expect(find.text('알 수 없음'), findsOneWidget);
  });
}
