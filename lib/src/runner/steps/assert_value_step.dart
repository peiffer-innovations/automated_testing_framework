import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

/// Test step that asserts that the value equals (or does not equal) a specific
/// value.
class AssertValueStep extends TestRunnerStep {
  AssertValueStep({
    @required this.caseSensitive,
    @required this.equals,
    @required this.testableId,
    this.timeout,
    @required this.value,
  })  : assert(caseSensitive != null),
        assert(equals != null),
        assert(testableId?.isNotEmpty == true);

  /// Set to [true] if the comparison should be case sensitive.  Set to [false]
  /// to allow the comparison to be case insensitive.
  final bool caseSensitive;

  /// Set to [true] if the value from the [Testable] must equal the set [value].
  /// Set to [false] if the value from the [Testable] must not equal the
  /// [value].
  final bool equals;

  /// The id of the [Testable] widget to interact with.
  final String testableId;

  /// The maximum amount of time this step will wait while searching for the
  /// [Testable] on the widget tree.
  final Duration timeout;

  /// The [value] to test againt when comparing the [Testable]'s value.
  final String value;

  /// Creates an instance from a JSON-like map structure.  This expects the
  /// following format:
  ///
  /// ```json
  /// {
  ///   "caseSensitive": <bool>,
  ///   "equals": <bool>,
  ///   "testableId": <String>,
  ///   "timeout": <number>,
  ///   "value": <String>
  /// }
  /// ```
  ///
  /// See also:
  /// * [JsonClass.parseBool]
  /// * [JsonClass.parseDurationFromSeconds]
  static AssertValueStep fromDynamic(dynamic map) {
    AssertValueStep result;

    if (map != null) {
      result = AssertValueStep(
        caseSensitive: map['caseSensitive'] == null
            ? true
            : JsonClass.parseBool(map['caseSensitive']),
        equals:
            map['equals'] == null ? true : JsonClass.parseBool(map['equals']),
        testableId: map['testableId'],
        timeout: JsonClass.parseDurationFromSeconds(map['timeout']),
        value: map['value']?.toString(),
      );
    }

    return result;
  }

  /// Executes the step.  This will first look for the [Testable], get the value
  /// from the [Testable], then compare it against the set [value].
  @override
  Future<void> execute({
    @required TestReport report,
    @required TestController tester,
  }) async {
    String testableId = tester.resolveVariable(this.testableId);
    var value = tester.resolveVariable(this.value)?.toString();
    assert(testableId?.isNotEmpty == true);

    var name =
        "assert_value('$testableId', '$value', '$equals', '$caseSensitive')";
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
    dynamic actual;
    if (widgetFinder?.isNotEmpty == true) {
      StatefulElement element = widgetFinder.first;

      var state = element.state;
      if (state is TestableState) {
        try {
          actual = state.onRequestValue();
          if (equals ==
              (caseSensitive == true
                  ? (actual?.toString() == value)
                  : (actual?.toString()?.toLowerCase() ==
                      value?.toString()?.toLowerCase()))) {
            match = true;
          }
        } catch (e) {
          throw Exception(
            'testableId: [$testableId] -- could not locate Testable with a functional [onRequestValue] method.',
          );
        }
      }
    }
    if (match != true) {
      throw Exception(
        'testableId: [$testableId] -- actualValue: [$actual] ${equals == true ? '!=' : '=='} [$value] (caseSensitive = [$caseSensitive]).',
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
        'testableId': testableId,
        'timeout': timeout?.inSeconds,
        'value': value,
      };
}
