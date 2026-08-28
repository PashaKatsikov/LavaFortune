// ============================================================
// AppAssets — relay-stage backgrounds (boot / permission / offline)
// ============================================================
// White-part gameplay art lives in `lib/core/assets.dart` (GameAssets).
// This file is the ONLY place gray stages may read asset paths from.
// ============================================================

/// Centralized asset paths for relay stages.
class AppAssets {
  AppAssets._();

  static const String _extra = 'assets/Lava_Fortune_additional_assets';

  static const String verticalLoading = '$_extra/Vertical_Loading_Screen.webp';
  static const String horizontalLoading =
      '$_extra/Horizontal_Loading_Screen.webp';
  // The offline stage is painted, not photographed — no nowifi art.
  static const String verticalNotifications =
      '$_extra/Vertical_Notifications_Screen.webp';
  static const String horizontalNotifications =
      '$_extra/Horizontal_Notifications_Screen.webp';

  static const List<String> all = <String>[
    verticalLoading,
    horizontalLoading,
    verticalNotifications,
    horizontalNotifications,
  ];
}
