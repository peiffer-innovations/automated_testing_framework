import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// Sets a variable on the identified [TestController].
class SetVariableStep extends TestRunnerStep {
  SetVariableStep({
    @required this.key,
    String type = 'String',
    @required this.value,
  })  : assert(key?.isNotEmpty == true),
        assert(type != null),
        assert(type == 'bool' ||
            type == 'double' ||
            type == 'int' ||
            type == 'String'),
        type = type;

  /// The Key (or name) of the variable to set on the controller.
  final String key;

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
  ///   "key": <String>,
  ///   "type": <String>,
  ///   "value": <String>
  /// }
  /// ```
  static SetVariableStep fromDynamic(dynamic map) {
    SetVariableStep result;

    if (map != null) {
      result = SetVariableStep(
        key: map['key'],
        type: map['type'] ?? 'String',
        value: map['value']?.toString(),
      );
    }

    return result;
  }

  /// Sets the variable on the [TestController].
  @override
  Future<void> execute({
    @required TestReport report,
    @required TestController tester,
  }) async {
    String key = tester.resolveVariable(this.key);
    String type = tester.resolveVariable(this.type);
    String value = tester.resolveVariable(this.value);

    assert(key?.isNotEmpty == true);
    assert(type != null);
    assert(type == 'bool' ||
        type == 'double' ||
        type == 'int' ||
        type == 'String');
    var name = "set_variable('$key', '$type', '$value')";

    log(
      name,
      tester: tester,
    );
    tester.setVariable(
      key: key,
      value: value,
    );
  }

  /// Overidden to ignore the delay
  @override
  Future<void> preStepSleep(Duration duration) async {}

  /// Overidden to ignore the delay
  @override
  Future<void> postStepSleep(Duration duration) async {}

  /// Converts this to a JSON compatible map.  For a description of the format,
  /// see [fromDynamic].
  @override
  Map<String, dynamic> toJson() => {
        'key': key,
        'type': type,
        'value': value,
      };
}
