import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:meta/meta.dart';

typedef TestRunnerStepBuilder = TestRunnerStep Function(dynamic values);

/// Simple class that binds an available test step with the actual running test
/// step.
@immutable
class TestStepBuilder {
  TestStepBuilder({
    @required this.availableTestStep,
    @required this.testRunnerStepBuilder,
  })  : assert(availableTestStep != null),
        assert(testRunnerStepBuilder != null);

  /// The test step that can be selected by the user.
  final AvailableTestStep availableTestStep;

  /// The builder that can build the actual test execution step.
  final TestRunnerStepBuilder testRunnerStepBuilder;

  /// Unique identifier (ideally; human readable) for the this step.
  String get id => availableTestStep.id;
}
