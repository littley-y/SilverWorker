import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/job_filter.dart';

/// Horizontal scrollable filter chip bar for job search.
///
/// Contains two sections: location and job category.
/// Single selection per section (demo scope). Re-tapping the selected
/// chip deselects it (resets to "전체" / null filter).
class FilterBar extends StatelessWidget {
  final JobFilter currentFilter;
  final ValueChanged<JobFilter> onFilterChanged;

  const FilterBar({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  // --- Location options (spec_04 §3) ---
  static const _locationOptions = <_FilterOption>[
    _FilterOption(label: '전체', code: null),
    _FilterOption(label: '종로구', code: '11110'),
    _FilterOption(label: '중구', code: '11140'),
    _FilterOption(label: '용산구', code: '11170'),
  ];

  // --- Job category options (spec_04 §3) ---
  static const _categoryOptions = <_FilterOption>[
    _FilterOption(label: '전체', code: null),
    _FilterOption(label: '경비/관리', code: 'security_management'),
    _FilterOption(label: '청소/미화', code: 'cleaning'),
    _FilterOption(label: '단순노무', code: 'simple_labor'),
    _FilterOption(label: '서비스', code: 'service'),
    _FilterOption(label: '사무/문서', code: 'office_work'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChipRow(
          label: '지역',
          options: _locationOptions,
          selectedCode: currentFilter.locationCode,
          onSelected: (code) {
            onFilterChanged(currentFilter.copyWith(locationCode: code));
          },
        ),
        const SizedBox(height: 8),
        _ChipRow(
          label: '직종',
          options: _categoryOptions,
          selectedCode: currentFilter.jobCategory,
          onSelected: (code) {
            onFilterChanged(currentFilter.copyWith(jobCategory: code));
          },
        ),
      ],
    );
  }
}

/// A single row of filter chips with a label.
class _ChipRow extends StatelessWidget {
  final String label;
  final List<_FilterOption> options;
  final String? selectedCode;
  final ValueChanged<String?> onSelected;

  const _ChipRow({
    required this.label,
    required this.options,
    required this.selectedCode,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(
            label,
            style: AppTextStyles.caption,
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: options.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = option.code == selectedCode;
                return _FilterChip(
                  label: option.label,
                  isSelected: isSelected,
                  onTap: () {
                    // Re-tap selected → deselect (set to 전체/null)
                    onSelected(isSelected ? null : option.code);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Individual filter chip.
///
/// Height: 40dp, horizontal padding: 16dp per spec_04 §3.
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Internal model for filter options.
class _FilterOption {
  final String label;
  final String? code;

  const _FilterOption({required this.label, required this.code});
}
