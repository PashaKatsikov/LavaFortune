import 'contract.dart';
import 'drill.dart';
import 'zone.dart';

class PlayerProfile {
  int ore;
  int crystals;
  int energy;
  int energyMax;
  int lastEnergyTimestampMs;

  Set<ZoneId> unlockedZones;
  Map<ZoneId, int> bestDepthByZone;

  Set<DrillId> unlockedDrills;
  DrillId selectedDrill;

  Set<String> unlockedDrillHeads;
  String selectedDrillHead;

  Map<String, int> upgradeLevels;
  Set<String> ownedRelics;
  Map<String, int> defeatedCounts;

  List<ContractInstance> contracts;
  String contractsRefreshDate;

  int totalRuns;
  int totalExpeditionsFailed;
  int bestOverallDepth;

  bool musicOn;
  bool sfxOn;
  bool vibrationOn;

  String lastFreeChestDate;

  PlayerProfile({
    required this.ore,
    required this.crystals,
    required this.energy,
    required this.energyMax,
    required this.lastEnergyTimestampMs,
    required this.unlockedZones,
    required this.bestDepthByZone,
    required this.unlockedDrills,
    required this.selectedDrill,
    required this.unlockedDrillHeads,
    required this.selectedDrillHead,
    required this.upgradeLevels,
    required this.ownedRelics,
    required this.defeatedCounts,
    required this.contracts,
    required this.contractsRefreshDate,
    required this.totalRuns,
    required this.totalExpeditionsFailed,
    required this.bestOverallDepth,
    required this.musicOn,
    required this.sfxOn,
    required this.vibrationOn,
    this.lastFreeChestDate = '',
  });

  factory PlayerProfile.fresh() {
    return PlayerProfile(
      ore: 250,
      crystals: 40,
      energy: 25,
      energyMax: 25,
      lastEnergyTimestampMs: DateTime.now().millisecondsSinceEpoch,
      unlockedZones: {ZoneId.upperTunnels},
      bestDepthByZone: {},
      unlockedDrills: {DrillId.standard},
      selectedDrill: DrillId.standard,
      unlockedDrillHeads: {'standard_head'},
      selectedDrillHead: 'standard_head',
      upgradeLevels: {},
      ownedRelics: {},
      defeatedCounts: {},
      contracts: [],
      contractsRefreshDate: '',
      totalRuns: 0,
      totalExpeditionsFailed: 0,
      bestOverallDepth: 0,
      musicOn: true,
      sfxOn: true,
      vibrationOn: true,
      lastFreeChestDate: '',
    );
  }

  int upgradeLevel(String upgradeId) => upgradeLevels[upgradeId] ?? 0;

  Map<String, dynamic> toJson() => {
        'ore': ore,
        'crystals': crystals,
        'energy': energy,
        'energyMax': energyMax,
        'lastEnergyTimestampMs': lastEnergyTimestampMs,
        'unlockedZones': unlockedZones.map((z) => z.index).toList(),
        'bestDepthByZone': bestDepthByZone.map((k, v) => MapEntry(k.index.toString(), v)),
        'unlockedDrills': unlockedDrills.map((d) => d.index).toList(),
        'selectedDrill': selectedDrill.index,
        'unlockedDrillHeads': unlockedDrillHeads.toList(),
        'selectedDrillHead': selectedDrillHead,
        'upgradeLevels': upgradeLevels,
        'ownedRelics': ownedRelics.toList(),
        'defeatedCounts': defeatedCounts,
        'contracts': contracts.map((c) => c.toJson()).toList(),
        'contractsRefreshDate': contractsRefreshDate,
        'totalRuns': totalRuns,
        'totalExpeditionsFailed': totalExpeditionsFailed,
        'bestOverallDepth': bestOverallDepth,
        'musicOn': musicOn,
        'sfxOn': sfxOn,
        'vibrationOn': vibrationOn,
        'lastFreeChestDate': lastFreeChestDate,
      };

