import 'dart:math';
import 'package:flutter/foundation.dart';
import '../core/assets.dart';
import '../models/drill_stats.dart';
import '../models/enemy.dart';
import '../models/relic.dart';
import '../models/run_state.dart';
import '../models/segment.dart';
import '../models/zone.dart';
import '../services/audio_service.dart';
import '../services/haptics_service.dart';

/// Depth at which the final volcanic monster starts guarding the tunnels
/// inside the Volcano Heart zone.
const double kBossDepthThreshold = 1900;

/// Multipliers applied for the duration of a run when a Drill Booster is
/// consumed at expedition start.
const double kBoosterHeatGainMultiplier = 0.7;
const double kBoosterSpeedMultiplier = 1.25;

class RunProvider extends ChangeNotifier {
  RunState? _run;
  EffectiveStats? _stats;
  final Random _random = Random();
  bool _overheatWarned = false;

  RunState? get run => _run;

  void start(ZoneId zoneId, EffectiveStats stats, {bool boosted = false}) {
    _stats = boosted
        ? EffectiveStats(
            maxHp: stats.maxHp,
            maxHeat: stats.maxHeat,
            collisionPower: stats.collisionPower,
            heatGainMultiplier: stats.heatGainMultiplier * kBoosterHeatGainMultiplier,
            coolingMultiplier: stats.coolingMultiplier,
            resourceMultiplier: stats.resourceMultiplier,
            rareFindChance: stats.rareFindChance,
            speed: stats.speed * kBoosterSpeedMultiplier,
          )
        : stats;
    _overheatWarned = false;
    _run = RunState(
      zoneId: zoneId,
      heatMax: stats.maxHeat,
      hp: stats.maxHp,
      hpMax: stats.maxHp,
    );
    _run!.boosterActive = boosted;
    _run!.addLog(
      boosted ? 'Expedition started with Drill Booster active!' : 'Expedition started.',
    );
    _generateOptions();
    notifyListeners();
  }

  ZoneDef get _zone => zoneById(_run!.zoneId);

  double get _dangerFactor {
    final depth = _run!.depth;
    final zone = _zone;
    return 1.0 + (depth / 500.0) + (zone.minDepth / 900.0);
  }

  /// Rock gets denser and the surrounding magma hotter the deeper the drill
  /// goes, so every heat source scales along with depth and zone.
  double get _heatFactor {
    final depth = _run!.depth;
    return 1.0 + (depth / 1600.0) + (_zone.minDepth / 2600.0);
  }

  bool get _bossAvailable {
    final run = _run!;
    return run.zoneId == ZoneId.volcanoHeart &&
        !run.bossOffered &&
        run.depth >= kBossDepthThreshold;
  }

  void _generateOptions() {
    final run = _run!;
    final options = <LaneOption>[];
    for (int i = 0; i < 3; i++) {
      options.add(_rollLaneOption());
    }
    if (_bossAvailable) {
      final boss = kEnemies.firstWhere((e) => e.category == EnemyCategory.boss);
      options[_random.nextInt(options.length)] = LaneOption(
        type: SegmentType.enemy,
        risk: RiskTier.risky,
        enemy: boss,
        artSeed: _seed(),
      );
      run.bossOffered = true;
      run.addLog('Something enormous stirs in the depths...', positive: false);
    }
    run.currentOptions = options;
  }

  RiskTier _rollRisk() {
    final r = _random.nextDouble();
    if (r < 0.45) return RiskTier.safe;
    if (r < 0.80) return RiskTier.medium;
    return RiskTier.risky;
  }

