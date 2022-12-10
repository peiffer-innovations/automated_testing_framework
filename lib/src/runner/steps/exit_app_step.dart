import 'dart:io';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:json_class/json_class.dart';

/// Test step that exits the application.
class ExitAppStep extends TestRunnerStep {
  static const id = 'exit_app';

  static final List<String> behaviorDrivenDescriptions = List.unmodifiable([
    'exit the application.',
  ]);

  @override
  String get stepId => id;

  /// Creates an instance from a JSON-like map structure.  This expects the
  /// following format:
  ///
  /// ```json
  /// {
  /// }
  /// ```
  ///
  /// See also:
  /// * [JsonClass.parseBool]
  /// * [JsonClass.parseDurationFromSeconds]
  static ExitAppStep? fromDynamic(dynamic map) {
    ExitAppStep? result;

    if (map != null) {
      result = ExitAppStep();
    }

    return result;
  }

  /// Executes the step and exits the application.
  @override
  Future<void> execute({
    required CancelToken cancelToken,
    required TestReport report,
    required TestController tester,
  }) async {
    final name = '$id()';
    log(
      name,
      tester: tester,
    );
    exit(1);
  }

  @override
  String getBehaviorDrivenDescription(TestController tester) =>
      behaviorDrivenDescriptions[0];

  /// Overidden to ignore the delay
  @override
  Future<void> preStepSleep(Duration duration) async {}

  /// Overidden to ignore the delay
  @override
  Future<void> postStepSleep(Duration duration) async {}

  /// Converts this to a JSON compatible map.  For a description of the format,
  /// see [fromDynamic].
  @override
  Map<String, dynamic> toJson() => {};
}
