import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silver_worker_now/constants/app_colors.dart';
import 'package:silver_worker_now/models/job_filter.dart';
import 'package:silver_worker_now/widgets/filter_bar.dart';

void main() {
  testWidgets('FilterBar renders location and category labels', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FilterBar(
            currentFilter: JobFilter.empty,
            onFilterChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('지역'), findsOneWidget);
    expect(find.text('직종'), findsOneWidget);
  });

  testWidgets('FilterBar renders all location chips', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FilterBar(
            currentFilter: JobFilter.empty,
            onFilterChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('전체'), findsNWidgets(2)); // both location and category
    expect(find.text('종로구'), findsOneWidget);
    expect(find.text('중구'), findsOneWidget);
    expect(find.text('용산구'), findsOneWidget);
  });

  testWidgets('FilterBar renders all category chips', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FilterBar(
            currentFilter: JobFilter.empty,
            onFilterChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('경비/관리'), findsOneWidget);
    expect(find.text('청소/미화'), findsOneWidget);
    expect(find.text('단순노무'), findsOneWidget);
    expect(find.text('서비스'), findsOneWidget);
    expect(find.text('사무/문서'), findsOneWidget);
  });

  testWidgets('Tapping a location chip calls onFilterChanged with locationCode',
      (tester) async {
    JobFilter? receivedFilter;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FilterBar(
            currentFilter: JobFilter.empty,
            onFilterChanged: (filter) => receivedFilter = filter,
          ),
        ),
      ),
    );

    await tester.tap(find.text('종로구'));
    await tester.pump();

    expect(receivedFilter, isNotNull);
    expect(receivedFilter!.locationCode, '11110');
  });

  testWidgets('Tapping selected chip again deselects it (sets to null)',
      (tester) async {
    JobFilter? receivedFilter;

    final filterWithLocation = const JobFilter(locationCode: '11110');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FilterBar(
            currentFilter: filterWithLocation,
            onFilterChanged: (filter) => receivedFilter = filter,
          ),
        ),
      ),
    );

    // Tap the already-selected chip
    await tester.tap(find.text('종로구'));
    await tester.pump();

    expect(receivedFilter, isNotNull);
    expect(receivedFilter!.locationCode, isNull);
  });

  testWidgets('Tapping a category chip calls onFilterChanged with jobCategory',
      (tester) async {
    JobFilter? receivedFilter;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FilterBar(
            currentFilter: JobFilter.empty,
            onFilterChanged: (filter) => receivedFilter = filter,
          ),
        ),
      ),
    );

    await tester.tap(find.text('경비/관리'));
    await tester.pump();

    expect(receivedFilter, isNotNull);
    expect(receivedFilter!.jobCategory, 'security_management');
  });

  testWidgets('Selected chip has primary color background', (tester) async {
    final filterWithLocation = const JobFilter(locationCode: '11110');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FilterBar(
            currentFilter: filterWithLocation,
            onFilterChanged: (_) {},
          ),
        ),
      ),
    );

    // Find the Container for the chip with text '종로구' (selected chip)
    final jongnoChip = find.ancestor(
      of: find.text('종로구'),
      matching: find.byType(Container),
    );

    final container = tester.widget<Container>(jongnoChip);
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, AppColors.primary);
  });
}