  LaneOption _rollLaneOption() {
    final tier = _rollRisk();
    final depth = _run!.depth;
    final rand = _random.nextDouble();

    switch (tier) {
      case RiskTier.safe:
        if (rand < 0.50) {
          return LaneOption(type: SegmentType.plainRock, risk: tier, artSeed: _seed());
        } else if (rand < 0.80) {
          return LaneOption(type: SegmentType.oreVein, risk: tier, artSeed: _seed());
        } else if (rand < 0.94) {
          return LaneOption(type: SegmentType.coolingCrystal, risk: tier, artSeed: _seed());
        } else {
          return LaneOption(
            type: SegmentType.enemy,
            risk: tier,
            enemy: _pickEnemy(depth, elite: false, weak: true),
            artSeed: _seed(),
          );
        }
      case RiskTier.medium:
        if (rand < 0.30) {
          return LaneOption(type: SegmentType.hardRock, risk: tier, artSeed: _seed());
        } else if (rand < 0.52) {
          return LaneOption(type: SegmentType.oreVein, risk: tier, artSeed: _seed());
        } else if (rand < 0.74) {
          return LaneOption(type: SegmentType.crystalVein, risk: tier, artSeed: _seed());
        } else if (rand < 0.92) {
          return LaneOption(
            type: SegmentType.enemy,
            risk: tier,
            enemy: _pickEnemy(depth, elite: false, weak: false),
            artSeed: _seed(),
          );
        } else {
          return LaneOption(type: SegmentType.event, risk: tier, artSeed: _seed());
        }
      case RiskTier.risky:
        final eliteChance = depth > 900 ? 0.22 : (depth > 500 ? 0.10 : 0.0);
        if (rand < 0.20) {
          return LaneOption(type: SegmentType.rareOre, risk: tier, artSeed: _seed());
        } else if (rand < 0.42) {
          return LaneOption(type: SegmentType.crystalVein, risk: tier, artSeed: _seed());
        } else if (rand < 0.68) {
          return LaneOption(
            type: SegmentType.enemy,
            risk: tier,
            enemy: _pickEnemy(depth, elite: _random.nextDouble() < eliteChance, weak: false),
            artSeed: _seed(),
          );
        } else if (rand < 0.85) {
          return LaneOption(type: SegmentType.hazard, risk: tier, artSeed: _seed());
        } else if (rand < 0.95 || depth < 300) {
          return LaneOption(type: SegmentType.event, risk: tier, artSeed: _seed());
        } else {
          return LaneOption(type: SegmentType.ancientChamber, risk: tier, artSeed: _seed());
        }
    }
  }

  String _seed() => _random.nextInt(1 << 30).toString();

  EnemyDef _pickEnemy(double depth, {required bool elite, required bool weak}) {
    List<EnemyDef> pool;
    if (elite) {
      pool = kEnemies.where((e) => e.category == EnemyCategory.elite).toList();
    } else if (weak) {
      pool = kEnemies.where((e) => e.category == EnemyCategory.normal).toList();
    } else {
      pool = kEnemies
          .where((e) =>
              e.category == EnemyCategory.normal || e.category == EnemyCategory.special)
          .where((e) => zoneById(e.minZone).minDepth <= depth + 250)
          .toList();
      if (pool.isEmpty) {
        pool = kEnemies.where((e) => e.category == EnemyCategory.normal).toList();
      }
    }
    return pool[_random.nextInt(pool.length)];
  }

  // -------------------- Player actions --------------------

  void chooseLane(int index) {
    final run = _run;
    if (run == null || run.status != RunStatus.running) return;
    if (index < 0 || index >= run.currentOptions.length) return;
    _resolveOption(run.currentOptions[index]);
  }

  void _addDepth() {
    final base = 10.0 + _random.nextDouble() * 6;
    _run!.depth += base * _stats!.speed;
  }

  void _addHeat(double amount) {
    final run = _run!;
    final gained = amount * _stats!.heatGainMultiplier * _heatFactor;
    run.heat = (run.heat + gained).clamp(0, run.heatMax + 40);
    if (run.heat >= run.heatMax) {
      run.heat = run.heatMax;
      run.metNoOverheat = false;
      _fail(DefeatReason.overheat);
      return;
    }
    if (run.heatPercent >= 0.8) {
      if (!_overheatWarned) {
        _overheatWarned = true;
        AudioService.instance.playSfx(GameAssets.sfxOverheatWarning);
        HapticsService.instance.heavy();
        run.addLog('Warning: temperature critical!', positive: false);
      }
    } else {
      _overheatWarned = false;
    }
  }

