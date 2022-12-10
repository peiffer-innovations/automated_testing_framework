import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:json_class/json_class.dart';

/// Simple test step that will sleep for a given period of time.
class SleepStep extends TestRunnerStep {
  SleepStep({
    required this.timeout,
  }) : assert(timeout.inMilliseconds >= 0);

  static const id = 'sleep';

  static List<String> get behaviorDrivenDescriptions => List.unmodifiable([
        'sleep for `{{timeout}}` seconds.',
      ]);

  /// The maximum amount of time to sleep for.
  final Duration timeout;

  @override
  String get stepId => id;

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
  static SleepStep? fromDynamic(dynamic map) {
    SleepStep? result;

    if (map != null) {
      result = SleepStep(
        timeout: JsonClass.parseDurationFromSeconds(map['timeout'])!,
      );
    }

    return result;
  }

  /// Simply sleeps for the time specified by [timeout].
  @override
  Future<void> execute({
    CancelToken? cancelToken,
    TestReport? report,
    required TestController tester,
  }) async {
    final name = "$id('${timeout.inMilliseconds}')";
    log(
      name,
      tester: tester,
    );
    if (cancelToken?.cancelled == true) {
      throw Exception('[CANCELLED]: step was cancelled by the test');
    }
    await sleep(
      timeout,
      cancelStream: cancelToken?.stream,
      tester: tester,
    );
  }

  @override
  String getBehaviorDrivenDescription(TestController tester) =>
      behaviorDrivenDescriptions[0].replaceAll(
        '{{timeout}}',
        timeout.inSeconds.toString(),
      );

  /// Overidden to ignore the delay
  @override
  Future<void> preStepSleep(Duration duration) async {}

  /// Overidden to ignore the delay
  @override
  Future<void> postStepSleep(Duration duration) async {}

  /// Converts this to a JSON compatible map.  For a description of the format,
  /// see [fromDynamic].
  @override
  Map<String, dynamic> toJson() => {
        'timeout': timeout.inSeconds,
      };
}
