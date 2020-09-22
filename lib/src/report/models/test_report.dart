import 'dart:typed_data';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

/// Represents a report from a test run.
class TestReport {
  TestReport({
    TestDeviceInfo deviceInfo,
    String id,
    this.name,
    this.suiteName,
    this.version,
  })  : deviceInfo = deviceInfo ?? TestDeviceInfo.instance,
        id = id ?? Uuid().v4(),
        startTime = DateTime.now();

  /// Information about the app and device the test is executing on.
  final TestDeviceInfo deviceInfo;

  /// The unique identifier for the report.  If not specifically set then this
  /// will be an auto-generated UUID.
  final String id;

  /// The name of the test
  final String name;

  /// The date time the test started.
  final DateTime startTime;

  /// The test suite for the report.
  final String suiteName;

  /// The version of the test
  final int version;

  /// A list of all screencaptures requested by the test
  final List<TestImage> _images = [];

  /// A list of the log entries that happened during the test.
  final List<String> _logs = [];

  /// A list of all the steps executed by the test along with their individual
  /// results.
  final List<TestReportStep> _steps = [];

  TestReportStep _current;
  int _errorSteps = 0;
  int _passedSteps = 0;
  DateTime _endTime;
  String _runtimeException;

  /// The date time the test was completed.
  DateTime get endTime => _endTime;

  /// The number of steps that encountered an error and failed.
  int get errorSteps => _errorSteps;

  /// The number of steps that had no errors and successfully passed.
  int get passedSteps => _passedSteps;

  /// Returns the list of images that were screen captured via the test.
  List<TestImage> get images => List.unmodifiable(_images);

  /// Returns the unmodifiable list of log entires from the report.
  List<String> get logs => List.unmodifiable(_logs);

  /// Returns the runtime exception that aborted the test.  This will only be
  /// populated if the framework itself encountered a fatal issue (such as a
  /// malformed JSON body for a test step).  If this is populated, a developer
  /// should investicate because this is not a typical error that would be
  /// expected due to failed test runs.
  String get runtimeException => _runtimeException;

  /// Returns the list of test steps in an unmodifiable [List].
  List<TestReportStep> get steps => List.unmodifiable(_steps);

  /// Returns an overall status for the report.  This will return [true] if, and
  /// only if, there were no errors encountered within the test.  If any errors
  /// exist, be it step specific or test-wide, this will return [false].
  bool get success {
    var success = runtimeException == null;
    for (var step in _steps) {
      success = success && step.error == null;
    }

    return success;
  }

  /// Appends the log entry to the test report.
  void appendLog(String log) => _logs.add(log);

  /// Attaches the given screenshot to the test report.
  void attachScreenshot(
    Uint8List screenshot, {
    @required bool goldenCompatible,
    @required String id,
  }) =>
      _images.add(TestImage(
        goldenCompatible: goldenCompatible,
        id: id,
        image: screenshot,
      ));

  /// Completes the test and locks in the end time to now.
  void complete() => _endTime = DateTime.now();

  /// Ends the current step with the optional [error].  If the [error] is [null]
  /// then the step is considered successful.  If there is an [error] value then
  /// the step is considered a failure.
  void endStep([String error]) {
    if (_current != null) {
      _current = _current.copyWith(
        endTime: DateTime.now(),
        error: error,
      );
      _steps.add(_current);

      if (error == null) {
        _passedSteps++;
      } else {
        _errorSteps++;
      }
      _current = null;
    }
  }

  /// Informs the report that an excetion happened w/in the framework itself.
  /// This is likely a non-recoverable error and should be investigated.
  void exception(String message, dynamic e, StackTrace stack) =>
      _runtimeException = '$message: $e\n$stack';

  /// Starts a step within the report.
  void startStep({
    @required String id,
    @required Map<String, dynamic> step,
  }) =>
      _current = TestReportStep(
        id: id,
        step: step,
      );
}