  /// Maps a stored enum index onto [values], dropping entries that no longer
  /// exist so a save written by a different build cannot crash the load.
  static Set<T> _enumSet<T>(Object? stored, List<T> values, T fallback) {
    final result = <T>{};
    if (stored is List) {
      for (final entry in stored) {
        if (entry is int && entry >= 0 && entry < values.length) {
          result.add(values[entry]);
        }
      }
    }
    if (result.isEmpty) result.add(fallback);
    return result;
  }

  static T _enumValue<T>(Object? stored, List<T> values, T fallback) {
    if (stored is int && stored >= 0 && stored < values.length) return values[stored];
    return fallback;
  }

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    final bestDepths = <ZoneId, int>{};
    final storedDepths = json['bestDepthByZone'];
    if (storedDepths is Map) {
      storedDepths.forEach((k, v) {
        final index = int.tryParse('$k');
        if (index == null || index < 0 || index >= ZoneId.values.length) return;
        if (v is int) bestDepths[ZoneId.values[index]] = v;
      });
    }

    final upgradeLevels = <String, int>{};
    final storedUpgrades = json['upgradeLevels'];
    if (storedUpgrades is Map) {
      storedUpgrades.forEach((k, v) {
        if (v is int) upgradeLevels['$k'] = v;
      });
    }

    final defeatedCounts = <String, int>{};
    final storedDefeats = json['defeatedCounts'];
    if (storedDefeats is Map) {
      storedDefeats.forEach((k, v) {
        if (v is int) defeatedCounts['$k'] = v;
      });
    }

    final contracts = <ContractInstance>[];
    final storedContracts = json['contracts'];
    if (storedContracts is List) {
      for (final entry in storedContracts) {
        if (entry is! Map) continue;
        final typeIndex = entry['type'];
        if (typeIndex is! int || typeIndex < 0 || typeIndex >= ContractType.values.length) {
          continue;
        }
        contracts.add(ContractInstance.fromJson(Map<String, dynamic>.from(entry)));
      }
    }

    final drillHeads =
        ((json['unlockedDrillHeads'] as List?) ?? const ['standard_head']).cast<String>().toSet();
    drillHeads.add('standard_head');
    final selectedHead = json['selectedDrillHead'] as String? ?? 'standard_head';

    final unlockedDrills = _enumSet(json['unlockedDrills'], DrillId.values, DrillId.standard);
    final selectedDrill = _enumValue(json['selectedDrill'], DrillId.values, DrillId.standard);

    return PlayerProfile(
      ore: json['ore'] as int? ?? 250,
      crystals: json['crystals'] as int? ?? 40,
      energy: json['energy'] as int? ?? 25,
      energyMax: json['energyMax'] as int? ?? 25,
      lastEnergyTimestampMs:
          json['lastEnergyTimestampMs'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      unlockedZones: _enumSet(json['unlockedZones'], ZoneId.values, ZoneId.upperTunnels),
      bestDepthByZone: bestDepths,
      unlockedDrills: unlockedDrills.contains(selectedDrill)
          ? unlockedDrills
          : (unlockedDrills..add(selectedDrill)),
      selectedDrill: selectedDrill,
      unlockedDrillHeads: drillHeads,
      selectedDrillHead: drillHeads.contains(selectedHead) ? selectedHead : 'standard_head',
      upgradeLevels: upgradeLevels,
      ownedRelics: ((json['ownedRelics'] as List?) ?? []).cast<String>().toSet(),
      defeatedCounts: defeatedCounts,
      contracts: contracts,
      contractsRefreshDate: json['contractsRefreshDate'] as String? ?? '',
      totalRuns: json['totalRuns'] as int? ?? 0,
      totalExpeditionsFailed: json['totalExpeditionsFailed'] as int? ?? 0,
      bestOverallDepth: json['bestOverallDepth'] as int? ?? 0,
      musicOn: json['musicOn'] as bool? ?? true,
      sfxOn: json['sfxOn'] as bool? ?? true,
      vibrationOn: json['vibrationOn'] as bool? ?? true,
      lastFreeChestDate: json['lastFreeChestDate'] as String? ?? '',
    );
  }
}
