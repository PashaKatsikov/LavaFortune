import 'relic.dart';
import 'segment.dart';
import 'zone.dart';

enum RunStatus { running, paused, event, relicFound, victoryClaim, defeated, extracted }

enum DefeatReason { overheat, destroyed, none }

class RunLogEntry {
  final String text;
  final bool positive;
  RunLogEntry(this.text, {this.positive = true});
}

/// Holds all ephemeral state for a single expedition run.
class RunState {
  final ZoneId zoneId;
  double depth = 0;
  double heat = 0;
  double heatMax;
  double hp;
  double hpMax;

  int oreCollected = 0;
  int crystalsCollected = 0;
  int enemiesDefeated = 0;
  final List<RelicDef> relicsFound = [];
  final Map<String, int> enemyDefeatCounts = {};

  RunStatus status = RunStatus.running;
  DefeatReason defeatReason = DefeatReason.none;

  List<LaneOption> currentOptions = [];
  EventDef? activeEvent;
  RelicDef? pendingRelic;
  bool metNoOverheat = true;

  /// The final volcanic monster is offered at most once per expedition.
  bool bossOffered = false;
  bool bossDefeated = false;

  /// Whether a Drill Booster was consumed to start this expedition.
  bool boosterActive = false;

  /// The emergency heat vent can be triggered at most once per expedition.
  bool ventUsed = false;

  final List<RunLogEntry> log = [];

  RunState({
    required this.zoneId,
    required this.heatMax,
    required this.hp,
    required this.hpMax,
  });

  double get heatPercent => heatMax <= 0 ? 0 : (heat / heatMax).clamp(0, 1);
  double get hpPercent => hpMax <= 0 ? 0 : (hp / hpMax).clamp(0, 1);
  int get depthMeters => depth.round();

  void addLog(String text, {bool positive = true}) {
    log.insert(0, RunLogEntry(text, positive: positive));
    if (log.length > 30) log.removeLast();
  }
}
