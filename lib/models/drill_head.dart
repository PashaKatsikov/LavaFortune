import 'package:flutter/material.dart';

enum DrillHeadBonus { resourceBonus, collisionPower, coolingEfficiency, maxHeat, rareFindChance }

class DrillHeadDef {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final DrillHeadBonus bonus;
  final double bonusValue;
  final int unlockOreCost;

  const DrillHeadDef({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.bonus,
    required this.bonusValue,
    required this.unlockOreCost,
  });

  String get bonusLabel {
    switch (bonus) {
      case DrillHeadBonus.resourceBonus:
        return '+${(bonusValue * 100).toStringAsFixed(0)}% resources';
      case DrillHeadBonus.collisionPower:
        return '+${bonusValue.toStringAsFixed(0)} collision power';
      case DrillHeadBonus.coolingEfficiency:
        return '+${(bonusValue * 100).toStringAsFixed(0)}% cooling';
      case DrillHeadBonus.maxHeat:
        return '+${bonusValue.toStringAsFixed(0)} max heat';
      case DrillHeadBonus.rareFindChance:
        return '+${(bonusValue * 100).toStringAsFixed(0)}% rare find';
    }
  }
}

const List<DrillHeadDef> kDrillHeads = [
  DrillHeadDef(
    id: 'standard_head',
    name: 'Standard Head',
    icon: Icons.change_history,
    color: Color(0xFFB0A08C),
    bonus: DrillHeadBonus.resourceBonus,
    bonusValue: 0.0,
    unlockOreCost: 0,
  ),
  DrillHeadDef(
    id: 'reinforced_head',
    name: 'Reinforced Head',
    icon: Icons.shield,
    color: Color(0xFF8AA0B8),
    bonus: DrillHeadBonus.collisionPower,
    bonusValue: 3,
    unlockOreCost: 400,
  ),
  DrillHeadDef(
    id: 'thermal_head',
    name: 'Thermal-Resistant Head',
    icon: Icons.ac_unit,
    color: Color(0xFF3ED2E8),
    bonus: DrillHeadBonus.coolingEfficiency,
    bonusValue: 0.1,
    unlockOreCost: 600,
  ),
  DrillHeadDef(
    id: 'crystal_head',
    name: 'Crystalline Head',
    icon: Icons.diamond,
    color: Color(0xFF9B6BFF),
    bonus: DrillHeadBonus.resourceBonus,
    bonusValue: 0.15,
    unlockOreCost: 900,
  ),
  DrillHeadDef(
    id: 'seeker_head',
    name: 'Seeker Head',
    icon: Icons.travel_explore,
    color: Color(0xFFF2A93B),
    bonus: DrillHeadBonus.rareFindChance,
    bonusValue: 0.06,
    unlockOreCost: 1200,
  ),
  DrillHeadDef(
    id: 'furnace_head',
    name: 'Furnace Head',
    icon: Icons.local_fire_department,
    color: Color(0xFFE33B2E),
    bonus: DrillHeadBonus.maxHeat,
    bonusValue: 12,
    unlockOreCost: 1500,
  ),
];

/// Falls back to the starter head so a save referencing an unknown id
/// (older or corrupted data) can never break the loadout.
DrillHeadDef drillHeadById(String id) =>
    kDrillHeads.firstWhere((h) => h.id == id, orElse: () => kDrillHeads.first);
