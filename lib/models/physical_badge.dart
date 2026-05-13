import 'package:flutter/material.dart';

/// Single-source enum for physical badge types used in safety curation.
///
/// All UI rendering, test fixtures, and seed data MUST reference
/// these constants to prevent N-way drift between badge definitions.
abstract final class PhysicalBadge {
  PhysicalBadge._();

  static const String standing = 'standing';
  static const String sitting = 'sitting';
  static const String heavyLifting = 'heavy_lifting';
  static const String outdoor = 'outdoor';
  static const String repetitive = 'repetitive';
  static const String stairs = 'stairs';

  /// All 6 badge type codes.
  static const List<String> values = <String>[
    standing,
    sitting,
    heavyLifting,
    outdoor,
    repetitive,
    stairs,
  ];

  /// Korean display label for a badge code.
  static String label(String code) => switch (code) {
        standing => '계속 서있기',
        sitting => '좌식 업무',
        heavyLifting => '무거운 짐',
        outdoor => '야외 근무',
        repetitive => '반복 동작',
        stairs => '계단 오르내림',
        _ => code,
      };

  /// Material icon for a badge code.
  static IconData icon(String code) => switch (code) {
        standing => Icons.accessibility_new,
        sitting => Icons.chair,
        heavyLifting => Icons.inventory_2,
        outdoor => Icons.wb_sunny,
        repetitive => Icons.replay,
        stairs => Icons.stairs,
        _ => Icons.info_outline,
      };
}
