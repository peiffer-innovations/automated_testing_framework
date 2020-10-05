import 'dart:convert';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:crypto/crypto.dart';
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

@immutable
class DriverTestRequest extends JsonClass {
  factory DriverTestRequest({
    @required String secret,
    @required List<Test> tests,
  }) {
    var timestamp = DateTime.now();
    var signature = _createSignature(
      secret: secret,
      timestamp: timestamp,
    );

    return DriverTestRequest._internal(
      signature: signature,
      tests: tests,
      timestamp: timestamp,
    );
  }

  DriverTestRequest._internal({
    @required this.signature,
    @required this.tests,
    @required this.timestamp,
  });

  final String signature;
  final List<Test> tests;
  final DateTime timestamp;

  static DriverTestRequest fromDynamic(dynamic map) {
    DriverTestRequest result;

    if (map != null) {
      result = DriverTestRequest._internal(
        signature: map['signature'],
        tests: JsonClass.fromDynamicList(
          map['tests'],
          (map) => Test.fromDynamic(map),
        ),
        timestamp: JsonClass.parseUtcMillis(
          map['timestamp'],
        ),
      );
    }

    return result;
  }

  static String _createSignature({
    @required String secret,
    @required DateTime timestamp,
  }) =>
      Hmac(sha256, utf8.encode(secret))
          .convert(utf8.encode(json.encode({
            'timestamp': timestamp.millisecondsSinceEpoch,
          })))
          .toString();

  String createSignature(String secret) => _createSignature(
        secret: secret,
        timestamp: timestamp,
      );

  bool validateSignature(String secret) {
    assert(secret?.isNotEmpty == true);

    return signature == createSignature(secret);
  }

  @override
  Map<String, dynamic> toJson() => {
        'signature': signature,
        'tests': JsonClass.toJsonList(tests),
        'timestamp': timestamp.millisecondsSinceEpoch,
      };
}
