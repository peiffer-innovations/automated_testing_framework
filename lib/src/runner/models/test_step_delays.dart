import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

/// Defines the various delays and timeouts involved when executing tests.
@immutable
class TestStepDelays implements JsonClass {
  /// Constructs the delay object.  All values have timeouts that have been
  /// tested via the example application on various devices.  They may need to
  /// be altered based on your individual application's timings and
  /// requirements.
  const TestStepDelays({
    this.defaultTimeout = const Duration(seconds: 10),
    this.postFoundWidget = const Duration(),
    this.postStep = const Duration(seconds: 1),
    this.postSubmitReport = const Duration(seconds: 5),
    this.preStep = const Duration(seconds: 1),
    this.screenshot = const Duration(seconds: 5),
    this.scrollIncrement = const Duration(milliseconds: 100),
    this.testSetUp = const Duration(milliseconds: 500),
    this.testTearDown = const Duration(milliseconds: 500),
  })  : assert(defaultTimeout != null),
        assert(postFoundWidget != null),
        assert(postStep != null),
        assert(postSubmitReport != null),
        assert(preStep != null),
        assert(screenshot != null),
        assert(scrollIncrement != null),
        assert(testSetUp != null),
        assert(testTearDown != null);

  /// The default amount of time to wait for a widget being tested to become
  /// available on the widget tree.  Exceeding this timeout will result in an
  /// error that will fail the associated test step.
  final Duration defaultTimeout;

  /// The amount of time to wait aftr discovering a widget being tested.  This
  /// allows the widget to perform any post-processing that it may do once it is
  /// attached to the tree.  In general, this should be a small value and the
  /// [SleepStep] should be used when specific widgets need large amounts of time
  /// after being added to the tree.
  final Duration postFoundWidget;

  /// The amount of time to wait after a step is complete before moving to the
  /// next step.
  final Duration postStep;

  /// The amount of time to wait after a test report was submitted before
  /// resetting and starting the next test.
  final Duration postSubmitReport;

  /// The amount of time to wait before starting a step.
  final Duration preStep;

  /// The time to wait in order to receive a screenshot.  Screenshot requests
  /// are fully async so this time needs to be large enough for a device to
  /// generate and respond to a screenshot request.
  final Duration screenshot;

  /// The amount of time to wait between each scroll attempt.  A value too small
  /// will result in scroll attempts happening too close for the scroller to
  /// complete each step.
  final Duration scrollIncrement;

  /// The amount of time at the start of each test to wait after the reset
  /// request and before any steps are executed.
  final Duration testSetUp;

  /// The amount of time at the end of each test to wait before submitting the
  /// report or initiating the reset request for the next test.
  final Duration testTearDown;

  /// Creates the delays object from a JSON-like map.  The format of the map is
  /// as follows:
  ///
  /// ```json
  /// {
  ///   "defaultTimeout": <number>,
  ///   "postFoundWidget": <number>,
  ///   "postStep": <number>,
  ///   "postSubmitReport": <number>,
  ///   "preStep": <number>,
  ///   "screenshot": <number>,
  ///   "scrollIncrement": <number>,
  ///   "testSetUp": <number>,
  ///   "testTearDown": <number>
  /// }
  /// ```
  ///
  /// See also:
  /// * [JsonClass.parseDurationFromMillis]
  static TestStepDelays fromDynamic(dynamic map) {
    TestStepDelays result;

    if (map != null) {
      result = TestStepDelays(
        defaultTimeout: JsonClass.parseDurationFromMillis(
          map['defaultTimeout'],
          Duration(seconds: 10),
        ),
        postFoundWidget: JsonClass.parseDurationFromMillis(
          map['postFoundWidget'],
          Duration(),
        ),
        postStep: JsonClass.parseDurationFromMillis(
          map['postStep'],
          Duration(seconds: 1),
        ),
        postSubmitReport: JsonClass.parseDurationFromMillis(
          map['postSubmitReport'],
          Duration(seconds: 5),
        ),
        preStep: JsonClass.parseDurationFromMillis(
          map['preStep'],
          Duration(seconds: 1),
        ),
        screenshot: JsonClass.parseDurationFromMillis(
          map['screenshot'],
          Duration(seconds: 5),
        ),
        scrollIncrement: JsonClass.parseDurationFromMillis(
          map['scrollIncrement'],
          Duration(milliseconds: 100),
        ),
        testSetUp: JsonClass.parseDurationFromMillis(
          map['testSetUp'],
          Duration(milliseconds: 500),
        ),
        testTearDown: JsonClass.parseDurationFromMillis(
          map['testTearDown'],
          Duration(milliseconds: 500),
        ),
      );
    }

    return result;
  }

  /// Converts this delay object to a JSON compatible map.  For the format, see
  /// [fromDynamic].
  @override
  Map<String, dynamic> toJson() => {
        'defaultTimeout': defaultTimeout.inMilliseconds,
        'postFoundWidget': postFoundWidget.inMilliseconds,
        'postStep': postStep.inMilliseconds,
        'postSubmitReport': postSubmitReport.inMilliseconds,
        'preStep': preStep.inMilliseconds,
        'screenshot': screenshot.inMilliseconds,
        'scrollIncrement': scrollIncrement.inMilliseconds,
        'testSetUp': testSetUp.inMilliseconds,
        'testTearDown': testTearDown.inMilliseconds,
      };
}
