import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

/// Test step that dismisses the keyboard.
class DismissKeyboardStep extends TestRunnerStep {
  /// Creates an instance from a JSON-like map structure.  This expects the
  /// following format:
  ///
  /// ```json
  /// {
  /// }
  /// ```
  static DismissKeyboardStep fromDynamic(dynamic map) {
    DismissKeyboardStep result;

    if (map != null) {
      result = DismissKeyboardStep();
    }

    return result;
  }

  /// Dismisses the keyboard if shown and does nothing if the keyboard is not
  /// currently showing.
  @override
  Future<void> execute({
    @required TestReport report,
    @required TestController tester,
  }) async {
    log(
      'dismiss_keyboard',
      tester: tester,
    );
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  /// Overidden to ignore the delay
  @override
  Future<void> preStepSleep(Duration duration) async {}

  /// Converts this to a JSON compatible map.  For a description of the format,
  /// see [fromDynamic].
  @override
  Map<String, dynamic> toJson() => {};
}
