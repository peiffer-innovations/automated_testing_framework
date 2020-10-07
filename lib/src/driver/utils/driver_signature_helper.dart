import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:pointycastle/export.dart';

/// Helper class to generate signatures for use by test drivers as well as
/// driven devices.
class DriverSignatureHelper {
  factory DriverSignatureHelper() => _singleton;
  DriverSignatureHelper._internal();

  static final DriverSignatureHelper _singleton =
      DriverSignatureHelper._internal();

  /// Returns a HEX encode HMAC-256 signature for the list of [args] using the
  /// given [secret] key.
  String createSignature(String secret, List<String> args) {
    // for HMAC SHA-256, block length must be 64
    final hmac = HMac(SHA256Digest(), 64)
      ..init(KeyParameter(utf8.encode(secret)));

    var data = utf8.encode(args.join('|'));

    return hex.encode(hmac.process(data));
  }
}
