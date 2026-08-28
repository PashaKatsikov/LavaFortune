import 'dart:convert';

import '../brief/spec.dart';
import '../dock/outcome.dart';
import 'outbound.dart';
import 'vault.dart';

/// POSTs the composed body to the config endpoint and caches a
/// destination URL when the reply is approved.
class GateAsk {
  GateAsk(this._vault);

  final BeaconKeystore _vault;

  static const Map<String, String> _jsonHeaders = <String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Future<GateReply> ask(Map<String, dynamic> body) async {
    final String endpoint = RelayConfig.endpointUrl;
    if (endpoint.isEmpty) {
      return GateReply.rejected('no_endpoint');
    }

    final Uri? uri = Uri.tryParse(endpoint);
    if (uri == null) {
      return GateReply.rejected('bad_endpoint');
    }

    try {
      final dynamic response = await boreHttp
          .post(
            uri,
            headers: _jsonHeaders,
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: RelayConfig.verdictTimeoutSeconds));

      final int code = response.statusCode as int;
      if (code != 200) {
        return GateReply.rejected('status_$code');
      }
      return _accept(response.body);
    } on FormatException {
      return GateReply.rejected('bad_json');
    } catch (error) {
      return GateReply.rejected('transport:$error');
    }
  }

  Future<GateReply> _accept(String raw) async {
    final GateReply reply = GateReply.decodeBody(raw);
    if (reply.hasDestination) {
      await _vault.cacheDestination(reply.url!, reply.expiresAt);
    }
    return reply;
  }
}
