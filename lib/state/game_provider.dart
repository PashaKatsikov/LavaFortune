import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/contract.dart';
import '../models/drill.dart';
import '../models/drill_head.dart';
import '../models/drill_stats.dart';
import '../models/player_profile.dart';
import '../models/run_state.dart';
import '../models/upgrade.dart';
import '../models/zone.dart';
import '../services/audio_service.dart';
import '../services/haptics_service.dart';
import '../services/save_service.dart';

const int kEnergyRegenSeconds = 180; // 1 energy every 3 minutes
const int kDrillBoosterCrystalCost = 25;

class GameProvider extends ChangeNotifier {
  final SaveService _saveService = SaveService();
  late PlayerProfile profile;
  bool loaded = false;
  Timer? _energyTimer;
  final Random _random = Random();

  Future<void> load() async {
    profile = await _saveService.load();
    _applyEnergyRegen();
    _refreshContractsIfNeeded();
    loaded = true;
    AudioService.instance.musicEnabled = profile.musicOn;
    AudioService.instance.sfxEnabled = profile.sfxOn;
    HapticsService.instance.enabled = profile.vibrationOn;
    notifyListeners();
    _energyTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _applyEnergyRegen();
      // Daily content must also roll over for sessions that stay open past
      // midnight, not just on a cold start.
      _refreshContractsIfNeeded();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _energyTimer?.cancel();
    super.dispose();
  }

  Future<void> _persist() async {
    await _saveService.save(profile);
  }

  void _applyEnergyRegen() {
    if (profile.energy >= profile.energyMax) {
      profile.lastEnergyTimestampMs = DateTime.now().millisecondsSinceEpoch;
      return;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsedSec = (now - profile.lastEnergyTimestampMs) ~/ 1000;
    final regenCount = elapsedSec ~/ kEnergyRegenSeconds;
    if (regenCount > 0) {
      final newEnergy = (profile.energy + regenCount).clamp(0, profile.energyMax);
      final consumedSec = regenCount * kEnergyRegenSeconds;
      profile.energy = newEnergy;
      profile.lastEnergyTimestampMs += consumedSec * 1000;
      _persist();
    }
  }

  int secondsUntilNextEnergy() {
    if (profile.energy >= profile.energyMax) return 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsedSec = (now - profile.lastEnergyTimestampMs) ~/ 1000;
    final remaining = kEnergyRegenSeconds - (elapsedSec % kEnergyRegenSeconds);
    return remaining;
  }

  String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }

  void _refreshContractsIfNeeded() {
    final today = _todayKey();
    if (profile.contractsRefreshDate == today && profile.contracts.isNotEmpty) return;
    profile.contractsRefreshDate = today;
    profile.contracts = _generateContracts();
    _persist();
  }

  List<ContractInstance> _generateContracts() {
    final depthTargets = [200, 400, 600, 900];
    final depthTarget = depthTargets[_random.nextInt(depthTargets.length)] +
        (profile.bestOverallDepth ~/ 4);
    final oreTarget = 150 + _random.nextInt(6) * 50;
    final crystalTarget = 15 + _random.nextInt(4) * 5;
    final enemiesTarget = 8 + _random.nextInt(4) * 3;
    return [
      ContractInstance(
        id: 'c_depth_${DateTime.now().millisecondsSinceEpoch}',
        type: ContractType.reachDepth,
        target: depthTarget,
        daily: true,
      ),
      ContractInstance(
        id: 'c_ore_${DateTime.now().millisecondsSinceEpoch + 1}',
        type: ContractType.mineOre,
        target: oreTarget,
        daily: true,
      ),
      ContractInstance(
        id: 'c_crystal_${DateTime.now().millisecondsSinceEpoch + 2}',
        type: ContractType.mineCrystals,
        target: crystalTarget,
        daily: true,
      ),
      ContractInstance(
        id: 'c_enemies_${DateTime.now().millisecondsSinceEpoch + 3}',
        type: ContractType.defeatEnemies,
        target: enemiesTarget,
        daily: true,
      ),
      ContractInstance(
        id: 'c_relic_${DateTime.now().millisecondsSinceEpoch + 4}',
        type: ContractType.findRelic,
        target: 1,
        daily: false,
      ),
      ContractInstance(
        id: 'c_noheat_${DateTime.now().millisecondsSinceEpoch + 5}',
        type: ContractType.noOverheatExpedition,
        target: 1,
        daily: false,
      ),
    ];
  }

