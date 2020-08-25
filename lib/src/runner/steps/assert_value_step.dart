import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

/// Test step that asserts that the value equals (or does not equal) a specific
/// value.
class AssertValueStep extends TestRunnerStep {
  AssertValueStep({
    @required this.equals,
    @required this.testableId,
    this.timeout,
    @required this.value,
  })  : assert(equals != null),
        assert(testableId?.isNotEmpty == true);

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
        equals:
            map['equals'] == null ? true : JsonClass.parseBool(map['equals']),
        testableId: map['testableId'],
        timeout: JsonClass.parseDurationFromSeconds(map['timeout']),
        value: map['value'],
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
    var name = "assertValue('$testableId', '$value')";
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
          var actual = state.onRequestValue();
          if (equals == (actual?.toString() == value)) {
            match = true;
          } else {
            throw Exception(
              'testableId: [$testableId] -- actualValue: [$actual] ${equals == true ? '!=' : '=='} [$value].',
            );
          }
        } catch (e) {
          // no-op; fail via "match != true"
        }
      }
    }
    if (match != true) {
      throw Exception(
        'testableId: [$testableId] -- could not locate Testable with a functional [onRequestValue] method.',
      );
    }
  }

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
