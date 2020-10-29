import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

@immutable
class GoldenTestImages extends JsonClass {
  GoldenTestImages({
    @required this.deviceInfo,
    @required this.goldenHashes,
    String id,
    @required this.suiteName,
    @required this.testName,
    @required this.testVersion,
    DateTime timestamp,
  })  : id = id ??
            createId(
              deviceInfo: deviceInfo,
              suiteName: suiteName,
              testName: testName,
            ),
        timestamp = timestamp ?? DateTime.now();

  final TestDeviceInfo deviceInfo;
  final Map<String, String> goldenHashes;
  final String id;
  final String suiteName;
  final String testName;
  final int testVersion;
  final DateTime timestamp;

  static String createId({
    @required TestDeviceInfo deviceInfo,
    @required String suiteName,
    @required String testName,
  }) {
    var suitePrefix = suiteName?.isNotEmpty == true ? '${suiteName}_' : '';
    return '${suitePrefix}${testName}_${deviceInfo.appIdentifier}_${deviceInfo.os}_${deviceInfo.systemVersion}_${deviceInfo.model}_${deviceInfo.device}_${deviceInfo.orientation}_${deviceInfo.pixels?.height}_${deviceInfo.pixels?.width}';
  }

  static String createIdFromReport(TestReport report) {
    var suiteName = report.suiteName;
    var testName = report.name;
    var deviceInfo = report.deviceInfo;

    return createId(
      deviceInfo: deviceInfo,
      suiteName: suiteName,
      testName: testName,
    );
  }

  static GoldenTestImages fromDynamic(dynamic map) {
    GoldenTestImages result;

    if (map != null) {
      result = GoldenTestImages(
        deviceInfo: TestDeviceInfo.fromDynamic(map['deviceInfo']),
        goldenHashes: map['goldenHashes'] == null
            ? null
            : Map<String, String>.from(map['goldenHashes']),
        id: map['id'],
        suiteName: map['suiteName'],
        testName: map['testName'],
        testVersion: JsonClass.parseInt(map['testVersion']),
        timestamp: JsonClass.parseUtcMillis(map['timestamp']),
      );
    }

    return result;
  }

  static GoldenTestImages fromTestReport(TestReport report) {
    var goldenHashes = <String, String>{};

    for (var image in (report.images ?? <TestImage>[])) {
      if (image.goldenCompatible == true) {
        goldenHashes[image.id] = image.hash;
      }
    }

    return GoldenTestImages(
      deviceInfo: report.deviceInfo,
      goldenHashes: goldenHashes,
      suiteName: report.suiteName,
      testName: report.name,
      testVersion: report.version,
      timestamp: DateTime.now(),
    );
  }

  @override
  bool operator ==(dynamic other) =>
      other is GoldenTestImages && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  Map<String, dynamic> toJson() => {
        'deviceInfo': deviceInfo.toJson(),
        'goldenHashes': goldenHashes,
        'id': id,
        'suiteName': suiteName,
        'testName': testName,
        'testVersion': testVersion,
        'timestamp': timestamp?.millisecondsSinceEpoch,
      };
}