  // ---------------- Derived helpers ----------------

  EffectiveStats get effectiveStats => EffectiveStats.compute(profile);

  bool isZoneUnlocked(ZoneId id) => profile.unlockedZones.contains(id);

  bool canUnlockZone(ZoneDef zone) {
    if (isZoneUnlocked(zone.id)) return false;
    final idx = kZones.indexWhere((z) => z.id == zone.id);
    if (idx <= 0) return true;
    final prevZone = kZones[idx - 1];
    final prevBest = profile.bestDepthByZone[prevZone.id] ?? 0;
    return prevBest >= zone.unlockDepthRequirement;
  }

  bool canAffordZoneUnlock(ZoneDef zone) => profile.ore >= zone.unlockOreCost;

  void unlockZone(ZoneDef zone) {
    if (!canUnlockZone(zone)) return;
    if (zone.unlockOreCost > 0) {
      if (profile.ore < zone.unlockOreCost) return;
      profile.ore -= zone.unlockOreCost;
    }
    profile.unlockedZones.add(zone.id);
    _persist();
    notifyListeners();
  }

  bool isDrillUnlocked(DrillId id) => profile.unlockedDrills.contains(id);

  bool canUnlockDrillProgress(DrillDef drill) {
    switch (drill.unlockZone) {
      case ZoneGate.none:
        return true;
      case ZoneGate.upperTunnels:
        return (profile.bestDepthByZone[ZoneId.upperTunnels] ?? 0) >= drill.unlockDepthRequirement;
      case ZoneGate.magmaCaves:
        return (profile.bestDepthByZone[ZoneId.magmaCaves] ?? 0) >= drill.unlockDepthRequirement;
      case ZoneGate.crystalDepths:
        return (profile.bestDepthByZone[ZoneId.crystalDepths] ?? 0) >=
            drill.unlockDepthRequirement;
    }
  }

  bool unlockDrill(DrillDef drill) {
    if (isDrillUnlocked(drill.id)) return true;
    if (profile.ore < drill.unlockOreCost || profile.crystals < drill.unlockCrystalCost) {
      return false;
    }
    profile.ore -= drill.unlockOreCost;
    profile.crystals -= drill.unlockCrystalCost;
    profile.unlockedDrills.add(drill.id);
    _persist();
    notifyListeners();
    return true;
  }

  void selectDrill(DrillId id) {
    if (!isDrillUnlocked(id)) return;
    profile.selectedDrill = id;
    _persist();
    notifyListeners();
  }

  bool unlockDrillHead(DrillHeadDef head) {
    if (profile.unlockedDrillHeads.contains(head.id)) return true;
    if (profile.ore < head.unlockOreCost) return false;
    profile.ore -= head.unlockOreCost;
    profile.unlockedDrillHeads.add(head.id);
    _persist();
    notifyListeners();
    return true;
  }

  void selectDrillHead(String id) {
    if (!profile.unlockedDrillHeads.contains(id)) return;
    profile.selectedDrillHead = id;
    _persist();
    notifyListeners();
  }

  bool purchaseUpgrade(UpgradeDef upgrade) {
    final level = profile.upgradeLevel(upgrade.id.name);
    if (level >= upgrade.maxLevel) return false;
    final cost = upgrade.costForLevel(level);
    if (profile.ore < cost) return false;
    profile.ore -= cost;
    profile.upgradeLevels[upgrade.id.name] = level + 1;
    _persist();
    notifyListeners();
    return true;
  }

