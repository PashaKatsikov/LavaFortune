enum ContractType {
  reachDepth,
  mineOre,
  mineCrystals,
  defeatEnemies,
  findRelic,
  noOverheatExpedition,
}

class ContractTemplate {
  final ContractType type;
  final String Function(int target) titleBuilder;
  final int Function() rollTarget;
  final int Function(int target) rewardOre;
  final int Function(int target) rewardCrystals;
  final bool daily;

  const ContractTemplate({
    required this.type,
    required this.titleBuilder,
    required this.rollTarget,
    required this.rewardOre,
    required this.rewardCrystals,
    required this.daily,
  });
}

/// A live contract instance tracked in the player's profile.
class ContractInstance {
  final String id;
  final ContractType type;
  final int target;
  final bool daily;
  int progress;
  bool claimed;

  ContractInstance({
    required this.id,
    required this.type,
    required this.target,
    required this.daily,
    this.progress = 0,
    this.claimed = false,
  });

  bool get isComplete => progress >= target;

  String title() {
    switch (type) {
      case ContractType.reachDepth:
        return 'Reach a depth of $target m in a single expedition';
      case ContractType.mineOre:
        return 'Mine $target ore';
      case ContractType.mineCrystals:
        return 'Collect $target crystals';
      case ContractType.defeatEnemies:
        return 'Defeat $target volcanic creatures';
      case ContractType.findRelic:
        return 'Find $target ancient relic(s)';
      case ContractType.noOverheatExpedition:
        return 'Complete an expedition without critical overheat';
    }
  }

  int rewardOre() {
    switch (type) {
      case ContractType.reachDepth:
        return (target * 0.4).round();
      case ContractType.mineOre:
        return (target * 0.5).round();
      case ContractType.mineCrystals:
        return target * 12;
      case ContractType.defeatEnemies:
        return target * 30;
      case ContractType.findRelic:
        return 250;
      case ContractType.noOverheatExpedition:
        return 150;
    }
  }

  int rewardCrystals() {
    switch (type) {
      case ContractType.mineCrystals:
        return (target * 0.5).round();
      case ContractType.findRelic:
        return 40;
      case ContractType.defeatEnemies:
        return (target * 1.5).round();
      default:
        return 0;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.index,
        'target': target,
        'daily': daily,
        'progress': progress,
        'claimed': claimed,
      };

  factory ContractInstance.fromJson(Map<String, dynamic> json) => ContractInstance(
        id: json['id'] as String,
        type: ContractType.values[json['type'] as int],
        target: json['target'] as int,
        daily: json['daily'] as bool? ?? false,
        progress: json['progress'] as int? ?? 0,
        claimed: json['claimed'] as bool? ?? false,
      );
}
