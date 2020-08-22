import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

class DismissKeyboardStep extends TestRunnerStep {
  static DismissKeyboardStep fromDynamic(dynamic map) {
    DismissKeyboardStep result;

    if (map != null) {
      result = DismissKeyboardStep();
    }

    return result;
  }

  @override
  Future<void> execute({
    @required TestReport report,
    @required TestController tester,
  }) async {
    log(
      'dismissKeyboard',
      tester: tester,
    );
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  Map<String, dynamic> toJson() => {};
}
