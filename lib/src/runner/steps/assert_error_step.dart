import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

/// Test step that asserts that the error value equals (or does not equal) a
/// specific value.
class AssertErrorStep extends TestRunnerStep {
  AssertErrorStep({
    @required this.caseSensitive,
    @required this.equals,
    @required this.error,
    @required this.testableId,
    this.timeout,
  })  : assert(caseSensitive != null),
        assert(equals != null),
        assert(testableId?.isNotEmpty == true);

  /// Set to [true] if the comparison should be case sensitive.  Set to [false]
  /// to allow the comparison to be case insensitive.
  final bool caseSensitive;

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
  ///   "caseSensitive": <bool>,
  ///   "equals": <bool>,
  ///   "error": <String>,
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
        caseSensitive: map['caseSensitive'] == null
            ? true
            : JsonClass.parseBool(map['caseSensitive']),
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
    String error = tester.resolveVariable(this.error);
    String testableId = tester.resolveVariable(this.testableId);
    assert(testableId?.isNotEmpty == true);

    var name =
        "assert_error('$testableId', '$error', '$equals', '$caseSensitive')";
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

          if (equals ==
              (caseSensitive == true
                  ? (actual?.toString() == error)
                  : (actual?.toString()?.toLowerCase() ==
                      error?.toString()?.toLowerCase()))) {
            match = true;
          } else {
            throw Exception(
              'testableId: [$testableId] -- actualValue: [$actual] ${equals == true ? '!=' : '=='} [$error] (caseSensitive = [$caseSensitive]).',
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

  /// Overidden to ignore the delay
  @override
  Future<void> postStepSleep(Duration duration) async {}

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
