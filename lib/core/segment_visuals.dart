import 'package:flutter/material.dart';
import '../models/segment.dart';
import 'app_colors.dart';

class SegmentVisual {
  final IconData icon;
  final Color color;
  final String hint;

  const SegmentVisual(this.icon, this.color, this.hint);
}

SegmentVisual segmentVisual(SegmentType type) {
  switch (type) {
    case SegmentType.plainRock:
      return const SegmentVisual(Icons.terrain, AppColors.textMuted, 'Plain rock');
    case SegmentType.hardRock:
      return const SegmentVisual(Icons.grain, Color(0xFF8A6A50), 'Hard rock');
    case SegmentType.oreVein:
      return const SegmentVisual(Icons.diamond_outlined, AppColors.emberGold, 'Ore glimmer');
    case SegmentType.crystalVein:
      return const SegmentVisual(Icons.auto_awesome, Color(0xFFB169F0), 'Crystal glow');
    case SegmentType.rareOre:
      return const SegmentVisual(Icons.stars, Color(0xFFFFD23C), 'Bright glow');
    case SegmentType.coolingCrystal:
      return const SegmentVisual(Icons.ac_unit, AppColors.coolCyan, 'Cool draft');
    case SegmentType.enemy:
      return const SegmentVisual(Icons.warning_amber, AppColors.danger, 'Movement inside');
    case SegmentType.hazard:
      return const SegmentVisual(Icons.local_fire_department, AppColors.lavaRed, 'Unstable heat');
    case SegmentType.event:
      return const SegmentVisual(Icons.auto_fix_high, Color(0xFFE8A33B), 'Something ahead');
    case SegmentType.ancientChamber:
      return const SegmentVisual(Icons.temple_hindu, Color(0xFFC9902F), 'Ancient chamber');
  }
}
