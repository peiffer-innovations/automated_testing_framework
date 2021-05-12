import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:json_class/json_class.dart';

/// Step that will attempt to scroll another widget until it becomes visible.
class DragStep extends TestRunnerStep {
  DragStep({
    required this.dx,
    required this.dy,
    required this.testableId,
    this.timeout,
  })  : assert((dx != null && JsonClass.parseDouble(dx) != 0.0) ||
            (dx != null && JsonClass.parseDouble(dx) != 0.0)),
        assert(testableId.isNotEmpty == true);

  static const id = 'drag';

  static final List<String> behaviorDrivenDescriptions = List.unmodifiable([
    'drag the `{{testableId}}` widget horizontally by `{{dx}}` pixels.',
    'drag the `{{testableId}}` widget vertically by `{{dy}}` pixels.',
    'drag the `{{testableId}}` widget horizontally by `{{dx}}` pixels and vertically by `{{dy}}` pixels.',
    'drag the `{{testableId}}` widget horizontally by `{{dx}}` pixels  and fail if it cannot be found in `{{timeout}}` seconds.',
    'drag the `{{testableId}}` widget vertically by `{{dy}}` pixels and fail if it cannot be found in `{{timeout}}` seconds.',
    'drag the `{{testableId}}` widget horizontally by `{{dx}}` pixels, vertically by `{{dy}}` pixels and fail if it cannot be found in `{{timeout}}` seconds.',
  ]);

  /// The horizontal drag direction in device-independent-pixels.  This may be a
  /// positive or negative number.  The relative direction depends on the
  /// device's Left-to-Right configuration.
  final String? dx;

  /// The vertical drag direction in device-independent-pixels.  This may be a
  /// positive or negative number.  The relative direction depends on the
  /// device's Up-to-Down configuration.
  final String? dy;

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
  ///   "dx": <number>,
  ///   "dy": <number>,
  ///   "testableId": <String>,
  ///   "timeout": <number>
  /// }
  /// ```
  ///
  /// See also:
  /// * [JsonClass.parseDurationFromSeconds]
  static DragStep? fromDynamic(dynamic map) {
    DragStep? result;

    if (map != null) {
      result = DragStep(
        dx: map['dx']?.toString(),
        dy: map['dy']?.toString(),
        testableId: map['testableId']!,
        timeout: JsonClass.parseDurationFromSeconds(map['timeout']),
      );
    }

    return result;
  }

  /// Executes the test step.  If the [scrollableId] is set then this will get
  /// that [Scrollable] instance and interact with it.  Otherwise, this will
  /// attempt to find the first [Scrollable] instance currently in the viewport
  /// and interact with that.
  ///
  /// For the most part, pages with a single [Scrollable] will work fine with
  /// omitting the [scrollableId].  However pages with multiple [Scrollables]
  /// (like a Netflix style stacked carousel) will require the [scrollableId] to
  /// be set in order to be able to find and interact with the inner
  /// [Scrollable] instances.
  ///
  /// The [timeout] defines how much time is allowed to pass while attempting to
  /// scroll and find the [Testable] identified by [testableId].
  @override
  Future<void> execute({
    required CancelToken cancelToken,
    required TestReport report,
    required TestController tester,
  }) async {
    var dx = JsonClass.parseDouble(tester.resolveVariable(this.dx)) ?? 0.0;
    var dy = JsonClass.parseDouble(tester.resolveVariable(this.dy)) ?? 0.0;
    String? testableId = tester.resolveVariable(this.testableId);
    assert(testableId?.isNotEmpty == true);

    var name = "$id('$testableId', '$dx', '$dy')";
    var timeout = this.timeout ?? tester.delays.defaultTimeout;
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

    await driver.drag(finder, Offset(dx, dy));
  }

  @override
  String getBehaviorDrivenDescription(TestController tester) {
    String result;

    var setDx = dx != null && JsonClass.parseDouble(dx) != 0.0;
    var setDy = dy != null && JsonClass.parseDouble(dy) != 0.0;

    if (timeout == null) {
      if (setDx && setDy) {
        result = behaviorDrivenDescriptions[2];
      } else if (setDx) {
        result = behaviorDrivenDescriptions[0];
      } else {
        result = behaviorDrivenDescriptions[1];
      }
    } else {
      if (setDx && setDy) {
        result = behaviorDrivenDescriptions[5];
      } else if (setDx) {
        result = behaviorDrivenDescriptions[3];
      } else {
        result = behaviorDrivenDescriptions[4];
      }

      result = result.replaceAll(
        '{{timeout}}',
        timeout!.inSeconds.toString(),
      );
    }

    result = result.replaceAll('{{dx}}', dx ?? 'null');
    result = result.replaceAll('{{dy}}', dy ?? 'null');
    result = result.replaceAll('{{testableId}}', testableId);

    return result;
  }

  /// Converts this to a JSON compatible map.  For a description of the format,
  /// see [fromDynamic].
  @override
  Map<String, dynamic> toJson() => {
        'dx': dx,
        'dy': dy,
        'testableId': testableId,
        'timeout': timeout?.inSeconds,
      };
}