  void _reduceHeat(double amount) {
    final run = _run!;
    final reduced = amount * _stats!.coolingMultiplier;
    run.heat = (run.heat - reduced).clamp(0, run.heatMax);
    if (run.heatPercent < 0.8) _overheatWarned = false;
  }

  void _damageDrill(double amount) {
    final run = _run!;
    run.hp = (run.hp - amount).clamp(0, run.hpMax);
    HapticsService.instance.medium();
    if (run.hp <= 0) {
      _fail(DefeatReason.destroyed);
    }
  }

  void _fail(DefeatReason reason) {
    final run = _run!;
    run.status = RunStatus.defeated;
    run.defeatReason = reason;
    run.addLog(
      reason == DefeatReason.overheat ? 'Critical overheat!' : 'Drill destroyed!',
      positive: false,
    );
    notifyListeners();
  }

  void _resolveOption(LaneOption option) {
    final run = _run!;
    final danger = _dangerFactor;

    switch (option.type) {
      case SegmentType.plainRock:
        _addDepth();
        _addHeat(2 + _random.nextDouble() * 2);
        final ore = (3 + _random.nextDouble() * 3) * _stats!.resourceMultiplier * danger;
        run.oreCollected += ore.round();
        run.addLog('Drilled through plain rock. +${ore.round()} ore');
        _finishSegment();
        break;

      case SegmentType.hardRock:
        _addDepth();
        _addHeat(9 + _random.nextDouble() * 5);
        final ore = (1 + _random.nextDouble() * 2) * _stats!.resourceMultiplier * danger;
        run.oreCollected += ore.round();
        run.addLog('Bored through hard rock. +${ore.round()} ore, high heat');
        _finishSegment();
        break;

      case SegmentType.oreVein:
        _addDepth();
        _addHeat(4 + _random.nextDouble() * 4);
        final ore = (9 + _random.nextDouble() * 8) * _stats!.resourceMultiplier * danger;
        run.oreCollected += ore.round();
        AudioService.instance.playSfx(GameAssets.sfxResourceCollected);
        run.addLog('Found an ore vein! +${ore.round()} ore', positive: true);
        _finishSegment();
        break;

      case SegmentType.crystalVein:
        _addDepth();
        _addHeat(6 + _random.nextDouble() * 5);
        final crystals = (3 + _random.nextDouble() * 4) * _stats!.resourceMultiplier * danger;
        run.crystalsCollected += crystals.round();
        AudioService.instance.playSfx(GameAssets.sfxResourceCollected);
        run.addLog('Mined a crystal vein! +${crystals.round()} crystals');
        _finishSegment();
        break;

      case SegmentType.rareOre:
        _addDepth();
        _addHeat(11 + _random.nextDouble() * 6);
        final bonus = _random.nextDouble() < _stats!.rareFindChance ? 2.0 : 1.0;
        final ore = (22 + _random.nextDouble() * 14) * _stats!.resourceMultiplier * danger * bonus;
        run.oreCollected += ore.round();
        AudioService.instance.playSfx(GameAssets.sfxRareResource);
        HapticsService.instance.light();
        run.addLog(
          bonus > 1 ? 'Rare ore jackpot! +${ore.round()} ore' : 'Found rare ore! +${ore.round()} ore',
        );
        _finishSegment();
        break;

      case SegmentType.coolingCrystal:
        _addDepth();
        _reduceHeat(22 + _random.nextDouble() * 10);
        final crystals = (1 + _random.nextDouble() * 2) * _stats!.resourceMultiplier;
        run.crystalsCollected += crystals.round();
        AudioService.instance.playSfx(GameAssets.sfxResourceCollected);
        run.addLog('Cooling crystal found. Heat reduced!');
        _finishSegment();
        break;

      case SegmentType.hazard:
        _addDepth();
        _addHeat(18 + _random.nextDouble() * 10);
        if (_random.nextDouble() < 0.35) {
          final dmg = 6 + _random.nextDouble() * 10;
          _damageDrill(dmg);
          run.addLog('Tunnel collapse! -${dmg.round()} hull integrity', positive: false);
        } else {
          run.addLog('Survived an unstable section, but heat spiked.', positive: false);
        }
        if (run.status == RunStatus.running) _finishSegment();
        break;

      case SegmentType.enemy:
        _resolveEnemy(option.enemy!);
        break;

      case SegmentType.event:
        run.status = RunStatus.event;
        run.activeEvent = kEvents.values.elementAt(_random.nextInt(kEvents.length));
        notifyListeners();
        break;

      case SegmentType.ancientChamber:
        _addDepth();
        _addHeat(10 + _random.nextDouble() * 6);
        _grantRelic();
        break;
    }
  }

