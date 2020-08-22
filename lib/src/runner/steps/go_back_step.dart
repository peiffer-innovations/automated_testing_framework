import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:meta/meta.dart';

class GoBackStep extends TestRunnerStep {
  static GoBackStep fromDynamic(dynamic map) {
    GoBackStep result;

    if (map != null) {
      result = GoBackStep();
    }

    return result;
  }

  @override
  Future<void> execute({
    @required TestReport report,
    @required TestController tester,
  }) async {
    log(
      'goBack',
      tester: tester,
    );
    var backButton = find.byTooltip('Back');

    await driver.tap(backButton);
  }

  @override
  Map<String, dynamic> toJson() => {};
}
