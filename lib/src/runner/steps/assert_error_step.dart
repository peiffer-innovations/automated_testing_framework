import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

class AssertErrorStep extends TestRunnerStep {
  AssertErrorStep({
    @required this.equals,
    @required this.error,
    @required this.testableId,
    this.timeout,
  })  : assert(equals != null),
        assert(testableId?.isNotEmpty == true);

  final bool equals;
  final String error;
  final String testableId;
  final Duration timeout;

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

  @override
  Map<String, dynamic> toJson() => {
        'equals': equals,
        'error': error,
        'testableId': testableId,
        'timeout': timeout?.inSeconds,
      };
}
