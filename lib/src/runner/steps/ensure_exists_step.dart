import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

/// Test step that ensures a particular widget exists on the widget tree before
/// continuing.
class EnsureExistsStep extends TestRunnerStep {
  EnsureExistsStep({
    @required this.testableId,
    this.timeout,
  }) : assert(testableId?.isNotEmpty == true);

  /// The id of the [Testable] widget to interact with.
  final String testableId;

  /// The maximum amount of time this step will wait while searching for the
  /// [Testable] on the widget tree.
  final Duration timeout;

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
  static EnsureExistsStep fromDynamic(dynamic map) {
    EnsureExistsStep result;

    if (map != null) {
      result = EnsureExistsStep(
        testableId: map['testableId'],
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
    @required TestReport report,
    @required TestController tester,
  }) async {
    var name = "ensureExists('$testableId')";
    log(
      name,
      tester: tester,
    );
    var finder = await waitFor(
      testableId,
      tester: tester,
      timeout: timeout,
    );

    await sleep(
      tester.delays.postFoundWidget,
      tester: tester,
    );

    var widgetFinder = finder.evaluate();
    if (widgetFinder?.isNotEmpty != true) {
      throw Exception('testableId: [$testableId] -- could not locate widget.');
    }
  }

  /// Converts this to a JSON compatible map.  For a description of the format,
  /// see [fromDynamic].
  @override
  Map<String, dynamic> toJson() => {
        'testableId': testableId,
        'timeout': timeout?.inSeconds,
      };
}