  void _resolveEnemy(EnemyDef enemy) {
    final run = _run!;
    _addDepth();

    final scaledHp = enemy.baseHp * (1 + (run.depth / 1400));
    final effectiveness = (_stats!.collisionPower / scaledHp).clamp(0.05, 1.4);
    final damageTaken =
        (enemy.baseDamage * (1.5 - effectiveness) * (0.85 + _random.nextDouble() * 0.3))
            .clamp(2.0, enemy.baseDamage * 1.8);

    AudioService.instance.playSfx(GameAssets.sfxEnemyHit);
    _addHeat(enemy.heatOnEncounter * 0.6);
    if (run.status == RunStatus.defeated) return;
    _damageDrill(damageTaken);

    if (run.status == RunStatus.defeated) return;

    run.enemiesDefeated += 1;
    run.enemyDefeatCounts[enemy.id] = (run.enemyDefeatCounts[enemy.id] ?? 0) + 1;
    final isBoss = enemy.category == EnemyCategory.boss;
    final rewardMultiplier = isBoss ? 1.1 : 0.55;
    final reward = (scaledHp * rewardMultiplier * _stats!.resourceMultiplier).round();
    run.oreCollected += reward;
    AudioService.instance.playSfx(GameAssets.sfxEnemyDefeat);
    if (isBoss) {
      run.bossDefeated = true;
      final crystals = (60 * _stats!.resourceMultiplier).round();
      run.crystalsCollected += crystals;
      HapticsService.instance.heavy();
      run.addLog(
        'The Volcanic Monster is defeated! +$reward ore, +$crystals crystals',
        positive: true,
      );
    } else {
      run.addLog(
        'Defeated ${enemy.name}! -${damageTaken.round()} hull, +$reward ore',
        positive: true,
      );
    }
    _finishSegment();
  }

  /// Rarer relics are meant to stay rare, so candidates are weighted instead
  /// of drawn uniformly.
  int _relicWeight(RelicRarity rarity) {
    switch (rarity) {
      case RelicRarity.common:
        return 40;
      case RelicRarity.rare:
        return 26;
      case RelicRarity.epic:
        return 14;
      case RelicRarity.legendary:
        return 5;
    }
  }

  RelicDef _pickRelic(List<RelicDef> candidates) {
    final totalWeight =
        candidates.fold<int>(0, (sum, relic) => sum + _relicWeight(relic.rarity));
    var roll = _random.nextInt(totalWeight);
    for (final relic in candidates) {
      roll -= _relicWeight(relic.rarity);
      if (roll < 0) return relic;
    }
    return candidates.last;
  }

