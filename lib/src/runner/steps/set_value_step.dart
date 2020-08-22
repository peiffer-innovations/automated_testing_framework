import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

class SetValueStep extends TestRunnerStep {
  SetValueStep({
    @required this.testableId,
    this.timeout,
    String type = 'String',
    @required this.value,
  })  : assert(testableId?.isNotEmpty == true),
        assert(type != null),
        assert(type == 'bool' ||
            type == 'double' ||
            type == 'int' ||
            type == 'String'),
        assert(value?.isNotEmpty == true),
        type = type;

  final String testableId;
  final Duration timeout;
  final String type;
  final String value;

  static SetValueStep fromDynamic(dynamic map) {
    SetValueStep result;

    if (map != null) {
      result = SetValueStep(
        testableId: map['testableId'],
        timeout: JsonClass.parseDurationFromSeconds(map['timeout']),
        type: map['type'],
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
    var name = "setValue('$testableId', '$value')";
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

    dynamic typedValue;
    switch (type) {
      case 'bool':
        typedValue = JsonClass.parseBool(value);
        break;

      case 'double':
        typedValue = JsonClass.parseDouble(value);
        break;

      case 'int':
        typedValue = JsonClass.parseInt(value);
        break;

      case 'String':
        typedValue = value;
        break;

      default:
        throw Exception('Unknown type encountered: $type');
    }

    var widgetFinder = finder.evaluate();
    var match = false;
    if (widgetFinder?.isNotEmpty == true) {
      try {
        StatefulElement element = widgetFinder.first;

        var state = element.state;
        if (state is TestableState) {
          state.onSetValue(typedValue);
          match = true;
        }
      } catch (e) {
        // no-op; fail via "match != true".
      }
    }
    if (match != true) {
      throw Exception(
        'testableId: [$testableId] -- could not locate Testable with a functional [onSetValue] method.',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'testableId': testableId,
        'timeout': timeout?.inSeconds,
        'type': type,
        'value': value,
      };
}
