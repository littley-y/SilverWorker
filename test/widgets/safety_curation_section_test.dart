import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silver_worker_now/widgets/safety_curation_section.dart';

void main() {
  testWidgets('renders intensity grade label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SafetyCurationSection(
            physicalIntensity: 'moderate',
            physicalBadges: [],
          ),
        ),
      ),
    );

    expect(find.text('업무 강도'), findsOneWidget);
    expect(find.text('보통'), findsOneWidget);
  });

  testWidgets('renders all intensity levels', (tester) async {
    for (final intensity in ['light', 'moderate', 'heavy']) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafetyCurationSection(
              physicalIntensity: intensity,
              physicalBadges: [],
            ),
          ),
        ),
      );

      final label = switch (intensity) {
        'light' => '가벼움',
        'moderate' => '보통',
        'heavy' => '무거움',
        _ => intensity,
      };
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('renders physical badges', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SafetyCurationSection(
            physicalIntensity: 'moderate',
            physicalBadges: ['standing', 'outdoor'],
          ),
        ),
      ),
    );

    expect(find.text('신체 부담 항목'), findsOneWidget);
    expect(find.text('계속 서있기'), findsOneWidget);
    expect(find.text('야외 근무'), findsOneWidget);
  });

  testWidgets('hides badge section when empty', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SafetyCurationSection(
            physicalIntensity: 'light',
            physicalBadges: [],
          ),
        ),
      ),
    );

    expect(find.text('신체 부담 항목'), findsNothing);
  });
}
