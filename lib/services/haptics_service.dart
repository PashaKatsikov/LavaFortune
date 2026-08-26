import 'package:flutter/services.dart';

/// Thin wrapper over Flutter's built-in haptic feedback so we don't need
/// extra native permissions beyond the standard vibration permission.
class HapticsService {
  HapticsService._internal();
  static final HapticsService instance = HapticsService._internal();

  bool enabled = true;

  void light() {
    if (!enabled) return;
    HapticFeedback.lightImpact();
  }

  void medium() {
    if (!enabled) return;
    HapticFeedback.mediumImpact();
  }

  void heavy() {
    if (!enabled) return;
    HapticFeedback.heavyImpact();
  }

  void selection() {
    if (!enabled) return;
    HapticFeedback.selectionClick();
  }
}
