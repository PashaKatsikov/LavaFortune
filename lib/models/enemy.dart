import '../core/assets.dart';
import 'zone.dart';

enum EnemyCategory { normal, special, elite, boss }

class EnemyDef {
  final String id;
  final String name;
  final String art;
  final int baseHp;
  final int baseDamage;
  final double heatOnEncounter;
  final EnemyCategory category;
  final String description;
  final ZoneId minZone;

  const EnemyDef({
    required this.id,
    required this.name,
    required this.art,
    required this.baseHp,
    required this.baseDamage,
    required this.heatOnEncounter,
    required this.category,
    required this.description,
    required this.minZone,
  });
}

const List<EnemyDef> kEnemies = [
  EnemyDef(
    id: 'small_lava_creature',
    name: 'Small Lava Creature',
    art: GameAssets.creatureSmallLava,
    baseHp: 18,
    baseDamage: 6,
    heatOnEncounter: 6,
    category: EnemyCategory.normal,
    description: 'Fast moving critter with a small pool of health.',
    minZone: ZoneId.upperTunnels,
  ),
  EnemyDef(
    id: 'stone_crawler',
    name: 'Stone Crawler',
    art: GameAssets.creatureStoneCrawler,
    baseHp: 34,
    baseDamage: 8,
    heatOnEncounter: 5,
    category: EnemyCategory.normal,
    description: 'Slow but sturdy, covered in thick volcanic plating.',
    minZone: ZoneId.upperTunnels,
  ),
  EnemyDef(
    id: 'magma_predator',
    name: 'Magma Predator',
    art: GameAssets.creatureMagmaPredator,
    baseHp: 26,
    baseDamage: 10,
    heatOnEncounter: 8,
    category: EnemyCategory.normal,
    description: 'Quick predator able to close the distance in an instant.',
    minZone: ZoneId.magmaCaves,
  ),
  EnemyDef(
    id: 'obsidian_destroyer',
    name: 'Obsidian Destroyer',
    art: GameAssets.creatureObsidianDestroyer,
    baseHp: 55,
    baseDamage: 16,
    heatOnEncounter: 7,
    category: EnemyCategory.normal,
    description: 'Slow armored brute that deals heavy damage on impact.',
    minZone: ZoneId.magmaCaves,
  ),
  EnemyDef(
    id: 'lava_hunter',
    name: 'Lava Hunter',
    art: GameAssets.creatureLavaHunter,
    baseHp: 42,
    baseDamage: 12,
    heatOnEncounter: 9,
    category: EnemyCategory.special,
    description: 'Relentlessly pursues the drill through the tunnels.',
    minZone: ZoneId.magmaCaves,
  ),
  EnemyDef(
    id: 'magma_guardian',
    name: 'Magma Guardian',
    art: GameAssets.creatureMagmaGuardian,
    baseHp: 70,
    baseDamage: 14,
    heatOnEncounter: 10,
    category: EnemyCategory.special,
    description: 'Guards valuable resource veins with high durability.',
    minZone: ZoneId.crystalDepths,
  ),
  EnemyDef(
    id: 'crystal_parasite',
    name: 'Crystal Parasite',
    art: GameAssets.creatureCrystalParasite,
    baseHp: 38,
    baseDamage: 11,
    heatOnEncounter: 7,
    category: EnemyCategory.special,
    description: 'Found nesting near large crystalline veins.',
    minZone: ZoneId.crystalDepths,
  ),
  EnemyDef(
    id: 'rock_breaker',
    name: 'Rock Breaker',
    art: GameAssets.creatureRockBreaker,
    baseHp: 48,
    baseDamage: 18,
    heatOnEncounter: 8,
    category: EnemyCategory.special,
    description: 'Specializes in damaging drilling equipment directly.',
    minZone: ZoneId.ancientZone,
  ),
  EnemyDef(
    id: 'obsidian_giant',
    name: 'Obsidian Giant',
    art: GameAssets.eliteObsidianGiant,
    baseHp: 140,
    baseDamage: 24,
    heatOnEncounter: 14,
    category: EnemyCategory.elite,
    description: 'An enormous armored elite with immense durability.',
    minZone: ZoneId.ancientZone,
  ),
  EnemyDef(
    id: 'magma_beast',
    name: 'Magma Beast',
    art: GameAssets.eliteMagmaBeast,
    baseHp: 110,
    baseDamage: 30,
    heatOnEncounter: 16,
    category: EnemyCategory.elite,
    description: 'A fast elite predator with devastating attacks.',
    minZone: ZoneId.ancientZone,
  ),
  EnemyDef(
    id: 'ancient_guardian',
    name: 'Ancient Volcanic Guardian',
    art: GameAssets.eliteAncientGuardian,
    baseHp: 160,
    baseDamage: 26,
    heatOnEncounter: 15,
    category: EnemyCategory.elite,
    description: 'An elite construct of the ancient civilization, guarding relics.',
    minZone: ZoneId.volcanoHeart,
  ),
  EnemyDef(
    id: 'volcanic_monster',
    name: 'The Volcanic Monster',
    art: GameAssets.finalBoss,
    baseHp: 500,
    baseDamage: 40,
    heatOnEncounter: 25,
    category: EnemyCategory.boss,
    description: 'The ancient beast slumbering at the heart of the volcano.',
    minZone: ZoneId.volcanoHeart,
  ),
];
