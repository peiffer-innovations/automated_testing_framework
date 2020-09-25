import 'dart:typed_data';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

/// Represents a report from a test run.
class TestReport extends JsonClass {
  TestReport({
    TestDeviceInfo deviceInfo,
    String id,
    this.name,
    this.suiteName,
    this.version,
  })  : deviceInfo = deviceInfo ?? TestDeviceInfo.instance,
        _errorSteps = 0,
        id = id ?? Uuid().v4(),
        _images = [],
        _logs = [],
        _passedSteps = 0,
        startTime = DateTime.now();

  TestReport._internal({
    this.deviceInfo,
    DateTime endTime,
    int errorSteps,
    this.id,
    List<String> logs,
    this.name,
    int passedSteps,
    String runtimeException,
    this.startTime,
    List<TestReportStep> steps,
    this.suiteName,
    this.version,
    List<TestImage> images,
  })  : _endTime = endTime,
        _errorSteps = errorSteps,
        _images = images,
        _logs = logs,
        _passedSteps = passedSteps,
        _runtimeException = runtimeException {
    steps?.forEach((step) => _steps[TestStep(
          id: step.id,
          values: step.step,
        )] = step);
  }

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
  final List<TestImage> _images;

  /// A list of the log entries that happened during the test.
  final List<String> _logs;

  /// Holds a map of steps that have been started, but not finished, to their
  /// metadata.
  final Set<TestStep> _pendingSteps = {};

  /// A list of all the steps executed by the test along with their individual
  /// results.
  final Map<TestStep, TestReportStep> _steps = {};

  int _errorSteps;
  int _passedSteps;
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
  List<TestReportStep> get steps => List.unmodifiable(_steps.values);

  /// Returns an overall status for the report.  This will return [true] if, and
  /// only if, there were no errors encountered within the test.  If any errors
  /// exist, be it step specific or test-wide, this will return [false].
  bool get success {
    var success = runtimeException == null;
    for (var step in steps) {
      success = success && step.error == null;
    }

    return success;
  }

  static TestReport fromDynamic(dynamic map) {
    TestReport result;
    if (map != null) {
      result = TestReport._internal(
        deviceInfo: TestDeviceInfo.fromDynamic(map['deviceInfo']),
        endTime: DateTime.fromMillisecondsSinceEpoch(
          JsonClass.parseInt(map['endTime']),
        ),
        errorSteps: JsonClass.parseInt(map['errorSteps']),
        images: JsonClass.fromDynamicList(
            map['images'], (map) => TestImage.fromDynamic(map)),
        logs: List<String>.from(map['logs']),
        name: map['name'],
        passedSteps: JsonClass.parseInt(map['passedSteps']),
        runtimeException: map['runtimeException'],
        startTime: DateTime.fromMillisecondsSinceEpoch(
          JsonClass.parseInt(map['startTime']),
        ),
        steps: JsonClass.fromDynamicList(
          map['steps'],
          (entry) => TestReportStep.fromDynamic(entry),
        ),
        suiteName: map['suiteName'],
        version: JsonClass.parseInt(map['version']),
      );
    }

    return result;
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

  /// Ends the given [step] with the optional [error].  If the [error] is [null]
  /// then the step is considered successful.  If there is an [error] value then
  /// the step is considered a failure.
  void endStep(
    TestStep step, [
    String error,
  ]) {
    if (_pendingSteps.contains(step)) {
      _pendingSteps.remove(step);
      var reportStep = _steps[step];
      if (reportStep != null) {
        reportStep = reportStep.copyWith(
          endTime: DateTime.now(),
          error: error,
        );
        _steps[step] = reportStep;

        if (error == null) {
          _passedSteps++;
        } else {
          _errorSteps++;
        }
      }
    }
  }

  /// Informs the report that an excetion happened w/in the framework itself.
  /// This is likely a non-recoverable error and should be investigated.
  ///
  /// This will also end all pending steps and mark them as failed using the
  /// given [message] as the error.
  void exception(String message, dynamic e, StackTrace stack) {
    _runtimeException = '$message: $e\n$stack';

    _pendingSteps.forEach((step) => endStep(step));
  }

  /// Starts a step within the report.
  void startStep(
    TestStep step, {
    bool subStep = true,
  }) {
    _pendingSteps.add(step);
    _steps[step] = TestReportStep(
      id: step.id,
      step: step.values,
      subStep: subStep,
    );
  }

  @override
  Map<String, dynamic> toJson([includeImageData = false]) => {
        'deviceInfo': deviceInfo.toJson(),
        'endTime': endTime?.millisecondsSinceEpoch,
        'errorSteps': errorSteps,
        'images': TestImage.toJsonList(images, includeImageData),
        'logs': logs,
        'name': name,
        'passedSteps': passedSteps,
        'runtimeException': runtimeException,
        'startTime': startTime?.millisecondsSinceEpoch,
        'steps': JsonClass.toJsonList(_steps.values.toList()),
        'success': success,
        'suiteName': suiteName,
        'version': version,
      };
}
