import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/services.dart';

/// Test step that dismisses the keyboard.
class DismissKeyboardStep extends TestRunnerStep {
  static const id = 'dismiss_keyboard';

  static List<String> get behaviorDrivenDescriptions => List.unmodifiable([
        'dismiss the keyboard.',
      ]);

  @override
  String get stepId => id;

  /// Creates an instance from a JSON-like map structure.  This expects the
  /// following format:
  ///
  /// ```json
  /// {
  /// }
  /// ```
  static DismissKeyboardStep? fromDynamic(dynamic map) {
    DismissKeyboardStep? result;

    if (map != null) {
      result = DismissKeyboardStep();
    }

    return result;
  }

  /// Dismisses the keyboard if shown and does nothing if the keyboard is not
  /// currently showing.
  @override
  Future<void> execute({
    required CancelToken cancelToken,
    required TestReport report,
    required TestController tester,
  }) async {
    log(
      '$id',
      tester: tester,
    );
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  String getBehaviorDrivenDescription(TestController tester) =>
      behaviorDrivenDescriptions[0];

  /// Overidden to ignore the delay
  @override
  Future<void> preStepSleep(Duration duration) async {}

  /// Converts this to a JSON compatible map.  For a description of the format,
  /// see [fromDynamic].
  @override
  Map<String, dynamic> toJson() => {};
}
