import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:json_class/json_class.dart';

/// Test step that ensures a particular widget exists on the widget tree before
/// continuing.
class EnsureExistsStep extends TestRunnerStep {
  EnsureExistsStep({
    required this.testableId,
    this.timeout,
  }) : assert(testableId.isNotEmpty == true);

  static const id = 'ensure_exists';

  static final List<String> behaviorDrivenDescriptions = List.unmodifiable([
    'ensure the `{{testableId}}` widget exists.',
    'ensure the `{{testableId}}` widget exists and fail if it cannot be found in `{{timeout}}` seconds.',
  ]);

  /// The id of the [Testable] widget to interact with.
  final String testableId;

  /// The maximum amount of time this step will wait while searching for the
  /// [Testable] on the widget tree.
  final Duration? timeout;

  @override
  String get stepId => id;

  /// Creates an instance from a JSON-like map structure.  This expects the
  /// following format:
  ///
  /// ```json
  /// {
  ///   "testableId": <String>,
  ///   "timeout": <number>
  /// }
  /// ```
  ///
  /// See also:
  /// * [JsonClass.parseDurationFromSeconds]
  static EnsureExistsStep? fromDynamic(dynamic map) {
    EnsureExistsStep? result;

    if (map != null) {
      result = EnsureExistsStep(
        testableId: map['testableId']!,
        timeout: JsonClass.parseDurationFromSeconds(map['timeout']),
      );
    }

    return result;
  }

  /// Executes the test step by ensuring the [Testable] with the given id exists
  /// on the widget tree before continuing.  This will throw an error is the
  /// [Testable] with the set [testableId] cannot be found on the tree before
  /// the [timeout] is exceeded.
  @override
  Future<void> execute({
    required CancelToken cancelToken,
    required TestReport report,
    required TestController tester,
  }) async {
    final testableId = tester.resolveVariable(this.testableId);
    assert(testableId?.isNotEmpty == true);

    final name = "$id('$testableId')";
    log(
      name,
      tester: tester,
    );
    final finder = await waitFor(
      testableId,
      cancelToken: cancelToken,
      tester: tester,
      timeout: timeout,
    );

    await sleep(
      tester.delays.postFoundWidget,
      cancelStream: cancelToken.stream,
      tester: tester,
    );

    if (cancelToken.cancelled == true) {
      throw Exception('[CANCELLED]: step was cancelled by the test');
    }
    final widgetFinder = finder.evaluate();
    if (widgetFinder.isNotEmpty != true) {
      throw Exception('testableId: [$testableId] -- could not locate widget.');
    }
  }

  @override
  String getBehaviorDrivenDescription(TestController tester) {
    String result;

    if (timeout == null) {
      result = behaviorDrivenDescriptions[0];
    } else {
      result = behaviorDrivenDescriptions[1];
      result = result.replaceAll(
        '{{timeout}}',
        timeout!.inSeconds.toString(),
      );
    }

    result = result.replaceAll('{{testableId}}', testableId);

    return result;
  }

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
        'testableId': testableId,
        'timeout': timeout?.inSeconds,
      };
}
