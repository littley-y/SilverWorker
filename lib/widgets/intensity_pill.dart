import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// 업무 강도 표현 pill 위젯.
///
/// 문장 형태로 표현하며, 테두리와 배경색으로 강조합니다.
/// 색상: 초록(하) / 주황(중) / 빨강(상)
class IntensityPill extends StatelessWidget {
  final String physicalIntensity;

  const IntensityPill({super.key, required this.physicalIntensity});

  String get _label => switch (physicalIntensity) {
        'light' => '앉아서 일해요',
        'moderate' => '서서 근무해요',
        'heavy' => '무거운 짐 있어요',
        _ => '알 수 없음',
      };

  Color get _color => switch (physicalIntensity) {
        'light' => AppColors.intensityLight,
        'moderate' => AppColors.intensityModerate,
        'heavy' => AppColors.intensityHeavy,
        _ => AppColors.textSecondary,
      };

  Color get _bgColor => switch (physicalIntensity) {
        'light' => const Color(0x144CAF50),
        'moderate' => const Color(0x14FF9800),
        'heavy' => const Color(0x14F44336),
        _ => AppColors.background,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _color, width: 1.5),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: _color,
          height: 1.2,
        ),
      ),
    );
  }
}
