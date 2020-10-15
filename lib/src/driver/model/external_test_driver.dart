import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

@immutable
class ExternalTestDriver extends JsonClass {
  factory ExternalTestDriver({
    @required String id,
    @required String name,
    @required String secret,
  }) {
    var pingTime = DateTime.now();

    return ExternalTestDriver._internal(
      id: id,
      name: name,
      pingTime: pingTime,
      signature: _createSignature(
        id: id,
        name: name,
        pingTime: pingTime,
        secret: secret,
      ),
    );
  }

  ExternalTestDriver._internal({
    @required this.id,
    @required this.name,
    @required this.pingTime,
    @required this.signature,
  })  : assert(id?.isNotEmpty == true),
        assert(name?.isNotEmpty == true),
        assert(pingTime != null),
        assert(signature?.isNotEmpty == true);

  final String id;
  final String name;
  final DateTime pingTime;
  final String signature;

  static ExternalTestDriver fromDynamic(dynamic map) {
    ExternalTestDriver result;

    if (map != null) {
      result = ExternalTestDriver._internal(
        id: map['id'],
        name: map['name'],
        pingTime: JsonClass.parseUtcMillis(map['pingTime']),
        signature: map['signature'],
      );
    }

    return result;
  }

  static String _createSignature({
    @required String id,
    @required String name,
    @required DateTime pingTime,
    @required String secret,
  }) =>
      DriverSignatureHelper().createSignature(
        secret,
        [
          id,
          name,
          pingTime.millisecondsSinceEpoch.toString(),
        ],
      );

  @override
  bool operator ==(dynamic other) => other is DrivableDevice && other.id == id;

  @override
  int get hashCode => id.hashCode;

  String createSignature(String secret) => _createSignature(
        id: id,
        name: name,
        pingTime: pingTime,
        secret: secret,
      );

  bool validateSignature(String secret) {
    assert(secret?.isNotEmpty == true);

    return signature == createSignature(secret);
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'pingTime': pingTime.millisecondsSinceEpoch,
        'signature': signature,
      };
}
