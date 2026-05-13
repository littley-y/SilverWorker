import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// 연회색 배경의 메타 정보 chip 위젯.
///
/// 구직형태, 도보거리, D-day 등 하단 메타 정보에 사용.
class GrayChip extends StatelessWidget {
  final String label;
  final String? icon;

  const GrayChip({super.key, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        icon != null ? '$icon $label' : label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          height: 1.2,
        ),
      ),
    );
  }
}
