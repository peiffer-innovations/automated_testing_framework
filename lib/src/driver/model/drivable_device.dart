import 'dart:convert';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:crypto/crypto.dart';
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

@immutable
class DrivableDevice extends JsonClass {
  factory DrivableDevice({
    String secret,
    TestDeviceInfo testDeviceInfo,
  }) {
    var pingTime = DateTime.now();
    return DrivableDevice._internal(
      signature: _createSignature(
        pingTime: pingTime,
        secret: secret,
        testDeviceInfo: testDeviceInfo,
      ),
      pingTime: pingTime,
      testDeviceInfo: testDeviceInfo,
    );
  }

  DrivableDevice._internal({
    @required this.pingTime,
    @required this.signature,
    @required this.testDeviceInfo,
  })  : assert(pingTime != null),
        assert(signature?.isNotEmpty == true),
        assert(testDeviceInfo != null);

  final DateTime pingTime;
  final String signature;
  final TestDeviceInfo testDeviceInfo;

  DrivableDevice fromDynamic(dynamic map) {
    DrivableDevice result;

    if (map != null) {
      result = DrivableDevice._internal(
        pingTime: JsonClass.parseUtcMillis(map['pingTime']),
        signature: map['signature'],
        testDeviceInfo: TestDeviceInfo.fromDynamic(map['testDeviceInfo']),
      );
    }

    return result;
  }

  static String _createSignature({
    @required DateTime pingTime,
    @required TestDeviceInfo testDeviceInfo,
    @required String secret,
  }) =>
      Hmac(sha256, utf8.encode(secret))
          .convert(utf8.encode(json.encode({
            'pingTime': pingTime.millisecondsSinceEpoch,
            'testDeviceInfo': testDeviceInfo.toJson(),
          })))
          .toString();

  String createSignature(String secret) => _createSignature(
        pingTime: pingTime,
        testDeviceInfo: testDeviceInfo,
        secret: secret,
      );

  bool validateSignature(String secret) {
    assert(secret?.isNotEmpty == true);

    return signature == createSignature(secret);
  }

  @override
  Map<String, dynamic> toJson() => {
        'pingTime': pingTime.millisecondsSinceEpoch,
        'signature': signature,
        'testDeviceInfo': testDeviceInfo?.toJson(),
      };
}
