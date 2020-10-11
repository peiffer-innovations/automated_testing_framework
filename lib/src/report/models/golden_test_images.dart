import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

@immutable
class GoldenTestImages extends JsonClass {
  GoldenTestImages({
    @required this.deviceInfo,
    @required this.goldenHashes,
    @required this.suiteName,
    @required this.testName,
    @required this.testVersion,
    DateTime timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  final TestDeviceInfo deviceInfo;
  final Map<String, String> goldenHashes;
  final String suiteName;
  final String testName;
  final int testVersion;
  final DateTime timestamp;

  static GoldenTestImages fromDynamic(dynamic map) {
    GoldenTestImages result;

    if (map != null) {
      result = GoldenTestImages(
        deviceInfo: TestDeviceInfo.fromDynamic(map['deviceInfo']),
        goldenHashes: map['goldenHashes'] == null
            ? null
            : Map<String, String>.from(map['goldenHashes']),
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
  Map<String, dynamic> toJson() => {
        'deviceInfo': deviceInfo.toJson(),
        'goldenHashes': goldenHashes,
        'suiteName': suiteName,
        'testName': testName,
        'testVersion': testVersion,
        'timestamp': timestamp?.millisecondsSinceEpoch,
      };
}
