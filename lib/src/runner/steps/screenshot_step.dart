import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:json_class/json_class.dart';

class ScreenshotStep extends TestRunnerStep {
  ScreenshotStep({
    this.goldenCompatible = true,
    this.imageId,
  });

  static const id = 'screenshot';

  static final List<String> behaviorDrivenDescriptions = List.unmodifiable([
    'take a screenshot.',
    'take a screenshot and name it `{{imageId}}`.',
    'take a screenshot and tag it as `{{goldenCompatible}}`.',
    'take a screenshot, name it `{{imageId}}`, and tag it as `{{goldenCompatible}}`.',
  ]);

  /// Set to [false] if this image is known to be capturing dynamic information
  /// that is incompatible with golden images.
  final bool goldenCompatible;

  /// The id of the screenshot.  This will be saved in the report along with the
  /// screenshot itself.
  final String? imageId;

  @override
  String get stepId => id;

  /// Creates an instance from a JSON-like map structure.  This expects the
  /// following format:
  ///
  /// ```json
  /// {
  ///   "goldenCompatible": <bool>,
  ///   "imageId": <String>
  /// }
  /// ```
  static ScreenshotStep? fromDynamic(dynamic map) {
    ScreenshotStep? result;

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
    required CancelToken cancelToken,
    required TestReport report,
    required TestController tester,
  }) async {
    var imageId = this.imageId ?? 'screenshot_${report.images.length}';
    var name = "screenshot('$imageId', '$goldenCompatible')";
    log(
      name,
      tester: tester,
    );
    var image = await tester.screencap();

    if (image != null) {
      report.attachScreenshot(
        image,
        goldenCompatible: goldenCompatible,
        id: imageId,
      );
    }
  }

  @override
  String getBehaviorDrivenDescription() {
    String result;

    if (imageId == null && goldenCompatible == false) {
      result = behaviorDrivenDescriptions[0];
    } else if (imageId != null && goldenCompatible == false) {
      result = behaviorDrivenDescriptions[1];
    } else if (imageId == null && goldenCompatible == true) {
      result = behaviorDrivenDescriptions[2];
    } else {
      result = behaviorDrivenDescriptions[3];
    }

    result = result.replaceAll('{{imageId}}', imageId ?? 'null');
    result = result.replaceAll(
      '{{goldenCompatible}}',
      goldenCompatible == true ? 'golden' : 'not golden',
    );

    return result;
  }

  /// Overidden to ignore the delay
  @override
  Future<void> postStepSleep(Duration duration) async {}

  /// Converts this to a JSON compatible map.  For a description of the format,
  /// see [fromDynamic].
  @override
  Map<String, dynamic> toJson() => {
        'imageId': imageId,
        'goldenCompatible': goldenCompatible,
      };
}
