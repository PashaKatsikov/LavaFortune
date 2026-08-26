import 'package:flutter/material.dart';
import '../core/assets.dart';

enum RelicBonusType {
  maxHeat,
  coolingEfficiency,
  durability,
  rareFindChance,
  resourceBonus,
  collisionPower,
}

enum RelicRarity { common, rare, epic, legendary }

extension RelicRarityX on RelicRarity {
  Color get color {
    switch (this) {
      case RelicRarity.common:
        return const Color(0xFFB0A08C);
      case RelicRarity.rare:
        return const Color(0xFF4FA3E8);
      case RelicRarity.epic:
        return const Color(0xFFB169F0);
      case RelicRarity.legendary:
        return const Color(0xFFF2A93B);
    }
  }

  String get label {
    switch (this) {
      case RelicRarity.common:
        return 'Common';
      case RelicRarity.rare:
        return 'Rare';
      case RelicRarity.epic:
        return 'Epic';
      case RelicRarity.legendary:
        return 'Legendary';
    }
  }
}

class RelicDef {
  final String id;
  final String name;
  final String art;
  final RelicRarity rarity;
  final RelicBonusType bonusType;
  final double bonusValue;
  final String description;
  final int minDepth;

  RelicDef({
    required this.id,
    required this.name,
    required this.art,
    required this.rarity,
    required this.bonusType,
    required this.bonusValue,
    required this.description,
    required this.minDepth,
  });

  String get bonusLabel {
    switch (bonusType) {
      case RelicBonusType.maxHeat:
        return '+${bonusValue.toStringAsFixed(0)} max temperature';
      case RelicBonusType.coolingEfficiency:
        return '+${(bonusValue * 100).toStringAsFixed(0)}% cooling efficiency';
      case RelicBonusType.durability:
        return '+${bonusValue.toStringAsFixed(0)} drill durability';
      case RelicBonusType.rareFindChance:
        return '+${(bonusValue * 100).toStringAsFixed(0)}% rare find chance';
      case RelicBonusType.resourceBonus:
        return '+${(bonusValue * 100).toStringAsFixed(0)}% resource yield';
      case RelicBonusType.collisionPower:
        return '+${bonusValue.toStringAsFixed(0)} collision power';
    }
  }
}

final List<RelicDef> kRelics = [
  RelicDef(
    id: 'ancient_talisman',
    name: 'Ancient Talisman',
    art: GameAssets.relicArt[0],
    rarity: RelicRarity.rare,
    bonusType: RelicBonusType.maxHeat,
    bonusValue: 15,
    description: 'Increases the drill\'s maximum temperature threshold.',
    minDepth: 0,
  ),
  RelicDef(
    id: 'spiral_rune_disc',
    name: 'Spiral Rune Disc',
    art: GameAssets.relicArt[1],
    rarity: RelicRarity.common,
    bonusType: RelicBonusType.coolingEfficiency,
    bonusValue: 0.12,
    description: 'An ancient rune said to channel heat away from machinery.',
    minDepth: 0,
  ),
  RelicDef(
    id: 'molten_idol',
    name: 'Molten Idol',
    art: GameAssets.relicArt[2],
    rarity: RelicRarity.epic,
    bonusType: RelicBonusType.durability,
    bonusValue: 20,
    description: 'A heavy idol that reinforces the drill\'s hull.',
    minDepth: 300,
  ),
  RelicDef(
    id: 'sun_amulet',
    name: 'Sun Amulet',
    art: GameAssets.relicArt[3],
    rarity: RelicRarity.rare,
    bonusType: RelicBonusType.rareFindChance,
    bonusValue: 0.05,
    description: 'Radiates a warmth that seems to attract rare ore.',
    minDepth: 200,
  ),
  RelicDef(
    id: 'crimson_talisman',
    name: 'Crimson Talisman',
    art: GameAssets.relicArt[0],
    rarity: RelicRarity.legendary,
    bonusType: RelicBonusType.maxHeat,
    bonusValue: 30,
    description: 'A deeper, more powerful variant of the ancient talisman.',
    minDepth: 800,
  ),
  RelicDef(
    id: 'obsidian_disc',
    name: 'Obsidian Rune Disc',
    art: GameAssets.relicArt[1],
    rarity: RelicRarity.epic,
    bonusType: RelicBonusType.coolingEfficiency,
    bonusValue: 0.22,
    description: 'This disc pulses with residual cooling energy.',
    minDepth: 700,
  ),
  RelicDef(
    id: 'guardian_idol',
    name: 'Guardian Idol',
    art: GameAssets.relicArt[2],
    rarity: RelicRarity.legendary,
    bonusType: RelicBonusType.collisionPower,
    bonusValue: 6,
    description: 'Grants the drill the guardian\'s legendary striking power.',
    minDepth: 1100,
  ),
  RelicDef(
    id: 'radiant_amulet',
    name: 'Radiant Amulet',
    art: GameAssets.relicArt[3],
    rarity: RelicRarity.epic,
    bonusType: RelicBonusType.resourceBonus,
    bonusValue: 0.18,
    description: 'A brilliant amulet that enhances every haul of resources.',
    minDepth: 900,
  ),
];

/// Returns null for ids that are not part of the current relic set, so stats
/// computed from a save file never throw on unknown entries.
RelicDef? relicById(String id) {
  for (final relic in kRelics) {
    if (relic.id == id) return relic;
  }
  return null;
}
