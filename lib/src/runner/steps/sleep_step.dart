import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

/// Simple test step that will sleep for a given period of time.
class SleepStep extends TestRunnerStep {
  SleepStep({
    @required this.timeout,
  })  : assert(timeout != null),
        assert(timeout.inMilliseconds >= 0);

  /// The maximum amount of time to sleep for.
  final Duration timeout;

  /// Creates an instance from a JSON-like map structure.  This expects the
  /// following format:
  ///
  /// ```json
  /// {
  ///   "timeout": <number>
  /// }
  /// ```
  ///
  /// See also:
  /// * [JsonClass.parseDurationFromSeconds]
  static SleepStep fromDynamic(dynamic map) {
    SleepStep result;

    if (map != null) {
      result = SleepStep(
        timeout: JsonClass.parseDurationFromSeconds(map['timeout']),
      );
    }

    return result;
  }

  /// Simply sleeps for the time specified by [timeout].
  @override
  Future<void> execute({
    TestReport report,
    @required TestController tester,
  }) =>
      sleep(
        timeout,
        tester: tester,
      );

  /// Converts this to a JSON compatible map.  For a description of the format,
  /// see [fromDynamic].
  @override
  Map<String, dynamic> toJson() => {
        'timeout': timeout.inSeconds,
      };
}
