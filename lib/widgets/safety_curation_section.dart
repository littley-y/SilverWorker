import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../utils/intensity_helper.dart';

class SafetyCurationSection extends StatelessWidget {
  final String physicalIntensity;
  final List<String> physicalBadges;

  const SafetyCurationSection({
    super.key,
    required this.physicalIntensity,
    required this.physicalBadges,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('업무 강도', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 8),
        _IntensityGradeBox(intensity: physicalIntensity),
        const SizedBox(height: 16),
        if (physicalBadges.isNotEmpty) ...[
          Text('신체 부담 항목', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: physicalBadges
                .map((b) => _PhysicalBadgeChip(badge: b))
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _IntensityGradeBox extends StatelessWidget {
  final String intensity;

  const _IntensityGradeBox({required this.intensity});

  @override
  Widget build(BuildContext context) {
    final color = IntensityHelper.color(intensity);
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(IntensityHelper.icon(intensity), size: 24, color: color),
          const SizedBox(width: 8),
          Text(
            IntensityHelper.label(intensity),
            style: AppTextStyles.bodyBold.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _PhysicalBadgeChip extends StatelessWidget {
  final String badge;

  const _PhysicalBadgeChip({required this.badge});

  String get _label => switch (badge) {
        'standing' => '계속 서있기',
        'sitting' => '좌식 업무',
        'heavy_lifting' => '무거운 짐',
        'outdoor' => '야외 근무',
        'repetitive' => '반복 동작',
        'stairs' => '계단 오르내림',
        _ => badge,
      };

  IconData get _icon => switch (badge) {
        'standing' => Icons.accessibility_new,
        'sitting' => Icons.chair,
        'heavy_lifting' => Icons.inventory_2,
        'outdoor' => Icons.wb_sunny,
        'repetitive' => Icons.replay,
        'stairs' => Icons.stairs,
        _ => Icons.info_outline,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(_label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