  void _grantRelic() {
    final run = _run!;
    final owned = run.relicsFound.map((r) => r.id).toSet();
    final candidates = kRelics.where((r) => r.minDepth <= run.depth).toList();
    if (candidates.isEmpty) {
      _finishSegment();
      return;
    }
    final fresh = candidates.where((r) => !owned.contains(r.id)).toList();
    final chosen = _pickRelic(fresh.isNotEmpty ? fresh : candidates);
    run.relicsFound.add(chosen);
    run.pendingRelic = chosen;
    run.status = RunStatus.relicFound;
    AudioService.instance.playSfx(GameAssets.sfxMagmaDiscovery);
    HapticsService.instance.medium();
    run.addLog('Ancient relic discovered: ${chosen.name}!');
    notifyListeners();
  }

  void acknowledgeRelic() {
    final run = _run;
    if (run == null || run.status != RunStatus.relicFound) return;
    run.pendingRelic = null;
    run.status = RunStatus.running;
    _finishSegment();
  }

  void resolveEvent(bool accept) {
    final run = _run;
    if (run == null || run.status != RunStatus.event) return;
    final event = run.activeEvent;
    if (event == null) return;
    switch (event.kind) {
      case EventKind.magmaGeyser:
        if (accept) {
          _addHeat(20 + _random.nextDouble() * 10);
          final ore = (18 + _random.nextDouble() * 12) * _stats!.resourceMultiplier;
          run.oreCollected += ore.round();
          run.addLog('Pushed through the geyser! +${ore.round()} rare ore', positive: true);
        } else {
          run.addLog('Bypassed the magma geyser safely.');
        }
        break;
      case EventKind.unstableTunnel:
        if (accept) {
          if (_random.nextDouble() < 0.4) {
            final dmg = 10 + _random.nextDouble() * 14;
            _damageDrill(dmg);
            run.addLog('The tunnel collapsed! -${dmg.round()} hull', positive: false);
          } else {
            _run!.depth += 60;
            run.addLog('Pushed through, gaining bonus depth!');
          }
        } else {
          run.addLog('Took the careful route around the tunnel.');
        }
        break;
      case EventKind.ancientCache:
        if (accept) {
          _addHeat(8 + _random.nextDouble() * 6);
          final ore = (12 + _random.nextDouble() * 8) * _stats!.resourceMultiplier;
          final crystals = (4 + _random.nextDouble() * 4) * _stats!.resourceMultiplier;
          run.oreCollected += ore.round();
          run.crystalsCollected += crystals.round();
          run.addLog('Opened the ancient cache! +${ore.round()} ore, +${crystals.round()} crystals');
        } else {
          run.addLog('Left the ancient cache untouched.');
        }
        break;
      case EventKind.coldVent:
        _reduceHeat(18 + _random.nextDouble() * 10);
        run.addLog('Cooled the drill in the cold vent.');
        break;
      case EventKind.oreSurge:
        _addHeat(6 + _random.nextDouble() * 4);
        final ore = (20 + _random.nextDouble() * 10) * _stats!.resourceMultiplier;
        run.oreCollected += ore.round();
        run.addLog('Rode the ore surge! +${ore.round()} ore');
        break;
    }
    run.activeEvent = null;
    if (run.status == RunStatus.event) {
      run.status = RunStatus.running;
    }
    if (run.status == RunStatus.running) {
      _addDepth();
      _finishSegment();
    } else {
      notifyListeners();
    }
  }

  void _finishSegment() {
    final run = _run!;
    if (run.status != RunStatus.running) {
      notifyListeners();
      return;
    }
    _generateOptions();
    notifyListeners();
  }

  void togglePause() {
    final run = _run;
    if (run == null) return;
    if (run.status == RunStatus.running) {
      run.status = RunStatus.paused;
    } else if (run.status == RunStatus.paused) {
      run.status = RunStatus.running;
    }
    notifyListeners();
  }

  void extract() {
    final run = _run;
    if (run == null) return;
    if (run.status != RunStatus.running && run.status != RunStatus.paused) return;
    run.status = RunStatus.extracted;
    run.addLog('Expedition extracted safely.');
    notifyListeners();
  }

  void reset() {
    _run = null;
    _stats = null;
    _overheatWarned = false;
  }
}
