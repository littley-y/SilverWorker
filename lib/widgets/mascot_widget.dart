import 'package:flutter/material.dart';

/// 은일이 마스코트 위젯.
///
/// 등장 시 통통 튀는 애니메이션을 가집니다.
class MascotWidget extends StatelessWidget {
  const MascotWidget({
    super.key,
    this.size = 80,
    this.animated = true,
  });

  final double size;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final widget = Image.asset(
      'assets/mascot/silver_dog.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(size / 4),
          ),
          child: Icon(
            Icons.pets,
            size: size * 0.5,
            color: Colors.grey.shade400,
          ),
        );
      },
    );

    if (!animated) return widget;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (BuildContext context, double scale, Widget? child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: widget,
    );
  }
}
