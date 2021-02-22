import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

/// Sets a value on the identified [Testable].
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
        type = type;

  /// The id of the [Testable] widget to interact with.
  final String testableId;

  /// The maximum amount of time this step will wait while searching for the
  /// [Testable] on the widget tree.
  final Duration timeout;

  /// The type of value to set.  This must be one of:
  /// * `bool`
  /// * `double`
  /// * `int`
  /// * `String`
  final String type;

  /// The string representation of the value to set.
  final String value;

  /// Creates an instance from a JSON-like map structure.  This expects the
  /// following format:
  ///
  /// ```json
  /// {
  ///   "testableId": <String>,
  ///   "timeout": <number>,
  ///   "type": <String>,
  ///   "value": <String>
  /// }
  /// ```
  ///
  /// See also:
  /// * [JsonClass.parseDurationFromSeconds]
  static SetValueStep fromDynamic(dynamic map) {
    SetValueStep result;

    if (map != null) {
      result = SetValueStep(
        testableId: map['testableId'],
        timeout: JsonClass.parseDurationFromSeconds(map['timeout']),
        type: map['type'] ?? 'String',
        value: map['value']?.toString(),
      );
    }

    return result;
  }

  /// Attempts to locate the [Testable] identified by the [testableId] and will
  /// then set the associated [value] to the found widget.
  @override
  Future<void> execute({
    @required CancelToken cancelToken,
    @required TestReport report,
    @required TestController tester,
  }) async {
    String testableId = tester.resolveVariable(this.testableId);
    String type = tester.resolveVariable(this.type);
    var value = tester.resolveVariable(this.value)?.toString();

    assert(testableId?.isNotEmpty == true);
    assert(type != null);
    assert(type == 'bool' ||
        type == 'double' ||
        type == 'int' ||
        type == 'String');
    var name = "set_value('$testableId', '$type', '$value')";

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

    if (cancelToken.cancelled == true) {
      throw Exception('[CANCELLED]: step was cancelled by the test');
    }
    var widgetFinder = finder.evaluate();
    if (cancelToken.cancelled == true) {
      throw Exception('[CANCELLED]: step was cancelled by the test');
    }

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

  /// Converts this to a JSON compatible map.  For a description of the format,
  /// see [fromDynamic].
  @override
  Map<String, dynamic> toJson() => {
        'testableId': testableId,
        'timeout': timeout?.inSeconds,
        'type': type,
        'value': value,
      };
}
