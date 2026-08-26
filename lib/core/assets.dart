/// Central registry of asset paths so screens never hardcode raw strings.
class GameAssets {
  GameAssets._();

  static const String _gameplay = 'assets/Lava_Fortune_gameplay_assets';
  static const String _additional = 'assets/Lava_Fortune_additional_assets';
  static const String _sounds = 'assets/Lava_Fortune_sounds_assets';
  static const String _sliced = 'assets/images/sliced';

  // Additional / branding
  static const String gameLogo = '$_additional/Game_Name.webp';
  static const String appIcon = '$_additional/Icon.png';
  static const String verticalLoading = '$_additional/Vertical_Loading_Screen.webp';
  static const String horizontalLoading = '$_additional/Horizontal_Loading_Screen.webp';

  // Backgrounds (zones)
  static const String bgUpperTunnels = '$_gameplay/upper_tunnel_background_asset.webp';
  static const String bgMagmaCaves = '$_gameplay/magma_cave_background_asset.webp';
  static const String bgCrystalDepths = '$_gameplay/crystal_depths_background_asset.webp';
  static const String bgAncientZone = '$_gameplay/ancient_volcanic_zone_background_asset.webp';
  static const String bgVolcanoHeart = '$_gameplay/volcano_heart_background_asset.webp';

  // Drills
  static const String drillMain = '$_gameplay/main_drill_asset.webp';
  static const String drillHeavy = '$_sliced/drill_heavy.png';
  static const String drillThermal = '$_sliced/drill_thermal.png';
  static const String drillRapid = '$_sliced/drill_rapid.png';
  static const String drillBooster = '$_gameplay/drill_booster_asset.webp';

  // Resources / environment
  static const String rareOre = '$_gameplay/rare_volcanic_ore_asset.webp';
  static const String coolingCrystal = '$_gameplay/cooling_crystal_asset.webp';
  static const String coolingSystem = '$_gameplay/cooling_system_asset.webp';
  static const String fuelReservoir = '$_gameplay/fuel_reservoir_asset.webp';
  static const String magmaContainer = '$_gameplay/magma_container_asset.webp';
  static const String resourceContainer = '$_gameplay/resource_container_asset.webp';
  static const String largeDrillingStation = '$_gameplay/large_drilling_station_asset.webp';
  static const String largeMagmaChamber = '$_gameplay/large_magma_chamber_asset.webp';
  static const String largeMagmaCrystal = '$_gameplay/large_magma_crystal_asset.webp';
  static const String volcanoCore = '$_gameplay/volcano_core_asset.webp';

  static const List<String> crystals = [
    '$_sliced/crystal_gold.png',
    '$_sliced/crystal_red.png',
    '$_sliced/crystal_purple.png',
    '$_sliced/crystal_orange.png',
  ];

  static const List<String> rocks = [
    '$_sliced/rock_peak.png',
    '$_sliced/rock_dome.png',
    '$_sliced/rock_stepped.png',
    '$_sliced/rock_tall.png',
  ];

  static const List<String> veins = [
    '$_sliced/vein_tall.png',
    '$_sliced/vein_round.png',
    '$_sliced/vein_spiky.png',
    '$_sliced/vein_wide.png',
  ];

  static const List<String> debris = [
    '$_sliced/debris_1.png',
    '$_sliced/debris_2.png',
    '$_sliced/debris_3.png',
    '$_sliced/debris_4.png',
  ];

  static const List<String> stalagmites = [
    '$_sliced/stalagmite_1.png',
    '$_sliced/stalagmite_2.png',
    '$_sliced/stalagmite_3.png',
    '$_sliced/stalagmite_4.png',
  ];

  static const List<String> magmaCracks = [
    '$_sliced/magma_crack_1.png',
    '$_sliced/magma_crack_2.png',
    '$_sliced/magma_crack_3.png',
    '$_sliced/magma_crack_4.png',
  ];

  // Ancient zone decor
  static const String ancientAltar = '$_gameplay/ancient_altar_asset.webp';
  static const String ancientMechanism = '$_gameplay/ancient_mechanism_asset.webp';
  static const String ancientDoor = '$_gameplay/ancient_volcanic_door_asset.webp';
  static const List<String> columns = [
    '$_sliced/column_1.png',
    '$_sliced/column_2.png',
    '$_sliced/column_3.png',
    '$_sliced/column_4.png',
  ];
  static const List<String> fossils = [
    '$_sliced/fossil_ammonite.png',
    '$_sliced/fossil_skull.png',
    '$_sliced/fossil_trilobite.png',
  ];
  static const List<String> symbols = [
    '$_sliced/symbol_spiral.png',
    '$_sliced/symbol_tree.png',
    '$_sliced/symbol_sun.png',
    '$_sliced/symbol_mountain.png',
  ];

  // Relics
  static const List<String> relicArt = [
    '$_sliced/relic_pendant.png',
    '$_sliced/relic_spiral_disc.png',
    '$_sliced/relic_idol.png',
    '$_sliced/relic_sun_amulet.png',
  ];

  // Creatures
  static const String creatureSmallLava = '$_sliced/creature_small_lava.png';
  static const String creatureStoneCrawler = '$_sliced/creature_stone_crawler.png';
  static const String creatureMagmaPredator = '$_sliced/creature_magma_predator.png';
  static const String creatureObsidianDestroyer = '$_sliced/creature_obsidian_destroyer.png';
  static const String creatureRockBreaker = '$_sliced/creature_rock_breaker.png';
  static const String creatureMagmaGuardian = '$_sliced/creature_magma_guardian.png';
  static const String creatureLavaHunter = '$_sliced/creature_lava_hunter.png';
  static const String creatureCrystalParasite = '$_sliced/creature_crystal_parasite.png';
  static const String eliteObsidianGiant = '$_sliced/elite_obsidian_giant.png';
  static const String eliteMagmaBeast = '$_sliced/elite_magma_beast.png';
  static const String eliteAncientGuardian = '$_sliced/elite_ancient_guardian.png';
  static const String finalBoss = '$_gameplay/main_volcanic_monster_asset.webp';

  // Sounds
  static const String sfxButtonClick = '$_sounds/button_click_asset.mp3';
  static const String sfxDrillImpact = '$_sounds/drill_impact_asset.mp3';
  static const String sfxDrillStart = '$_sounds/drill_start_asset.mp3';
  static const String sfxEnemyDefeat = '$_sounds/enemy_defeat_asset.mp3';
  static const String sfxEnemyHit = '$_sounds/enemy_hit_asset.mp3';
  static const String sfxExpeditionComplete = '$_sounds/expedition_complete_asset.mp3';
  static const String sfxFailure = '$_sounds/failure_asset.mp3';
  static const String sfxMagmaDiscovery = '$_sounds/magma_discovery_asset.mp3';
  static const String sfxMenuSelect = '$_sounds/menu_select_asset.mp3';
  static const String sfxOverheatWarning = '$_sounds/overheat_warning_asset.mp3';
  static const String sfxRareResource = '$_sounds/rare_resource_collected_asset.mp3';
  static const String sfxResourceCollected = '$_sounds/resource_collected_asset.mp3';
  static const String sfxUpgradeComplete = '$_sounds/upgrade_complete_asset.mp3';
}

class GameLinks {
  GameLinks._();

  static const String privacyPolicy = 'https://lavafortune.site/privacy-policy.html';
  static const String support = 'https://lavafortune.site/support.html';
}
