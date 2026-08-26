import 'enemy.dart';

enum SegmentType {
  plainRock,
  hardRock,
  oreVein,
  crystalVein,
  rareOre,
  coolingCrystal,
  enemy,
  hazard,
  event,
  ancientChamber,
}

enum RiskTier { safe, medium, risky }

/// One of the (usually 3) lane choices presented to the player at a fork.
class LaneOption {
  final SegmentType type;
  final RiskTier risk;
  final EnemyDef? enemy;
  final String artSeed;

  LaneOption({
    required this.type,
    required this.risk,
    this.enemy,
    required this.artSeed,
  });
}

enum EventKind { magmaGeyser, unstableTunnel, ancientCache, coldVent, oreSurge }

class EventDef {
  final EventKind kind;
  final String title;
  final String description;
  final String rewardLabel;
  final String riskLabel;

  const EventDef({
    required this.kind,
    required this.title,
    required this.description,
    required this.rewardLabel,
    required this.riskLabel,
  });
}

const Map<EventKind, EventDef> kEvents = {
  EventKind.magmaGeyser: EventDef(
    kind: EventKind.magmaGeyser,
    title: 'Magma Geyser!',
    description: 'A geyser of molten rock erupts ahead, blocking the tunnel.',
    rewardLabel: '+Rare ore',
    riskLabel: '+Heavy heat',
  ),
  EventKind.unstableTunnel: EventDef(
    kind: EventKind.unstableTunnel,
    title: 'Unstable Tunnel!',
    description: 'The tunnel walls are cracking. Pushing forward is risky.',
    rewardLabel: '+Bonus depth',
    riskLabel: '-Hull damage',
  ),
  EventKind.ancientCache: EventDef(
    kind: EventKind.ancientCache,
    title: 'Ancient Cache',
    description: 'A sealed ancient container is embedded in the rock.',
    rewardLabel: '+Ore & crystals',
    riskLabel: 'Takes time (+heat)',
  ),
  EventKind.coldVent: EventDef(
    kind: EventKind.coldVent,
    title: 'Cold Vent',
    description: 'A rare vent of cool air flows through the rock.',
    rewardLabel: '-Heat',
    riskLabel: 'None',
  ),
  EventKind.oreSurge: EventDef(
    kind: EventKind.oreSurge,
    title: 'Ore Surge',
    description: 'A rich vein of ore runs right through this section.',
    rewardLabel: '++Ore',
    riskLabel: '+Mild heat',
  ),
};
