import 'dart:convert';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:crypto/crypto.dart';
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

@immutable
class DrivableDevice extends JsonClass {
  factory DrivableDevice({
    @required String driverId,
    @required String id,
    @required String secret,
    @required String status,
    @required TestDeviceInfo testDeviceInfo,
  }) {
    id ??= testDeviceInfo.id;
    var pingTime = DateTime.now();
    return DrivableDevice._internal(
      driverId: driverId,
      id: id,
      pingTime: pingTime,
      signature: _createSignature(
        driverId: driverId,
        id: id,
        pingTime: pingTime,
        secret: secret,
        status: status,
        testDeviceInfo: testDeviceInfo,
      ),
      status: status,
      testDeviceInfo: testDeviceInfo,
    );
  }

  DrivableDevice._internal({
    @required this.driverId,
    String id,
    @required this.pingTime,
    @required this.signature,
    @required this.status,
    @required this.testDeviceInfo,
  })  : id = id ?? testDeviceInfo.id,
        assert(pingTime != null),
        assert(signature?.isNotEmpty == true),
        assert(testDeviceInfo != null);

  final String driverId;
  final String id;
  final DateTime pingTime;
  final String signature;
  final String status;
  final TestDeviceInfo testDeviceInfo;

  static DrivableDevice fromDynamic(dynamic map) {
    DrivableDevice result;

    if (map != null) {
      result = DrivableDevice._internal(
        driverId: map['driverId'],
        id: map['id'],
        pingTime: JsonClass.parseUtcMillis(map['pingTime']),
        signature: map['signature'],
        status: map['status'],
        testDeviceInfo: TestDeviceInfo.fromDynamic(map['testDeviceInfo']),
      );
    }

    return result;
  }

  static String _createSignature({
    @required String driverId,
    @required String id,
    @required DateTime pingTime,
    @required String secret,
    @required String status,
    @required TestDeviceInfo testDeviceInfo,
  }) =>
      Hmac(sha256, utf8.encode(secret))
          .convert(utf8.encode(json.encode({
            'driverId': driverId,
            'id': id,
            'pingTime': pingTime.millisecondsSinceEpoch,
            'status': status,
            'testDeviceInfo': testDeviceInfo.toJson(),
          })))
          .toString();

  String createSignature(String secret) => _createSignature(
        driverId: driverId,
        id: id,
        pingTime: pingTime,
        secret: secret,
        status: status,
        testDeviceInfo: testDeviceInfo,
      );

  bool validateSignature(String secret) {
    assert(secret?.isNotEmpty == true);

    return signature == createSignature(secret);
  }

  @override
  Map<String, dynamic> toJson() => {
        'driverId': driverId,
        'id': id,
        'pingTime': pingTime.millisecondsSinceEpoch,
        'signature': signature,
        'status': status,
        'testDeviceInfo': testDeviceInfo?.toJson(),
      };
}
