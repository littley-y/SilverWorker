import 'package:flutter/material.dart';

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
      'assets/mascot/silver_bunny.png',
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

    return AnimatedScale(
      scale: 1.0,
      duration: const Duration(milliseconds: 300),
      child: widget,
    );
  }
}
