import 'package:flutter/material.dart';
import '../core/assets.dart';

enum DrillId { standard, heavy, thermal, rapid, crystal }

class DrillDef {
  final DrillId id;
  final String name;
  final String tagline;
  final String art;
  final Color tintColor;
  final bool tinted;

  /// Base stats (before global workshop upgrades / relics).
  final int baseHp;
  final double baseSpeed; // affects segment timer & depth-per-segment
  final double baseMaxHeat;
  final double baseCollisionPower;
  final double heatGainMultiplier; // >1 heats up faster
  final double resourceMultiplier; // ore/crystal gain multiplier
  final double rareFindBonus; // additive chance bonus [0..1]
  final int unlockOreCost;
  final int unlockCrystalCost;
  final int unlockDepthRequirement;
  final ZoneGate unlockZone;

  const DrillDef({
    required this.id,
    required this.name,
    required this.tagline,
    required this.art,
    this.tintColor = Colors.transparent,
    this.tinted = false,
    required this.baseHp,
    required this.baseSpeed,
    required this.baseMaxHeat,
    required this.baseCollisionPower,
    required this.heatGainMultiplier,
    required this.resourceMultiplier,
    required this.rareFindBonus,
    required this.unlockOreCost,
    required this.unlockCrystalCost,
    required this.unlockDepthRequirement,
    required this.unlockZone,
  });
}

enum ZoneGate { none, upperTunnels, magmaCaves, crystalDepths }

const List<DrillDef> kDrills = [
  DrillDef(
    id: DrillId.standard,
    name: 'Standard Drill',
    tagline: 'A reliable, well balanced rig for new expeditions.',
    art: GameAssets.drillMain,
    baseHp: 100,
    baseSpeed: 1.0,
    baseMaxHeat: 100,
    baseCollisionPower: 10,
    heatGainMultiplier: 1.0,
    resourceMultiplier: 1.0,
    rareFindBonus: 0.0,
    unlockOreCost: 0,
    unlockCrystalCost: 0,
    unlockDepthRequirement: 0,
    unlockZone: ZoneGate.none,
  ),
  DrillDef(
    id: DrillId.heavy,
    name: 'Heavy Drill',
    tagline: 'Powerful and tough. Crushes hard rock with ease, but slow.',
    art: GameAssets.drillHeavy,
    baseHp: 150,
    baseSpeed: 0.8,
    baseMaxHeat: 100,
    baseCollisionPower: 16,
    heatGainMultiplier: 1.05,
    resourceMultiplier: 1.0,
    rareFindBonus: 0.0,
    unlockOreCost: 500,
    unlockCrystalCost: 0,
    unlockDepthRequirement: 150,
    unlockZone: ZoneGate.upperTunnels,
  ),
  DrillDef(
    id: DrillId.thermal,
    name: 'Thermal Drill',
    tagline: 'Built for heat. Handles magmatic zones far better.',
    art: GameAssets.drillThermal,
    baseHp: 110,
    baseSpeed: 1.0,
    baseMaxHeat: 140,
    baseCollisionPower: 11,
    heatGainMultiplier: 0.75,
    resourceMultiplier: 1.0,
    rareFindBonus: 0.0,
    unlockOreCost: 900,
    unlockCrystalCost: 0,
    unlockDepthRequirement: 300,
    unlockZone: ZoneGate.magmaCaves,
  ),
  DrillDef(
    id: DrillId.rapid,
    name: 'Rapid Drill',
    tagline: 'Extremely fast, reaching great depth quickly. Overheats fast.',
    art: GameAssets.drillRapid,
    baseHp: 90,
    baseSpeed: 1.35,
    baseMaxHeat: 85,
    baseCollisionPower: 9,
    heatGainMultiplier: 1.25,
    resourceMultiplier: 1.0,
    rareFindBonus: 0.0,
    unlockOreCost: 1200,
    unlockCrystalCost: 100,
    unlockDepthRequirement: 500,
    unlockZone: ZoneGate.magmaCaves,
  ),
  DrillDef(
    id: DrillId.crystal,
    name: 'Crystal Drill',
    tagline: 'Specialized for crystal mining. Weaker against hard rock.',
    art: GameAssets.drillMain,
    tinted: true,
    tintColor: Color(0xFF9B6BFF),
    baseHp: 95,
    baseSpeed: 0.95,
    baseMaxHeat: 100,
    baseCollisionPower: 8,
    heatGainMultiplier: 1.0,
    resourceMultiplier: 1.35,
    rareFindBonus: 0.12,
    unlockOreCost: 800,
    unlockCrystalCost: 400,
    unlockDepthRequirement: 700,
    unlockZone: ZoneGate.crystalDepths,
  ),
];

DrillDef drillById(DrillId id) => kDrills.firstWhere((d) => d.id == id);
