import 'package:automated_testing_framework/automated_testing_framework.dart';

/// Sets a global variable on the identified [TestController].
class SetGlobalVariableStep extends TestRunnerStep {
  SetGlobalVariableStep({
    String type = 'String',
    required this.value,
    required this.variableName,
  })  : assert(type == 'bool' ||
            type == 'double' ||
            type == 'int' ||
            type == 'String'),
        type = type,
        assert(variableName.isNotEmpty == true);

  static const id = 'set_global_variable';

  static List<String> get behaviorDrivenDescriptions => List.unmodifiable([
        'set the `{{variableName}}` globally to `{{value}}` using a `{{type}}` type.',
      ]);

  /// The type of value to set.  This must be one of:
  /// * `bool`
  /// * `double`
  /// * `int`
  /// * `String`
  final String type;

  /// The string representation of the value to set.
  final String? value;

  /// The variable name of the variable to set on the controller.
  final String variableName;

  @override
  String get stepId => id;

  /// Creates an instance from a JSON-like map structure.  This expects the
  /// following format:
  ///
  /// ```json
  /// {
  ///   "type": <String>,
  ///   "value": <String>
  ///   "variableName": <String>,
  /// }
  /// ```
  static SetGlobalVariableStep? fromDynamic(dynamic map) {
    SetGlobalVariableStep? result;

    if (map != null) {
      result = SetGlobalVariableStep(
        type: map['type'] ?? 'String',
        value: map['value']?.toString(),
        variableName: map['variableName'],
      );
    }

    return result;
  }

  /// Sets the global variable on the [TestController].
  @override
  Future<void> execute({
    required CancelToken cancelToken,
    required TestReport report,
    required TestController tester,
  }) async {
    final type = tester.resolveVariable(this.type);
    final value = tester.resolveVariable(this.value);
    final variableName = tester.resolveVariable(this.variableName);

    assert(type == 'bool' ||
        type == 'double' ||
        type == 'int' ||
        type == 'String');
    assert(variableName.isNotEmpty == true);
    final name = "$id('$variableName', '$type', '$value')";

    log(
      name,
      tester: tester,
    );
    tester.setGlobalVariable(
      variableName: variableName,
      value: value,
    );
  }

  @override
  String getBehaviorDrivenDescription(TestController tester) =>
      behaviorDrivenDescriptions[0]
          .replaceAll('{{variableName}}', variableName)
          .replaceAll('{{type}}', type)
          .replaceAll('{{value}}', value ?? 'null');

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
        'type': type,
        'value': value,
        'variableName': variableName,
      };
}