  bool spendEnergy(int amount) {
    if (profile.energy < amount) return false;
    profile.energy -= amount;
    _persist();
    notifyListeners();
    return true;
  }

  /// Applies the outcome of a finished expedition to persistent progress.
  void applyRunResult(RunState run) {
    profile.ore += run.oreCollected;
    profile.crystals += run.crystalsCollected;
    profile.totalRuns += 1;
    if (run.status == RunStatus.defeated) {
      profile.totalExpeditionsFailed += 1;
    }

    final zoneBest = profile.bestDepthByZone[run.zoneId] ?? 0;
    if (run.depthMeters > zoneBest) {
      profile.bestDepthByZone[run.zoneId] = run.depthMeters;
    }
    if (run.depthMeters > profile.bestOverallDepth) {
      profile.bestOverallDepth = run.depthMeters;
    }

    for (final relic in run.relicsFound) {
      profile.ownedRelics.add(relic.id);
    }

    run.enemyDefeatCounts.forEach((id, count) {
      profile.defeatedCounts[id] = (profile.defeatedCounts[id] ?? 0) + count;
    });

    // Update contract progress.
    for (final c in profile.contracts) {
      if (c.claimed) continue;
      switch (c.type) {
        case ContractType.reachDepth:
          if (run.depthMeters > c.progress) c.progress = run.depthMeters;
          break;
        case ContractType.mineOre:
          c.progress += run.oreCollected;
          break;
        case ContractType.mineCrystals:
          c.progress += run.crystalsCollected;
          break;
        case ContractType.defeatEnemies:
          c.progress += run.enemiesDefeated;
          break;
        case ContractType.findRelic:
          c.progress += run.relicsFound.length;
          break;
        case ContractType.noOverheatExpedition:
          if (run.metNoOverheat && run.status != RunStatus.defeated) {
            c.progress = 1;
          }
          break;
      }
      if (c.progress > c.target) c.progress = c.target;
    }

    _persist();
    notifyListeners();
  }

  bool claimContract(ContractInstance contract) {
    if (!contract.isComplete || contract.claimed) return false;
    profile.ore += contract.rewardOre();
    profile.crystals += contract.rewardCrystals();
    contract.claimed = true;
    _persist();
    notifyListeners();
    return true;
  }

  bool get canClaimFreeChest => profile.lastFreeChestDate != _todayKey();

  void claimFreeChest() {
    if (!canClaimFreeChest) return;
    profile.lastFreeChestDate = _todayKey();
    profile.ore += 120;
    profile.crystals += 15;
    _persist();
    notifyListeners();
  }

  bool buyDrillBooster() {
    if (profile.crystals < kDrillBoosterCrystalCost) return false;
    profile.crystals -= kDrillBoosterCrystalCost;
    profile.drillBoosters += 1;
    _persist();
    notifyListeners();
    return true;
  }

  /// Consumes one owned booster for the expedition about to start. Returns
  /// false (and consumes nothing) if none are owned.
  bool consumeDrillBooster() {
    if (profile.drillBoosters <= 0) return false;
    profile.drillBoosters -= 1;
    _persist();
    notifyListeners();
    return true;
  }

  bool exchangeCrystalsForOre(int crystalCost, int oreAmount) {
    if (profile.crystals < crystalCost) return false;
    profile.crystals -= crystalCost;
    profile.ore += oreAmount;
    _persist();
    notifyListeners();
    return true;
  }

  void setMusic(bool enabled) {
    profile.musicOn = enabled;
    AudioService.instance.setMusicEnabled(enabled);
    _persist();
    notifyListeners();
  }

  void setSfx(bool enabled) {
    profile.sfxOn = enabled;
    AudioService.instance.setSfxEnabled(enabled);
    _persist();
    notifyListeners();
  }

  void setVibration(bool enabled) {
    profile.vibrationOn = enabled;
    HapticsService.instance.enabled = enabled;
    _persist();
    notifyListeners();
  }
}
