import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silver_worker_now/constants/app_colors.dart';
import 'package:silver_worker_now/widgets/otp_pin_box.dart';

void main() {
  group('OtpPinBox', () {
    late TextEditingController controller;
    late FocusNode focusNode;
    String? changedValue;

    Widget buildPinBox({
      bool autofocus = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: OtpPinBox(
            controller: controller,
            focusNode: focusNode,
            autofocus: autofocus,
            onChanged: (String value) => changedValue = value,
            onKeyEvent: (_) {},
          ),
        ),
      );
    }

    setUp(() {
      controller = TextEditingController();
      focusNode = FocusNode();
      changedValue = null;
    });

    tearDown(() {
      controller.dispose();
      focusNode.dispose();
    });

    testWidgets('renders a TextField', (tester) async {
      await tester.pumpWidget(buildPinBox());

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('accepts digit input', (tester) async {
      await tester.pumpWidget(buildPinBox());

      await tester.enterText(find.byType(TextField), '5');
      await tester.pump();

      expect(controller.text, '5');
    });

    testWidgets('rejects non-digit input', (tester) async {
      await tester.pumpWidget(buildPinBox());

      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump();

      expect(controller.text, isEmpty);
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      await tester.pumpWidget(buildPinBox());

      await tester.enterText(find.byType(TextField), '7');
      await tester.pump();

      expect(changedValue, '7');
    });

    testWidgets('calls onChanged with empty string when cleared',
        (tester) async {
      await tester.pumpWidget(buildPinBox());

      await tester.enterText(find.byType(TextField), '3');
      await tester.pump();

      changedValue = null;

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      expect(changedValue, '');
    });

    testWidgets('has OutlineInputBorder with borderRadius 12', (tester) async {
      await tester.pumpWidget(buildPinBox());

      final textField = tester.widget<TextField>(find.byType(TextField));
      final decoration = textField.decoration!;
      final border = decoration.border as OutlineInputBorder;

      expect(border.borderRadius, BorderRadius.circular(12));
    });

    testWidgets('has focusedBorder with primary color and width 2',
        (tester) async {
      await tester.pumpWidget(buildPinBox());

      final textField = tester.widget<TextField>(find.byType(TextField));
      final decoration = textField.decoration!;
      final focusedBorder = decoration.focusedBorder as OutlineInputBorder;

      expect(focusedBorder.borderRadius, BorderRadius.circular(12));
      expect(focusedBorder.borderSide.color, AppColors.primary);
      expect(focusedBorder.borderSide.width, 2.0);
    });

    testWidgets('has border with correct default color', (tester) async {
      await tester.pumpWidget(buildPinBox());

      final textField = tester.widget<TextField>(find.byType(TextField));
      final decoration = textField.decoration!;
      final border = decoration.border as OutlineInputBorder;

      expect(border.borderSide.color, AppColors.border);
    });

    testWidgets('has correct fixed dimensions', (tester) async {
      await tester.pumpWidget(buildPinBox());

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(TextField),
          matching: find.byType(SizedBox),
        ),
      );

      expect(sizedBox.width, 56);
      expect(sizedBox.height, 64);
    });

    testWidgets('uses center text alignment', (tester) async {
      await tester.pumpWidget(buildPinBox());

      final textField = tester.widget<TextField>(find.byType(TextField));

      expect(textField.textAlign, TextAlign.center);
    });

    testWidgets('uses number keyboard type', (tester) async {
      await tester.pumpWidget(buildPinBox());

      final textField = tester.widget<TextField>(find.byType(TextField));

      expect(textField.keyboardType, TextInputType.number);
    });

    testWidgets('forwards autofocus to TextField', (tester) async {
      await tester.pumpWidget(buildPinBox(autofocus: true));

      final textField = tester.widget<TextField>(find.byType(TextField));

      expect(textField.autofocus, isTrue);
    });

    testWidgets('defaults autofocus to false', (tester) async {
      await tester.pumpWidget(buildPinBox());

      final textField = tester.widget<TextField>(find.byType(TextField));

      expect(textField.autofocus, isFalse);
    });
  });
}
