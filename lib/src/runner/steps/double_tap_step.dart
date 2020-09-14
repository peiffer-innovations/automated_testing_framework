import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

/// Step that double-taps a [Testable] widget.
class DoubleTapStep extends TestRunnerStep {
  DoubleTapStep({
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
  static DoubleTapStep fromDynamic(dynamic map) {
    DoubleTapStep result;

    if (map != null) {
      result = DoubleTapStep(
        testableId: map['testableId'],
        timeout: JsonClass.parseDurationFromSeconds(map['timeout']),
      );
    }

    return result;
  }

  /// Attempts to locate the [Testable] widget identified by [testableId] and
  /// then will attempt to double tap the widget on center point of the widget.
  @override
  Future<void> execute({
    @required TestReport report,
    @required TestController tester,
  }) async {
    String testableId = tester.resolveVariable(this.testableId);
    assert(testableId?.isNotEmpty == true);

    var name = "double_tap('$testableId')";
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

    await driver.tap(finder);
    await Future.delayed(Duration(milliseconds: 100));
    await driver.tap(finder);
  }

  /// Converts this to a JSON compatible map.  For a description of the format,
  /// see [fromDynamic].
  @override
  Map<String, dynamic> toJson() => {
        'testableId': testableId,
        'timeout': timeout?.inSeconds,
      };
}
