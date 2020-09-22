import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

class ScreenshotStep extends TestRunnerStep {
  ScreenshotStep({
    this.goldenCompatible,
    this.imageId,
  });

  /// Set to [false] if this image is known to be capturing dynamic information
  /// that is incompatible with golden images.
  final bool goldenCompatible;

  /// The id of the screenshot.  This will be saved in the report along with the
  /// screenshot itself.
  final String imageId;

  /// Creates an instance from a JSON-like map structure.  This expects the
  /// following format:
  ///
  /// ```json
  /// {
  ///   "goldenCompatible": <bool>,
  ///   "imageId": <String>
  /// }
  /// ```
  static ScreenshotStep fromDynamic(dynamic map) {
    ScreenshotStep result;

    if (map != null) {
      result = ScreenshotStep(
        goldenCompatible: map['goldenCompatible'] == null
            ? true
            : JsonClass.parseBool(map['goldenCompatible']),
        imageId: map['imageId'],
      );
    }

    return result;
  }

  /// Requests a screenshot from the framework and attaches it to the [report].
  @override
  Future<void> execute({
    @required TestReport report,
    @required TestController tester,
  }) async {
    var imageId = this.imageId ?? 'screenshot_${report?.images?.length ?? 0}';
    var name = "screenshot('$imageId', '$goldenCompatible')";
    log(
      name,
      tester: tester,
    );
    var image = await tester.screencap();

    if (image != null) {
      report?.attachScreenshot(
        image,
        goldenCompatible: goldenCompatible,
        id: imageId,
      );
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
