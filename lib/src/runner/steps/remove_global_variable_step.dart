import 'package:automated_testing_framework/automated_testing_framework.dart';

/// Sets a global variable on the identified [TestController].
class RemoveGlobalVariableStep extends TestRunnerStep {
  RemoveGlobalVariableStep({
    required this.variableName,
  }) : assert(variableName.isNotEmpty == true);

  static const id = 'remove_global_variable';

  static List<String> get behaviorDrivenDescriptions => List.unmodifiable([
        'Removes the `{{variableName}}` globally.',
      ]);

  /// The variable name of the variable to set on the controller.
  final String variableName;

  @override
  String get stepId => id;

  /// Creates an instance from a JSON-like map structure.  This expects the
  /// following format:
  ///
  /// ```json
  /// {
  ///   "variableName": <String>,
  /// }
  /// ```
  static RemoveGlobalVariableStep? fromDynamic(dynamic map) {
    RemoveGlobalVariableStep? result;

    if (map != null) {
      result = RemoveGlobalVariableStep(
        variableName: map['variableName'],
      );
    }

    return result;
  }

  /// Removes the global variable from the [TestController].
  @override
  Future<void> execute({
    required CancelToken cancelToken,
    required TestReport report,
    required TestController tester,
  }) async {
    String variableName = tester.resolveVariable(this.variableName);

    assert(variableName.isNotEmpty == true);
    var name = "$id('$variableName')";

    log(
      name,
      tester: tester,
    );
    tester.removeGlobalVariable(variableName: variableName);
  }

  @override
  String getBehaviorDrivenDescription(TestController tester) =>
      behaviorDrivenDescriptions[0]
          .replaceAll('{{variableName}}', variableName);

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
        'variableName': variableName,
      };
}
