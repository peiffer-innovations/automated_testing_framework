import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

@immutable
class DrivenTestStatus extends JsonClass {
  DrivenTestStatus({
    this.complete = false,
    @required this.deviceInfo,
    @required this.driverId,
    this.pending = false,
    this.progress = 0.0,
    this.running = false,
    this.status,
    @required this.suiteName,
    @required this.testName,
    this.testPassed,
    @required this.testVersion,
    DateTime timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory DrivenTestStatus.fromTest({
    bool complete = false,
    @required TestDeviceInfo deviceInfo,
    @required String driverId,
    bool pending = false,
    double progress = 0.0,
    bool running = false,
    String status,
    @required Test test,
    bool testPassed,
  }) =>
      DrivenTestStatus(
        complete: complete,
        deviceInfo: deviceInfo,
        driverId: driverId,
        pending: pending,
        progress: progress,
        running: running,
        status: status,
        suiteName: test.suiteName,
        testName: test.name,
        testPassed: testPassed,
        testVersion: test.version,
      );

  final bool complete;
  final TestDeviceInfo deviceInfo;
  final String driverId;
  final bool pending;
  final double progress;
  final bool running;
  final String status;
  final String suiteName;
  final String testName;
  final bool testPassed;
  final int testVersion;
  final DateTime timestamp;

  static DrivenTestStatus fromDynamic(dynamic map) {
    DrivenTestStatus result;

    if (map != null) {
      result = DrivenTestStatus(
        complete: JsonClass.parseBool(map['complete']),
        deviceInfo: TestDeviceInfo.fromDynamic(map['deviceInfo']),
        driverId: map['driverId'],
        pending: JsonClass.parseBool(map['pending']),
        progress: JsonClass.parseDouble(map['progress']),
        running: JsonClass.parseBool(map['running']),
        status: map['status'],
        suiteName: map['suiteName'],
        testName: map['testName'],
        testPassed: map['testPassed'],
        testVersion: JsonClass.parseInt(map['testVersion'], 0),
        timestamp: JsonClass.parseUtcMillis(
          map['timestamp'],
        ),
      );
    }

    return result;
  }

  @override
  Map<String, dynamic> toJson() => {
        'complete': complete,
        'deviceInfo': deviceInfo?.toJson(),
        'driverId': driverId,
        'pending': pending,
        'progress': progress,
        'running': running,
        'status': status,
        'suiteName': suiteName,
        'testName': testName,
        'testPassed': testPassed,
        'testVersion': testVersion,
        'timestamp': timestamp?.millisecondsSinceEpoch,
      };
}
