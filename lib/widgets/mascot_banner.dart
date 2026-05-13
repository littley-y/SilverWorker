import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// 홈 화면 최상단 마스코트 배너 위젯.
///
/// 스크롤 시 함께 날라가며, 터치 시 랜덤 응원 메시지를 출력합니다.
/// 은일이가 둥둥 떠다니고, 터치 시 흔들리는 애니메이션을 가집니다.
class MascotBanner extends StatefulWidget {
  const MascotBanner({super.key});

  @override
  State<MascotBanner> createState() => _MascotBannerState();
}

class _MascotBannerState extends State<MascotBanner>
    with SingleTickerProviderStateMixin {
  static const List<String> _greetings = [
    '좋은 하루 되세요! 오늘도 힘내세요 🐾',
    '안녕하세요! 새로운 일자리를 찾아볼까요?',
    '오늘도 멋진 하루 되세요!',
    '힘내세요! 좋은 일이 생길 거예요 💪',
    '반가워요! 무엇을 도와드릴까요?',
    '헤헤, 오늘 날씨가 참 좋네요!',
    '새로운 시작을 응원해요! 🌟',
    '은일이가 응원해요! 화이팅! 🐶',
    '꼬리를 흔들며 응원합니다! 은일이에요 🐾',
  ];

  late String _message;
  final _random = Random();

  late final AnimationController _floatController;
  late final Animation<Offset> _floatAnimation;

  double _wobbleAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _message = _greetings[_random.nextInt(_greetings.length)];

    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.08),
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  void _onTapMascot() {
    HapticFeedback.lightImpact();
    setState(() {
      _message = _greetings[_random.nextInt(_greetings.length)];
      _wobbleAngle = 0.15;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _wobbleAngle = -0.1);
      }
    });
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() => _wobbleAngle = 0.05);
      }
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _wobbleAngle = 0.0);
      }
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
          SlideTransition(
            position: _floatAnimation,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: _wobbleAngle),
              duration: const Duration(milliseconds: 150),
              curve: Curves.elasticOut,
              builder: (context, angle, child) {
                return Transform.rotate(
                  angle: angle,
                  child: child,
                );
              },
              child: GestureDetector(
                onTap: _onTapMascot,
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
                      'assets/mascot/silver_dog.png',
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
