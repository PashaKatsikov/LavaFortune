import 'package:flutter/material.dart';
import '../core/assets.dart';

enum ZoneId { upperTunnels, magmaCaves, crystalDepths, ancientZone, volcanoHeart }

class ZoneDef {
  final ZoneId id;
  final String name;
  final String background;
  final int minDepth;
  final int maxDepth;
  final Color accentColor;
  final String description;
  /// Depth the player must reach in the *previous* zone to unlock this one.
  final int unlockDepthRequirement;
  final int unlockOreCost;

  const ZoneDef({
    required this.id,
    required this.name,
    required this.background,
    required this.minDepth,
    required this.maxDepth,
    required this.accentColor,
    required this.description,
    required this.unlockDepthRequirement,
    required this.unlockOreCost,
  });

  double get baseDangerFactor => 1.0 + (minDepth / 600.0);
}

const List<ZoneDef> kZones = [
  ZoneDef(
    id: ZoneId.upperTunnels,
    name: 'Upper Tunnels',
    background: GameAssets.bgUpperTunnels,
    minDepth: 0,
    maxDepth: 300,
    accentColor: Color(0xFFE8A33B),
    description: 'A relatively safe network of volcanic tunnels. Perfect for learning the drill.',
    unlockDepthRequirement: 0,
    unlockOreCost: 0,
  ),
  ZoneDef(
    id: ZoneId.magmaCaves,
    name: 'Magma Caves',
    background: GameAssets.bgMagmaCaves,
    minDepth: 200,
    maxDepth: 700,
    accentColor: Color(0xFFE85A1A),
    description: 'Deep magmatic caverns. Higher heat, tougher rock, stronger enemies.',
    unlockDepthRequirement: 250,
    unlockOreCost: 600,
  ),
  ZoneDef(
    id: ZoneId.crystalDepths,
    name: 'Crystal Depths',
    background: GameAssets.bgCrystalDepths,
    minDepth: 600,
    maxDepth: 1200,
    accentColor: Color(0xFF8B4FD6),
    description: 'Crystalline depths rich with rare gems. Great value, great risk.',
    unlockDepthRequirement: 650,
    unlockOreCost: 1500,
  ),
  ZoneDef(
    id: ZoneId.ancientZone,
    name: 'Ancient Volcanic Zone',
    background: GameAssets.bgAncientZone,
    minDepth: 1100,
    maxDepth: 1800,
    accentColor: Color(0xFFC9902F),
    description: 'Ruins of an ancient civilization. Elite guardians protect powerful relics.',
    unlockDepthRequirement: 1150,
    unlockOreCost: 3200,
  ),
  ZoneDef(
    id: ZoneId.volcanoHeart,
    name: 'Volcano Heart',
    background: GameAssets.bgVolcanoHeart,
    minDepth: 1700,
    maxDepth: 999999,
    accentColor: Color(0xFFE33B2E),
    description: 'The molten core itself. Home to the final ancient volcanic beast.',
    unlockDepthRequirement: 1750,
    unlockOreCost: 6000,
  ),
];

ZoneDef zoneById(ZoneId id) => kZones.firstWhere((z) => z.id == id);
