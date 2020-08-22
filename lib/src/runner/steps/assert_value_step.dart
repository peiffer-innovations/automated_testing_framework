import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

class AssertValueStep extends TestRunnerStep {
  AssertValueStep({
    @required this.equals,
    @required this.testableId,
    this.timeout,
    @required this.value,
  })  : assert(equals != null),
        assert(testableId?.isNotEmpty == true);

  final bool equals;
  final String testableId;
  final Duration timeout;
  final String value;

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

  @override
  Map<String, dynamic> toJson() => {
        'equals': equals,
        'testableId': testableId,
        'timeout': timeout?.inSeconds,
        'value': value,
      };
}
