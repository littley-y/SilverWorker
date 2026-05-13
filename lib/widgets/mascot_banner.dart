import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// 홈 화면 최상단 마스코트 배너 위젯.
///
/// 스크롤 시 함께 날라가며, 터치 시 랜덤 응원 메시지를 출력합니다.
class MascotBanner extends StatefulWidget {
  const MascotBanner({super.key});

  @override
  State<MascotBanner> createState() => _MascotBannerState();
}

class _MascotBannerState extends State<MascotBanner> {
  static const List<String> _greetings = [
    '좋은 하루 되세요! 오늘도 힘내세요 🐾',
    '안녕하세요! 새로운 일자리를 찾아볼까요?',
    '오늘도 멋진 하루 되세요!',
    '힘내세요! 좋은 일이 생길 거예요 💪',
    '반가워요! 무엇을 도와드릴까요?',
    '헤헤, 오늘 날씨가 참 좋네요!',
    '새로운 시작을 응원해요! 🌟',
  ];

  late String _message;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _message = _greetings[_random.nextInt(_greetings.length)];
  }

  void _changeMessage() {
    HapticFeedback.lightImpact();
    setState(() {
      _message = _greetings[_random.nextInt(_greetings.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE3F2FD), Colors.white],
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: GestureDetector(
              onTap: _changeMessage,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/mascot/silver_bunny.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.pets,
                          size: 36,
                          color: Colors.grey.shade400,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                ),
                border: Border.all(color: AppColors.primary, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x081565C0),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _message,
                style: AppTextStyles.body.copyWith(height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
