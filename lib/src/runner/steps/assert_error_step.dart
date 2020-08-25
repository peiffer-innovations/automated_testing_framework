import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

/// Test step that asserts that the error value equals (or does not equal) a
/// specific value.
class AssertErrorStep extends TestRunnerStep {
  AssertErrorStep({
    @required this.equals,
    @required this.error,
    @required this.testableId,
    this.timeout,
  })  : assert(equals != null),
        assert(testableId?.isNotEmpty == true);

  /// Set to [true] if the error from the widget must equal the [error] value.
  /// Set to [false] if the error from the widget must not equal the [error]
  /// value.
  final bool equals;

  /// The error value to test against.
  final String error;

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
  ///   "error": <String>,
  ///   "equals": <bool>,
  ///   "testableId": <String>,
  ///   "timeout": <number>
  /// }
  /// ```
  ///
  /// See also:
  /// * [JsonClass.parseBool]
  /// * [JsonClass.parseDurationFromSeconds]
  static AssertErrorStep fromDynamic(dynamic map) {
    AssertErrorStep result;

    if (map != null) {
      result = AssertErrorStep(
        error: map['error'],
        equals:
            map['equals'] == null ? true : JsonClass.parseBool(map['equals']),
        testableId: map['testableId'],
        timeout: JsonClass.parseDurationFromSeconds(map['timeout']),
      );
    }

    return result;
  }

  /// Executes the step.  This will first look for the [Testable], get the error
  /// from the [Testable], then compare it against the set [error] value.
  @override
  Future<void> execute({
    @required TestReport report,
    @required TestController tester,
  }) async {
    var name = "assertError('$testableId', '$error')";
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
    var match = false;
    if (widgetFinder?.isNotEmpty == true) {
      StatefulElement element = widgetFinder.first;

      var state = element.state;
      if (state is TestableState) {
        try {
          var actual = state.onRequestError();
          if (equals == (actual?.toString() == error)) {
            match = true;
          } else {
            throw Exception(
              'testableId: [$testableId] -- actualValue: [$actual] ${equals == true ? '!=' : '=='} [$error].',
            );
          }
        } catch (e) {
          // no-op; fail via "match != true"
        }
      }
    }
    if (match != true) {
      throw Exception(
        'testableId: [$testableId] -- could not locate Testable with a functional [onRequestError] method.',
      );
    }
  }

  /// Converts this to a JSON compatible map.  For a description of the format,
  /// see [fromDynamic].
  @override
  Map<String, dynamic> toJson() => {
        'equals': equals,
        'error': error,
        'testableId': testableId,
        'timeout': timeout?.inSeconds,
      };
}
