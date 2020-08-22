import 'package:meta/meta.dart';

@immutable
class TestStepDelays {
  const TestStepDelays({
    this.defaultTimeout = const Duration(seconds: 10),
    this.postFoundWidget = const Duration(),
    this.postStep = const Duration(seconds: 1),
    this.postSubmitReport = const Duration(seconds: 5),
    this.preStep = const Duration(seconds: 1),
    this.scrollIncrement = const Duration(milliseconds: 100),
    this.testSetUp = const Duration(milliseconds: 500),
    this.testTearDown = const Duration(milliseconds: 500),
  })  : assert(defaultTimeout != null),
        assert(postFoundWidget != null),
        assert(postSubmitReport != null),
        assert(scrollIncrement != null),
        assert(testSetUp != null),
        assert(testTearDown != null);

  final Duration defaultTimeout;
  final Duration postFoundWidget;
  final Duration postStep;
  final Duration postSubmitReport;
  final Duration preStep;
  final Duration scrollIncrement;
  final Duration testSetUp;
  final Duration testTearDown;
}
