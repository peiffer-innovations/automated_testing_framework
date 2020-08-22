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

  final AvailableTestStep availableTestStep;
  final TestRunnerStepBuilder testRunnerStepBuilder;

  String get id => availableTestStep.id;
}
