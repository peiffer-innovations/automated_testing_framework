import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:meta/meta.dart';

class ScreenshotStep extends TestRunnerStep {
  static ScreenshotStep fromDynamic(dynamic map) {
    ScreenshotStep result;

    if (map != null) {
      result = ScreenshotStep();
    }

    return result;
  }

  @override
  Future<void> execute({
    @required TestReport report,
    @required TestController tester,
  }) async {
    tester.status = '<screenshot>';
    var image = await tester.screencap();

    report?.attachScreenshot(image);
  }

  @override
  Map<String, dynamic> toJson() => {};
}
