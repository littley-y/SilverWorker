import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silver_worker_now/widgets/gray_chip.dart';

void main() {
  testWidgets('GrayChip renders label text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GrayChip(label: '파트타임'),
        ),
      ),
    );

    expect(find.text('파트타임'), findsOneWidget);
  });

  testWidgets('GrayChip renders with icon prefix', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GrayChip(label: '도보 8분', icon: '🚶'),
        ),
      ),
    );

    expect(find.text('🚶 도보 8분'), findsOneWidget);
  });

  testWidgets('GrayChip has correct container styling', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GrayChip(label: 'D-3'),
        ),
      ),
    );

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.borderRadius, BorderRadius.circular(8));
  });
}
