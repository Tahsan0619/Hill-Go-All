import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// Optional TLS pinning for release builds.
///
/// `--dart-define=HILLGO_SSL_PINS=sha256/<base64>,sha256/<base64>`
/// When empty, the platform trust store is used (debug default).
///
/// Adapted from `Hill Go Main Customer App/lib/services/api/pinned_http.dart`
/// for the Courier Agent App's API layer.
class PinnedHttp {
  PinnedHttp._();

  static http.Client? _cached;

  static http.Client client() {
    if (kIsWeb) return http.Client();
    return _cached ??= _build();
  }

  static http.Client _build() {
    const raw = String.fromEnvironment('HILLGO_SSL_PINS');
    final pins = raw
        .split(',')
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toSet();
    if (pins.isEmpty) return http.Client();

    final io = HttpClient();
    io.badCertificateCallback = (cert, host, port) {
      final sha = base64.encode(sha256.convert(cert.der).bytes);
      final candidates = {'sha256/$sha', sha};
      return pins.intersection(candidates).isNotEmpty;
    };
    // Also enforce pin on otherwise-trusted certs via a wrapping client.
    return _EnforcingClient(io, pins);
  }
}

class _EnforcingClient extends IOClient {
  _EnforcingClient(super.inner, this._pins);

  final Set<String> _pins;

  @override
  Future<IOStreamedResponse> send(http.BaseRequest request) async {
    if (request.url.scheme == 'https') {
      final probe = HttpClient();
      try {
        final uri = Uri(
          scheme: 'https',
          host: request.url.host,
          port: request.url.hasPort ? request.url.port : 443,
          path: '/',
        );
        final req = await probe.getUrl(uri);
        req.followRedirects = false;
        final res = await req.close();
        final cert = res.certificate;
        await res.drain<void>();
        if (cert == null) {
          throw const HttpException('TLS certificate missing');
        }
        final sha = base64.encode(sha256.convert(cert.der).bytes).toLowerCase();
        if (!_pins.contains('sha256/$sha') && !_pins.contains(sha)) {
          throw const HttpException('Certificate pin mismatch');
        }
      } finally {
        probe.close(force: true);
      }
    }
    return super.send(request);
  }
}
