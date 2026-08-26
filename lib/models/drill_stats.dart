import 'drill.dart';
import 'drill_head.dart';
import 'player_profile.dart';
import 'relic.dart';
import 'upgrade.dart';

/// Fully computed drill stats for the currently selected loadout, combining
/// base drill stats, permanent workshop upgrades, the selected drill head
/// and all owned ancient relics.
class EffectiveStats {
  final double maxHp;
  final double maxHeat;
  final double collisionPower;
  final double heatGainMultiplier;
  final double coolingMultiplier;
  final double resourceMultiplier;
  final double rareFindChance;
  final double speed;

  const EffectiveStats({
    required this.maxHp,
    required this.maxHeat,
    required this.collisionPower,
    required this.heatGainMultiplier,
    required this.coolingMultiplier,
    required this.resourceMultiplier,
    required this.rareFindChance,
    required this.speed,
  });

  static EffectiveStats compute(PlayerProfile profile) {
    final drill = drillById(profile.selectedDrill);
    final head = drillHeadById(profile.selectedDrillHead);

    double maxHp = drill.baseHp.toDouble();
    double maxHeat = drill.baseMaxHeat;
    double collisionPower = drill.baseCollisionPower;
    double heatGainMultiplier = drill.heatGainMultiplier;
    double coolingMultiplier = 1.0;
    double resourceMultiplier = drill.resourceMultiplier;
    double rareFindChance = 0.06 + drill.rareFindBonus;
    double speed = drill.baseSpeed;

    maxHp += profile.upgradeLevel(UpgradeId.durability.name) *
        upgradeById(UpgradeId.durability).perLevelValue;
    maxHeat += profile.upgradeLevel(UpgradeId.maxTemperature.name) *
        upgradeById(UpgradeId.maxTemperature).perLevelValue;
    collisionPower += profile.upgradeLevel(UpgradeId.collisionPower.name) *
        upgradeById(UpgradeId.collisionPower).perLevelValue;
    coolingMultiplier += profile.upgradeLevel(UpgradeId.coolingEfficiency.name) *
        upgradeById(UpgradeId.coolingEfficiency).perLevelValue;
    resourceMultiplier += profile.upgradeLevel(UpgradeId.resourceBonus.name) *
        upgradeById(UpgradeId.resourceBonus).perLevelValue;
    rareFindChance += profile.upgradeLevel(UpgradeId.rareFindChance.name) *
        upgradeById(UpgradeId.rareFindChance).perLevelValue;
    heatGainMultiplier -= profile.upgradeLevel(UpgradeId.drillingSpeed.name) *
        upgradeById(UpgradeId.drillingSpeed).perLevelValue;

    switch (head.bonus) {
      case DrillHeadBonus.resourceBonus:
        resourceMultiplier += head.bonusValue;
        break;
      case DrillHeadBonus.collisionPower:
        collisionPower += head.bonusValue;
        break;
      case DrillHeadBonus.coolingEfficiency:
        coolingMultiplier += head.bonusValue;
        break;
      case DrillHeadBonus.maxHeat:
        maxHeat += head.bonusValue;
        break;
      case DrillHeadBonus.rareFindChance:
        rareFindChance += head.bonusValue;
        break;
    }

    for (final relicId in profile.ownedRelics) {
      final relic = relicById(relicId);
      if (relic == null) continue;
      switch (relic.bonusType) {
        case RelicBonusType.maxHeat:
          maxHeat += relic.bonusValue;
          break;
        case RelicBonusType.coolingEfficiency:
          coolingMultiplier += relic.bonusValue;
          break;
        case RelicBonusType.durability:
          maxHp += relic.bonusValue;
          break;
        case RelicBonusType.rareFindChance:
          rareFindChance += relic.bonusValue;
          break;
        case RelicBonusType.resourceBonus:
          resourceMultiplier += relic.bonusValue;
          break;
        case RelicBonusType.collisionPower:
          collisionPower += relic.bonusValue;
          break;
      }
    }

    if (heatGainMultiplier < 0.35) heatGainMultiplier = 0.35;
    if (rareFindChance > 0.6) rareFindChance = 0.6;

    return EffectiveStats(
      maxHp: maxHp,
      maxHeat: maxHeat,
      collisionPower: collisionPower,
      heatGainMultiplier: heatGainMultiplier,
      coolingMultiplier: coolingMultiplier,
      resourceMultiplier: resourceMultiplier,
      rareFindChance: rareFindChance,
      speed: speed,
    );
  }
}
