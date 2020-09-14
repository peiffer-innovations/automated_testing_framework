import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:meta/meta.dart';

class ScreenshotStep extends TestRunnerStep {
  /// Creates an instance from a JSON-like map structure.  This expects the
  /// following format:
  ///
  /// ```json
  /// {
  /// }
  /// ```
  static ScreenshotStep fromDynamic(dynamic map) {
    ScreenshotStep result;

    if (map != null) {
      result = ScreenshotStep();
    }

    return result;
  }

  /// Requests a screenshot from the framework and attaches it to the [report].
  @override
  Future<void> execute({
    @required TestReport report,
    @required TestController tester,
  }) async {
    tester.status = '<screenshot>';
    var image = await tester.screencap();

    if (image != null) {
      report?.attachScreenshot(image);
    }
  }

  /// Overidden to ignore the delay
  @override
  Future<void> postStepSleep(Duration duration) async {}

  /// Converts this to a JSON compatible map.  For a description of the format,
  /// see [fromDynamic].
  @override
  Map<String, dynamic> toJson() => {};
}
