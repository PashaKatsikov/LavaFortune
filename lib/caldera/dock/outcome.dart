import 'dart:convert';

/// Persistable boot path. Stored tokens must stay `undecided` /
/// `portal` / `native` so existing installs keep their route.
enum TrailMark {
  undecided,
  portal,
  native;

  String get token {
    if (this == TrailMark.portal) return 'portal';
    if (this == TrailMark.native) return 'native';
    return 'undecided';
  }

  static TrailMark read(String? raw) {
    if (raw == 'portal' || raw == 'web') return TrailMark.portal;
    if (raw == 'native' || raw == 'game') return TrailMark.native;
    return TrailMark.undecided;
  }
}

/// Backend JSON `{ok, url, expires, message}` — key spellings are fixed.
class GateReply {
  const GateReply({
    required this.approved,
    this.url,
    this.expiresAt,
    this.note,
  });

  factory GateReply.rejected(String note) {
    return GateReply(approved: false, note: note);
  }

  factory GateReply.fromJson(Map<String, dynamic> json) {
    final Object? expiry = json['expires'];
    int? until;
    if (expiry is num) {
      until = expiry.toInt();
    } else if (expiry != null) {
      until = int.tryParse(expiry.toString());
    }
    final Object? rawUrl = json['url'];
    return GateReply(
      approved: json['ok'] == true,
      url: rawUrl is String ? rawUrl : null,
      expiresAt: until,
      note: json['message']?.toString(),
    );
  }

  final bool approved;
  final String? url;
  final int? expiresAt;
  final String? note;

  bool get hasDestination {
    if (!approved) return false;
    final String? dest = url;
    return dest != null && dest.isNotEmpty;
  }

  static GateReply decodeBody(String raw) {
    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map) return GateReply.rejected('bad_json');
    return GateReply.fromJson(Map<String, dynamic>.from(decoded));
  }
}

sealed class Docking {
  const Docking();
}

final class NativeDock extends Docking {
  const NativeDock();
}

final class ViewDock extends Docking {
  const ViewDock(this.url, {this.coldTap = false});

  final String url;
  final bool coldTap;
}

final class GapDock extends Docking {
  const GapDock({required this.returnsToGame});

  final bool returnsToGame;
}
