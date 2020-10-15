import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

@immutable
class DrivableDevice extends JsonClass {
  factory DrivableDevice({
    @required String driverId,
    @required String driverName,
    @required String id,
    @required String secret,
    @required String status,
    @required TestDeviceInfo testDeviceInfo,
  }) {
    id ??= testDeviceInfo.id;
    var pingTime = DateTime.now();
    return DrivableDevice._internal(
      driverId: driverId,
      driverName: driverName,
      id: id,
      pingTime: pingTime,
      signature: _createSignature(
        driverId: driverId,
        id: id,
        pingTime: pingTime,
        secret: secret,
        status: status,
      ),
      status: status,
      testDeviceInfo: testDeviceInfo,
    );
  }

  DrivableDevice._internal({
    @required this.driverId,
    @required this.driverName,
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
  final String driverName;
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
        driverName: map['driverName'],
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
  }) =>
      DriverSignatureHelper().createSignature(
        secret,
        [
          driverId,
          id,
          pingTime.millisecondsSinceEpoch.toString(),
          status,
        ],
      );

  @override
  bool operator ==(dynamic other) => other is DrivableDevice && other.id == id;

  @override
  int get hashCode => id.hashCode;

  String createSignature(String secret) => _createSignature(
        driverId: driverId,
        id: id,
        pingTime: pingTime,
        secret: secret,
        status: status,
      );

  bool validateSignature(String secret) {
    assert(secret?.isNotEmpty == true);

    return signature == createSignature(secret);
  }

  @override
  Map<String, dynamic> toJson() => {
        'driverId': driverId,
        'driverName': driverName,
        'id': id,
        'pingTime': pingTime.millisecondsSinceEpoch,
        'signature': signature,
        'status': status,
        'testDeviceInfo': testDeviceInfo?.toJson(),
      };
}
