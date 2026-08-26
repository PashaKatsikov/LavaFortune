enum UpgradeId {
  durability,
  coolingEfficiency,
  maxTemperature,
  collisionPower,
  resourceBonus,
  rareFindChance,
  drillingSpeed,
}

class UpgradeDef {
  final UpgradeId id;
  final String name;
  final String description;
  final int maxLevel;
  final int baseCost;
  final double costGrowth;
  final double perLevelValue;
  final String unit;

  const UpgradeDef({
    required this.id,
    required this.name,
    required this.description,
    required this.maxLevel,
    required this.baseCost,
    required this.costGrowth,
    required this.perLevelValue,
    required this.unit,
  });

  int costForLevel(int currentLevel) {
    return (baseCost * (costGrowth == 1 ? 1 : _pow(costGrowth, currentLevel))).round();
  }

  static double _pow(double base, int exp) {
    double r = 1;
    for (int i = 0; i < exp; i++) {
      r *= base;
    }
    return r;
  }
}

const List<UpgradeDef> kUpgrades = [
  UpgradeDef(
    id: UpgradeId.durability,
    name: 'Durability',
    description: 'Increases maximum drill hull integrity.',
    maxLevel: 10,
    baseCost: 200,
    costGrowth: 1.35,
    perLevelValue: 12,
    unit: 'HP',
  ),
  UpgradeDef(
    id: UpgradeId.coolingEfficiency,
    name: 'Cooling Efficiency',
    description: 'Cooling crystals and cold sections reduce more heat.',
    maxLevel: 10,
    baseCost: 220,
    costGrowth: 1.35,
    perLevelValue: 0.08,
    unit: 'x',
  ),
  UpgradeDef(
    id: UpgradeId.maxTemperature,
    name: 'Max Temperature',
    description: 'Increases the heat threshold before critical overheat.',
    maxLevel: 10,
    baseCost: 250,
    costGrowth: 1.35,
    perLevelValue: 8,
    unit: '°',
  ),
  UpgradeDef(
    id: UpgradeId.collisionPower,
    name: 'Collision Power',
    description: 'Deal more damage against volcanic creatures.',
    maxLevel: 10,
    baseCost: 220,
    costGrowth: 1.35,
    perLevelValue: 2,
    unit: 'dmg',
  ),
  UpgradeDef(
    id: UpgradeId.resourceBonus,
    name: 'Resource Capacity',
    description: 'Increases ore and crystal yield from every route.',
    maxLevel: 10,
    baseCost: 260,
    costGrowth: 1.35,
    perLevelValue: 0.06,
    unit: 'x',
  ),
  UpgradeDef(
    id: UpgradeId.rareFindChance,
    name: 'Rare Find Chance',
    description: 'Increases the chance to find rare ore and relics.',
    maxLevel: 8,
    baseCost: 300,
    costGrowth: 1.4,
    perLevelValue: 0.02,
    unit: '%',
  ),
  UpgradeDef(
    id: UpgradeId.drillingSpeed,
    name: 'Drilling Efficiency',
    description: 'Slightly reduces heat generated while boring through rock.',
    maxLevel: 10,
    baseCost: 220,
    costGrowth: 1.35,
    perLevelValue: 0.03,
    unit: 'x',
  ),
];

UpgradeDef upgradeById(UpgradeId id) => kUpgrades.firstWhere((u) => u.id == id);
