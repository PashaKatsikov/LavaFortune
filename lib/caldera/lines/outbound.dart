import 'package:http/http.dart' as http;

import 'ua.dart';

/// Outbound HTTP helper. Forces the primed device UA onto every
/// request so nothing leaves with the default `dart-io` header.
class BoreClient extends http.BaseClient {
  BoreClient({http.Client? transport})
      : _transport = transport ?? http.Client();

  final http.Client _transport;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final String ua = DeviceSignature.userAgent;
    final String? current = request.headers['User-Agent'];
    if (current != ua) {
      request.headers['User-Agent'] = ua;
    }
    return _transport.send(request);
  }

  @override
  void close() {
    _transport.close();
  }
}

BoreClient? _sharedClient;

BoreClient get boreHttp => _sharedClient ??= BoreClient();
