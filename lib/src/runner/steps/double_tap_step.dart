import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:json_class/json_class.dart';

/// Step that double-taps a [Testable] widget.
class DoubleTapStep extends TestRunnerStep {
  DoubleTapStep({
    required this.testableId,
    this.timeout,
  }) : assert(testableId.isNotEmpty == true);

  static const id = 'double_tap';

  static final List<String> behaviorDrivenDescriptions = List.unmodifiable([
    'double tap the `{{testableId}}` widget.',
    'double tap the `{{testableId}}` widget and fail if it cannot be found in `{{timeout}}` seconds.',
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
  static DoubleTapStep? fromDynamic(dynamic map) {
    DoubleTapStep? result;

    if (map != null) {
      result = DoubleTapStep(
        testableId: map['testableId']!,
        timeout: JsonClass.parseDurationFromSeconds(map['timeout']),
      );
    }

    return result;
  }

  /// Attempts to locate the [Testable] widget identified by [testableId] and
  /// then will attempt to double tap the widget on center point of the widget.
  @override
  Future<void> execute({
    required CancelToken cancelToken,
    required TestReport report,
    required TestController tester,
  }) async {
    String? testableId = tester.resolveVariable(this.testableId);
    assert(testableId?.isNotEmpty == true);

    var name = "double_tap('$testableId')";
    log(
      name,
      tester: tester,
    );

    var finder = await waitFor(
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
    await driver.tap(finder);

    if (cancelToken.cancelled == true) {
      throw Exception('[CANCELLED]: step was cancelled by the test');
    }
    await Future.delayed(Duration(milliseconds: 100));

    if (cancelToken.cancelled == true) {
      throw Exception('[CANCELLED]: step was cancelled by the test');
    }
    await driver.tap(finder);
  }

  @override
  String getBehaviorDrivenDescription() {
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

  /// Converts this to a JSON compatible map.  For a description of the format,
  /// see [fromDynamic].
  @override
  Map<String, dynamic> toJson() => {
        'testableId': testableId,
        'timeout': timeout?.inSeconds,
      };
}
